# Step Apps: graceful then force stop; start configured executables.

function Invoke-AudioRebindApps {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $StepConfig,

        [switch] $WhatIf
    )

    $gracefulSec = 10
    $forceSec = 5
    if ($StepConfig.ContainsKey('gracefulStopSeconds') -and $null -ne $StepConfig.gracefulStopSeconds) {
        $gracefulSec = [int]$StepConfig.gracefulStopSeconds
    }
    if ($StepConfig.ContainsKey('forceStopSeconds') -and $null -ne $StepConfig.forceStopSeconds) {
        $forceSec = [int]$StepConfig.forceStopSeconds
    }

    $defaultWindow = 'leave'
    if ($StepConfig.ContainsKey('windowAfterStart') -and -not [string]::IsNullOrWhiteSpace([string]$StepConfig.windowAfterStart)) {
        $defaultWindow = ([string]$StepConfig.windowAfterStart).Trim().ToLowerInvariant()
    }

    $minimizeTimeoutMs = 1200
    if ($StepConfig.ContainsKey('minimizeTimeoutMs') -and $null -ne $StepConfig.minimizeTimeoutMs) {
        $minimizeTimeoutMs = [Math]::Max(0, [int]$StepConfig.minimizeTimeoutMs)
    }
    $minimizeNoWindowGiveUpMs = 400
    if ($StepConfig.ContainsKey('minimizeNoWindowGiveUpMs') -and $null -ne $StepConfig.minimizeNoWindowGiveUpMs) {
        $minimizeNoWindowGiveUpMs = [Math]::Max(0, [int]$StepConfig.minimizeNoWindowGiveUpMs)
    }

    $stopMode = 'graceful-then-force'
    if ($StepConfig.ContainsKey('stopMode') -and -not [string]::IsNullOrWhiteSpace([string]$StepConfig.stopMode)) {
        $stopMode = ([string]$StepConfig.stopMode).Trim().ToLowerInvariant()
    }
    if ($stopMode -notin @('graceful-then-force', 'force')) {
        Write-AudioRebindLog ("Apps: invalid stopMode '{0}', using graceful-then-force" -f $stopMode) -Level WARN
        $stopMode = 'graceful-then-force'
    }

    $postStopDelayMs = 200
    if ($StepConfig.ContainsKey('postStopDelayMs') -and $null -ne $StepConfig.postStopDelayMs) {
        $postStopDelayMs = [Math]::Max(0, [int]$StepConfig.postStopDelayMs)
    }
    $postForceStopMs = 200
    if ($StepConfig.ContainsKey('postForceStopMs') -and $null -ne $StepConfig.postForceStopMs) {
        $postForceStopMs = [Math]::Max(0, [int]$StepConfig.postForceStopMs)
    }

    $processes = @($StepConfig.processes)
    Write-AudioRebindLog ("Apps: {0} process entr(y/ies); graceful={1}s forceWait={2}s stopMode={3} postStopDelayMs={4} defaultWindow={5} minimizeTimeoutMs={6}" -f $processes.Count, $gracefulSec, $forceSec, $stopMode, $postStopDelayMs, $defaultWindow, $minimizeTimeoutMs)

    if ($WhatIf) {
        foreach ($entry in $processes) {
            $w = Get-AudioRebindWindowAfterStart -Entry $entry -Default $defaultWindow
            Write-AudioRebindLog ("Apps: WhatIf would recycle path='{0}' name='{1}' windowAfterStart={2} stopMode={3}" -f $entry.path, $entry.name, $w, $stopMode)
        }
        return $true
    }

    $stopSw = [System.Diagnostics.Stopwatch]::StartNew()
    # Stop all configured entries in one batched phase (not sequential per entry).
    Stop-AudioRebindProcessEntries -Entries $processes -GracefulSeconds $gracefulSec -ForceWaitSeconds $forceSec -StopMode $stopMode -PostForceStopMs $postForceStopMs
    if ($postStopDelayMs -gt 0) {
        Start-Sleep -Milliseconds $postStopDelayMs
    }
    $stopSw.Stop()
    Write-AudioRebindLog ("Apps: stop phase elapsedMs={0}" -f $stopSw.ElapsedMilliseconds)

    $ok = $true
    foreach ($entry in $processes) {
        if (-not (Start-AudioRebindProcessEntry -Entry $entry -DefaultWindowAfterStart $defaultWindow -MinimizeTimeoutMs $minimizeTimeoutMs -MinimizeNoWindowGiveUpMs $minimizeNoWindowGiveUpMs)) {
            $ok = $false
        }
    }
    return $ok
}

