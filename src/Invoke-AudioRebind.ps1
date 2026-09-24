<#
.SYNOPSIS
  Run the AudioRebind resume pipeline against a YAML profile.

.PARAMETER ProfilePath
  Path to a profile .yaml / .yml file.

.PARAMETER WhatIf
  Log planned steps without restarting services or recycling apps.

.NOTES
  Requires Windows PowerShell 5.1, administrator elevation, and module powershell-yaml.
  See src/README.md.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $ProfilePath,

    [switch] $WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$exitCode = 0
$libRoot = Join-Path $PSScriptRoot 'lib'

. (Join-Path $libRoot 'Write-AudioRebindLog.ps1')
. (Join-Path $libRoot 'Test-AudioRebindAdmin.ps1')
. (Join-Path $libRoot 'Import-AudioRebindProfile.ps1')
. (Join-Path $libRoot 'Step-AudioEngine.ps1')
. (Join-Path $libRoot 'Step-Apps.ps1')

function Get-DelayMs {
    param($Delays, [string] $Key, [int] $Default)
    if ($null -eq $Delays) { return $Default }
    if ($Delays -is [hashtable] -and $Delays.ContainsKey($Key) -and $null -ne $Delays[$Key]) {
        return [int]$Delays[$Key]
    }
    return $Default
}

# Dual Task Scheduler triggers (Event ID 1 + Kernel-Power 107) can fire on one resume.
# IgnoreNew covers overlap while a run is live; this stamp covers near-sequential starts (#22).
$script:AudioRebindDebounceSeconds = 120

function Get-AudioRebindDebounceStampPath {
    return (Join-Path $env:LOCALAPPDATA 'AudioRebind\last-run.stamp')
}

function Test-AudioRebindRecentRun {
    param([int] $WindowSeconds = $script:AudioRebindDebounceSeconds)
    $path = Get-AudioRebindDebounceStampPath
    if (-not (Test-Path -LiteralPath $path)) { return $false }
    $age = (Get-Date) - (Get-Item -LiteralPath $path).LastWriteTime
    return ($age.TotalSeconds -lt $WindowSeconds)
}

function Set-AudioRebindDebounceStamp {
    $dir = Join-Path $env:LOCALAPPDATA 'AudioRebind'
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $path = Get-AudioRebindDebounceStampPath
    Set-Content -LiteralPath $path -Value (Get-Date -Format o) -Encoding ASCII
}

$script:AudioRebindStopOverlap = $null

