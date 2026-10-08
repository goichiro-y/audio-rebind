# Writes timestamped run logs under %LOCALAPPDATA%\AudioRebind\logs\

# Two threads append one file while stop overlaps AudioEngine (#39).
# The wait is finite so a stuck holder cannot keep a resume run out of AudioEngine (#48).
# A timed-out wait records that skip without the mutex (#50).
$script:AudioRebindLogMutexTimeoutMs = 500

function Initialize-AudioRebindLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string] $RunLabel = 'run'
    )

    $dir = Join-Path $env:LOCALAPPDATA 'AudioRebind\logs'
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $safeLabel = ($RunLabel -replace '[^\w\-]+', '_').Trim('_')
    if ([string]::IsNullOrWhiteSpace($safeLabel)) { $safeLabel = 'run' }
    # PID keeps a second start in the same second from replacing the first run's file (#49).
    $script:AudioRebindLogPath = Join-Path $dir ("{0}-{1}-{2}.log" -f $stamp, $PID, $safeLabel)

    $header = @(
        "AudioRebind log"
        "Started: $(Get-Date -Format o)"
        "Host: $env:COMPUTERNAME"
        "User: $env:USERNAME"
        "PSVersion: $($PSVersionTable.PSVersion)"
        "---"
    ) -join [Environment]::NewLine
    Set-Content -LiteralPath $script:AudioRebindLogPath -Value $header -Encoding UTF8
    return $script:AudioRebindLogPath
}

function Add-AudioRebindLogLine {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path,

        [Parameter(Mandatory = $true)]
        [string] $Line
    )

    $mutex = New-Object System.Threading.Mutex($false, 'Local\AudioRebindLog')
    $held = $false
    $timedOut = $false
    try {
        try {
            $held = $mutex.WaitOne($script:AudioRebindLogMutexTimeoutMs)
        }
        catch [System.Threading.AbandonedMutexException] {
            $held = $true
        }
        if ($held) {
            Add-Content -LiteralPath $Path -Value $Line -Encoding UTF8
        }
        else {
            $timedOut = $true
        }
    }
    finally {
        if ($held) { $mutex.ReleaseMutex() }
        $mutex.Dispose()
    }
    if ($timedOut) {
        $skip = '{0} [WARN] Log: mutex wait skipped' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
        Add-Content -LiteralPath $Path -Value $skip -Encoding UTF8
    }
}

function Write-AudioRebindLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Message,

        [ValidateSet('INFO', 'WARN', 'ERROR')]
        [string] $Level = 'INFO'
    )

    $line = '{0} [{1}] {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level, $Message
    if ($script:AudioRebindLogPath) {
        Add-AudioRebindLogLine -Path $script:AudioRebindLogPath -Line $line
    }
    switch ($Level) {
        'ERROR' { Write-Host $line -ForegroundColor Red }
        'WARN'  { Write-Warning $Message }
        default { Write-Host $line }
    }
}