function Get-AudioRebindWindowAfterStart {
    param($Entry, [string] $Default)
    if ($Entry -is [hashtable] -and $Entry.ContainsKey('windowAfterStart') -and -not [string]::IsNullOrWhiteSpace([string]$Entry.windowAfterStart)) {
        return ([string]$Entry.windowAfterStart).Trim().ToLowerInvariant()
    }
    return $Default
}

function Find-AudioRebindProcessesForEntries {
    param([object[]] $Entries)
    $all = @()
    foreach ($entry in $Entries) {
        $found = @(Find-AudioRebindProcesses -Entry $entry)
        foreach ($p in $found) {
            $all += $p
        }
    }
    return @($all | Sort-Object -Property Id -Unique)
}

function Stop-AudioRebindProcessEntries {
    param(
        [object[]] $Entries,
        [int] $GracefulSeconds,
        [int] $ForceWaitSeconds,
        [string] $StopMode = 'graceful-then-force',
        [int] $PostForceStopMs = 200
    )

    $targets = @(Find-AudioRebindProcessesForEntries -Entries $Entries)
    if ($targets.Count -eq 0) {
        Write-AudioRebindLog "Apps: no running processes for configured entries"
        return
    }

    Write-AudioRebindLog ("Apps: stopping {0} process(es) across {1} entr(y/ies) mode={2}" -f $targets.Count, $Entries.Count, $StopMode)

    if ($StopMode -eq 'graceful-then-force') {
        foreach ($p in $targets) {
            Write-AudioRebindLog ("Apps: CloseMainWindow pid={0} name='{1}'" -f $p.Id, $p.ProcessName)
            try {
                $null = $p.CloseMainWindow()
            }
            catch { }
        }

        if ($GracefulSeconds -gt 0) {
            $deadline = (Get-Date).AddSeconds($GracefulSeconds)
            while ((Get-Date) -lt $deadline) {
                $left = @(Find-AudioRebindProcessesForEntries -Entries $Entries)
                if ($left.Count -eq 0) { break }
                Start-Sleep -Milliseconds 100
            }
        }
    }

    $left = @(Find-AudioRebindProcessesForEntries -Entries $Entries)
    if ($left.Count -eq 0) {
        return
    }

    Write-AudioRebindLog ("Apps: force-stopping {0} process(es)" -f $left.Count) -Level WARN
    foreach ($p in $left) {
        try {
            Stop-Process -Id $p.Id -Force -ErrorAction Stop
        }
        catch {
            Write-AudioRebindLog ("Apps: force-stop failed pid={0}: {1}" -f $p.Id, $_.Exception.Message) -Level WARN
        }
    }

    # One shared wait for all entries (not sequential per entry).
    $waitSec = [Math]::Max(0, $ForceWaitSeconds)
    if ($waitSec -gt 0) {
        $deadline = (Get-Date).AddSeconds($waitSec)
        while ((Get-Date) -lt $deadline) {
            $still = @(Find-AudioRebindProcessesForEntries -Entries $Entries)
            if ($still.Count -eq 0) { break }
            Start-Sleep -Milliseconds 100
        }
    }

    $still = @(Find-AudioRebindProcessesForEntries -Entries $Entries)
    if ($still.Count -gt 0) {
        Write-AudioRebindLog ("Apps: {0} process(es) still present after force wait" -f $still.Count) -Level WARN
    }

    if ($PostForceStopMs -gt 0) {
        Start-Sleep -Milliseconds $PostForceStopMs
    }
}

