# Writes timestamped run logs under %LOCALAPPDATA%\AudioRebind\logs\

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
    $script:AudioRebindLogPath = Join-Path $dir ("{0}-{1}.log" -f $stamp, $safeLabel)

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
        Add-Content -LiteralPath $script:AudioRebindLogPath -Value $line -Encoding UTF8
    }
    switch ($Level) {
        'ERROR' { Write-Host $line -ForegroundColor Red }
        'WARN'  { Write-Warning $Message }
        default { Write-Host $line }
    }
}