try {
    $resolvedProfile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ProfilePath)
    if (-not (Test-Path -LiteralPath $resolvedProfile)) {
        Write-Error "Profile not found: $resolvedProfile"
        exit 1
    }

    if (-not (Test-AudioRebindAdmin)) {
        Write-Error "Administrator elevation is required (restart services / PnP). Re-run from an elevated Windows PowerShell 5.1 prompt."
        exit 1
    }

    $profile = Import-AudioRebindProfile -Path $resolvedProfile
    $logPath = Initialize-AudioRebindLog -RunLabel ([string]$profile.name)
    Write-AudioRebindLog ("Profile: {0} ({1})" -f $profile.name, $resolvedProfile)
    Write-AudioRebindLog ("LogFile: {0}" -f $logPath)
    if ($WhatIf) {
        Write-AudioRebindLog "Mode: WhatIf"
    }
    elseif (Test-AudioRebindRecentRun) {
        Write-AudioRebindLog ("Debounce: skipping pipeline (run within last {0}s; dual-trigger overlap)" -f $script:AudioRebindDebounceSeconds)
        Write-AudioRebindLog "Finished exitCode=0"
        exit 0
    }
    else {
        Set-AudioRebindDebounceStamp
    }

    $steps = $profile.steps
    $delays = $profile.delays
    $requiredFailed = $false

    $apps = $steps.apps
    $appsEnabled = $false
    if ($apps -is [hashtable] -and $apps.ContainsKey('enabled')) { $appsEnabled = [bool]$apps.enabled }

    # --- AudioEngine (required when enabled; default enabled) ---
    # App stop overlaps this restart. App start stays after success and afterAudioEngineMs (#39).
    $ae = $steps.audioEngine
    $aeEnabled = $true
    if ($ae -is [hashtable] -and $ae.ContainsKey('enabled')) { $aeEnabled = [bool]$ae.enabled }

    if ($appsEnabled -and $aeEnabled) {
        if ($WhatIf) {
            Invoke-AudioRebindApps -StepConfig $apps -Phase Stop -WhatIf | Out-Null
        }
        else {
            Write-AudioRebindLog "Apps: stop overlaps AudioEngine"
            $script:AudioRebindStopOverlap = Start-AudioRebindAppsStopOverlap -StepConfig $apps -LogPath $script:AudioRebindLogPath
        }
    }

    if ($aeEnabled) {
        $ok = Invoke-AudioRebindAudioEngine -WhatIf:$WhatIf
        if (-not $ok) {
            Write-AudioRebindLog "AudioEngine: REQUIRED step failed — aborting later steps" -Level ERROR
            $requiredFailed = $true
            $exitCode = 2
        }
        else {
            $ms = Get-DelayMs $delays 'afterAudioEngineMs' 2000
            if ($ms -gt 0) {
                Write-AudioRebindLog ("Delay afterAudioEngineMs={0}" -f $ms)
                if (-not $WhatIf) {
                    Start-Sleep -Milliseconds $ms
                }
            }
        }
    }
    else {
        Write-AudioRebindLog "AudioEngine: disabled in profile"
    }

    # --- Apps start (optional). Stop already ran when it overlapped the engine. ---
    if ($requiredFailed) {
        if ($null -ne $script:AudioRebindStopOverlap) {
            Complete-AudioRebindAppsStopOverlap | Out-Null
        }
        if ($appsEnabled) {
            Write-AudioRebindLog "Apps: start skipped because AudioEngine failed" -Level ERROR
        }
    }
    elseif ($appsEnabled) {
        $ok = $true
        if ($null -ne $script:AudioRebindStopOverlap) {
            $ok = Complete-AudioRebindAppsStopOverlap
            if ($ok) {
                $ok = Invoke-AudioRebindApps -StepConfig $apps -Phase Start -WhatIf:$WhatIf
            }
            else {
                Write-AudioRebindLog "Apps: start skipped because stop failed" -Level WARN
            }
        }
        elseif ($WhatIf -and $aeEnabled) {
            $ok = Invoke-AudioRebindApps -StepConfig $apps -Phase Start -WhatIf
        }
        else {
            $ok = Invoke-AudioRebindApps -StepConfig $apps -WhatIf:$WhatIf
        }
        if (-not $ok) {
            Write-AudioRebindLog "Apps: step reported failure (optional — continuing)" -Level WARN
        }
        $ms = Get-DelayMs $delays 'afterAppsMs' 0
        if (-not $WhatIf -and $ms -gt 0) {
            Write-AudioRebindLog ("Delay afterAppsMs={0}" -f $ms)
            Start-Sleep -Milliseconds $ms
        }
    }
    else {
        Write-AudioRebindLog "Apps: disabled in profile"
    }

    Write-AudioRebindLog ("Finished exitCode={0}" -f $exitCode)
}
catch {
    try {
        Complete-AudioRebindAppsStopOverlap | Out-Null
    }
    catch { }
    $exitCode = 3
    $msg = $_.Exception.Message
    if ($msg -match 'powershell-yaml' -or $msg -match 'Unknown top-level' -or $msg -match 'Profile' -or $msg -match 'processes') {
        $exitCode = 1
    }
    try {
        if (-not $script:AudioRebindLogPath) {
            Initialize-AudioRebindLog -RunLabel 'error' | Out-Null
        }
        Write-AudioRebindLog $msg -Level ERROR
    }
    catch {
        Write-Error $msg
    }
}

exit $exitCode
