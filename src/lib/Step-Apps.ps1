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

    $processes = @($StepConfig.processes)
    Write-AudioRebindLog ("Apps: {0} process entr(y/ies); graceful={1}s force={2}s" -f $processes.Count, $gracefulSec, $forceSec)

    if ($WhatIf) {
        foreach ($entry in $processes) {
            Write-AudioRebindLog ("Apps: WhatIf would recycle path='{0}' name='{1}'" -f $entry.path, $entry.name)
        }
        return $true
    }

    # Stop in reverse order (helpers before main when listed main-first is common — stop all matching)
    foreach ($entry in $processes) {
        Stop-AudioRebindProcessEntry -Entry $entry -GracefulSeconds $gracefulSec -ForceSeconds $forceSec
    }

    Start-Sleep -Seconds 1

    $ok = $true
    foreach ($entry in $processes) {
        if (-not (Start-AudioRebindProcessEntry -Entry $entry)) {
            $ok = $false
        }
    }
    return $ok
}

function Stop-AudioRebindProcessEntry {
    param($Entry, [int] $GracefulSeconds, [int] $ForceSeconds)

    $targets = @(Find-AudioRebindProcesses -Entry $Entry)
    if ($targets.Count -eq 0) {
        Write-AudioRebindLog ("Apps: no running process for path='{0}' name='{1}'" -f $Entry.path, $Entry.name)
        return
    }

    foreach ($p in $targets) {
        Write-AudioRebindLog ("Apps: stopping pid={0} name='{1}'" -f $p.Id, $p.ProcessName)
        try {
            $null = $p.CloseMainWindow()
        }
        catch { }
    }

    $deadline = (Get-Date).AddSeconds($GracefulSeconds)
    while ((Get-Date) -lt $deadline) {
        $left = @(Find-AudioRebindProcesses -Entry $Entry)
        if ($left.Count -eq 0) { break }
        Start-Sleep -Milliseconds 400
    }

    $left = @(Find-AudioRebindProcesses -Entry $Entry)
    if ($left.Count -gt 0) {
        Write-AudioRebindLog ("Apps: force-stopping {0} process(es)" -f $left.Count) -Level WARN
        foreach ($p in $left) {
            try {
                Stop-Process -Id $p.Id -Force -ErrorAction Stop
            }
            catch {
                Write-AudioRebindLog ("Apps: force-stop failed pid={0}: {1}" -f $p.Id, $_.Exception.Message) -Level WARN
            }
        }
        Start-Sleep -Seconds ([Math]::Max(1, $ForceSeconds))
    }
}

function Start-AudioRebindProcessEntry {
    param($Entry)

    $path = $Entry.path
    if (-not [string]::IsNullOrWhiteSpace($path)) {
        if (-not (Test-Path -LiteralPath $path)) {
            Write-AudioRebindLog ("Apps: start path missing: {0}" -f $path) -Level ERROR
            return $false
        }
        try {
            Start-Process -FilePath $path -ErrorAction Stop | Out-Null
            Write-AudioRebindLog ("Apps: started '{0}'" -f $path)
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