function Start-AudioRebindProcessEntry {
    param(
        $Entry,
        [string] $DefaultWindowAfterStart = 'leave',
        [int] $MinimizeTimeoutMs = 1200,
        [int] $MinimizeNoWindowGiveUpMs = 400
    )

    $policy = Get-AudioRebindWindowAfterStart -Entry $Entry -Default $DefaultWindowAfterStart
    $path = $Entry.path
    if (-not [string]::IsNullOrWhiteSpace($path)) {
        if (-not (Test-Path -LiteralPath $path)) {
            Write-AudioRebindLog ("Apps: start path missing: {0}" -f $path) -Level ERROR
            return $false
        }
        try {
            $workDir = [IO.Path]::GetDirectoryName($path)
            if ($policy -eq 'minimize') {
                # Prefer CreateProcess + SW_SHOWMINNOACTIVE (#21) over Start-Process -WindowStyle Minimized
                # (which often flashes to the foreground before minimize).
                $pidStarted = Start-AudioRebindProcessNoActivate -FilePath $path -WorkingDirectory $workDir
                Write-AudioRebindLog ("Apps: started '{0}' (pid={1}, windowAfterStart=minimize, launch=CreateProcess/SW_SHOWMINNOACTIVE)" -f $path, $pidStarted)
                # Electron/Chromium often creates its own window later and may still activate —
                # keep a short SW_SHOWMINNOACTIVE poll as fallback (#16/#18).
                Set-AudioRebindWindowsMinimized -Entry $Entry -TimeoutMs $MinimizeTimeoutMs -NoWindowGiveUpMs $MinimizeNoWindowGiveUpMs
            }
            else {
                $startArgs = @{
                    FilePath     = $path
                    ErrorAction  = 'Stop'
                    PassThru     = $true
                }
                if (-not [string]::IsNullOrWhiteSpace($workDir)) {
                    $startArgs['WorkingDirectory'] = $workDir
                }
                $started = Start-Process @startArgs
                Write-AudioRebindLog ("Apps: started '{0}' (pid={1}, windowAfterStart={2})" -f $path, $started.Id, $policy)
            }
            return $true
        }
        catch {
            Write-AudioRebindLog ("Apps: start failed '{0}': {1}" -f $path, $_.Exception.Message) -Level ERROR
            return $false
        }
    }

    $name = $Entry.name
    Write-AudioRebindLog ("Apps: name-only entry '{0}' cannot Start-Process without path (soft-fail)" -f $name) -Level WARN
    return $true
}

function Initialize-AudioRebindWin32 {
    if ('AudioRebind.NativeMethods' -as [type]) { return }
    Add-Type -Namespace AudioRebind -Name NativeMethods -MemberDefinition @'
[System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential, CharSet = System.Runtime.InteropServices.CharSet.Unicode)]
public struct STARTUPINFO {
    public int cb;
    public string lpReserved;
    public string lpDesktop;
    public string lpTitle;
    public int dwX;
    public int dwY;
    public int dwXSize;
    public int dwYSize;
    public int dwXCountChars;
    public int dwYCountChars;
    public int dwFillAttribute;
    public int dwFlags;
    public short wShowWindow;
    public short cbReserved2;
    public System.IntPtr lpReserved2;
    public System.IntPtr hStdInput;
    public System.IntPtr hStdOutput;
    public System.IntPtr hStdError;
}

[System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential)]
public struct PROCESS_INFORMATION {
    public System.IntPtr hProcess;
    public System.IntPtr hThread;
    public int dwProcessId;
    public int dwThreadId;
}

[System.Runtime.InteropServices.DllImport("user32.dll")]
public static extern bool ShowWindowAsync(System.IntPtr hWnd, int nCmdShow);

[System.Runtime.InteropServices.DllImport("kernel32.dll", CharSet = System.Runtime.InteropServices.CharSet.Unicode, SetLastError = true)]
public static extern bool CreateProcess(
    string lpApplicationName,
    string lpCommandLine,
    System.IntPtr lpProcessAttributes,
    System.IntPtr lpThreadAttributes,
    bool bInheritHandles,
    uint dwCreationFlags,
    System.IntPtr lpEnvironment,
    string lpCurrentDirectory,
    ref STARTUPINFO lpStartupInfo,
    out PROCESS_INFORMATION lpProcessInformation);

[System.Runtime.InteropServices.DllImport("kernel32.dll", SetLastError = true)]
public static extern bool CloseHandle(System.IntPtr hObject);

public const int SW_SHOWMINNOACTIVE = 7;
public const int STARTF_USESHOWWINDOW = 0x00000001;
'@
}

function Start-AudioRebindProcessNoActivate {
    param(
        [Parameter(Mandatory = $true)]
        [string] $FilePath,

        [string] $WorkingDirectory = $null
    )

    Initialize-AudioRebindWin32

    $si = New-Object AudioRebind.NativeMethods+STARTUPINFO
    $si.cb = [Runtime.InteropServices.Marshal]::SizeOf([type][AudioRebind.NativeMethods+STARTUPINFO])
    $si.dwFlags = [AudioRebind.NativeMethods]::STARTF_USESHOWWINDOW
    $si.wShowWindow = [AudioRebind.NativeMethods]::SW_SHOWMINNOACTIVE

    $pi = New-Object AudioRebind.NativeMethods+PROCESS_INFORMATION

    # CreateProcess may write to the command-line buffer; pass a mutable StringBuilder-style string.
    $cmd = '"' + $FilePath + '"'
    $dir = $WorkingDirectory
    if ([string]::IsNullOrWhiteSpace($dir)) {
        $dir = $null
    }

    $ok = [AudioRebind.NativeMethods]::CreateProcess(
        $FilePath,
        $cmd,
        [IntPtr]::Zero,
        [IntPtr]::Zero,
        $false,
        [uint32]0,
        [IntPtr]::Zero,
        $dir,
        [ref]$si,
        [ref]$pi
    )

    if (-not $ok) {
        $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
        throw ("CreateProcess failed Win32Error={0} path='{1}'" -f $err, $FilePath)
    }

    try {
        return [int]$pi.dwProcessId
    }
    finally {
        if ($pi.hThread -ne [IntPtr]::Zero) { [void][AudioRebind.NativeMethods]::CloseHandle($pi.hThread) }
        if ($pi.hProcess -ne [IntPtr]::Zero) { [void][AudioRebind.NativeMethods]::CloseHandle($pi.hProcess) }
    }
}

function Set-AudioRebindWindowsMinimized {
    param(
        $Entry,
        [int] $TimeoutMs = 1200,
        [int] $NoWindowGiveUpMs = 400
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        Initialize-AudioRebindWin32
    }
    catch {
        Write-AudioRebindLog ("Apps: Win32 helper unavailable for minimize: {0}" -f $_.Exception.Message) -Level WARN
        return
    }

    if ($TimeoutMs -le 0) {
        Write-AudioRebindLog ("Apps: minimize skipped (minimizeTimeoutMs=0) path='{0}'" -f $Entry.path)
        return
    }

    $deadline = (Get-Date).AddMilliseconds($TimeoutMs)
    $noWindowDeadline = (Get-Date).AddMilliseconds([Math]::Min($NoWindowGiveUpMs, $TimeoutMs))
    $minimized = 0
    $sawWindow = $false
    $exitReason = 'timeout'

    while ((Get-Date) -lt $deadline) {
        $procs = @(Find-AudioRebindProcesses -Entry $Entry)
        foreach ($proc in $procs) {
            try {
                if ($proc.MainWindowHandle -ne [IntPtr]::Zero) {
                    $sawWindow = $true
                    if ([AudioRebind.NativeMethods]::ShowWindowAsync($proc.MainWindowHandle, [AudioRebind.NativeMethods]::SW_SHOWMINNOACTIVE)) {
                        $minimized++
                    }
                }
            }
            catch { }
        }

        if ($minimized -gt 0) {
            $exitReason = 'early-exit-minimized'
            break
        }

        if (-not $sawWindow -and (Get-Date) -ge $noWindowDeadline) {
            $exitReason = 'no-hwnd-give-up'
            break
        }

        Start-Sleep -Milliseconds 100
    }

    $sw.Stop()
    Write-AudioRebindLog ("Apps: minimize pass path='{0}' reason={1} successCount={2} elapsedMs={3}" -f $Entry.path, $exitReason, $minimized, $sw.ElapsedMilliseconds)
}

function Find-AudioRebindProcesses {
    param($Entry)

    $all = @(Get-Process -ErrorAction SilentlyContinue)
    $matched = @()
    $path = $Entry.path
    $name = $Entry.name

    foreach ($p in $all) {
        $hit = $false
        if (-not [string]::IsNullOrWhiteSpace($path)) {
            try {
                $pp = $p.Path
                if ($pp -and ($pp -ieq $path)) { $hit = $true }
            }
            catch { }
        }
        if (-not $hit -and -not [string]::IsNullOrWhiteSpace($name)) {
            if ($p.ProcessName -ieq [IO.Path]::GetFileNameWithoutExtension($name) -or
                $p.ProcessName -ieq $name -or
                ("{0}.exe" -f $p.ProcessName) -ieq $name) {
                $hit = $true
            }
        }
        if ($hit) { $matched += $p }
    }
    return $matched
}
