# Load and validate an AudioRebind YAML profile (Windows PowerShell 5.1 + powershell-yaml).

function Test-AudioRebindAdmin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($id)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Import-AudioRebindYamlModule {
    [CmdletBinding()]
    param()

    if (Get-Module -ListAvailable -Name powershell-yaml) {
        Import-Module powershell-yaml -ErrorAction Stop
        return
    }

    $hint = @(
        "Module 'powershell-yaml' is not installed."
        "Install for the current user (Windows PowerShell 5.1):"
        "  Install-Module powershell-yaml -Scope CurrentUser -Force"
        "Or re-run elevated Register-AudioRebindTask.ps1 (it installs the module when missing)."
        "Then re-run Invoke-AudioRebind.ps1."
    ) -join [Environment]::NewLine
    throw $hint
}

function Import-AudioRebindProfile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Profile not found: $Path"
    }

    Import-AudioRebindYamlModule

    $raw = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    $data = ConvertFrom-Yaml -Yaml $raw
    if ($null -eq $data) {
        throw "Profile YAML parsed to null: $Path"
    }

    # Normalize to hashtable for consistent access on PS 5.1
    if ($data -isnot [hashtable]) {
        $ht = @{}
        foreach ($p in $data.PSObject.Properties) {
            $ht[$p.Name] = $p.Value
        }
        $data = $ht
    }

    Assert-AudioRebindProfile -Profile $data -SourcePath $Path
    return $data
}

function Assert-AudioRebindProfile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Profile,

        [string] $SourcePath = ''
    )

    $allowedTop = @('name', 'description', 'steps', 'delays')
    foreach ($key in @($Profile.Keys)) {
        if ($allowedTop -notcontains $key) {
            throw "Unknown top-level key '$key' in profile $SourcePath (allowed: $($allowedTop -join ', '))"
        }
    }

    if (-not $Profile.ContainsKey('steps') -or $null -eq $Profile.steps) {
        throw "Profile missing 'steps': $SourcePath"
    }

    $steps = $Profile.steps
    if ($steps -isnot [hashtable]) {
        $sht = @{}
        foreach ($p in $steps.PSObject.Properties) { $sht[$p.Name] = $p.Value }
        $steps = $sht
        $Profile.steps = $steps
    }

    $ae = Get-ProfileStepMap -Parent $steps -Name 'audioEngine'
    $apps = Get-ProfileStepMap -Parent $steps -Name 'apps'

    if ($null -eq $ae) {
        $steps['audioEngine'] = @{ enabled = $true }
        $ae = $steps['audioEngine']
    }
    if (-not $ae.ContainsKey('enabled')) { $ae['enabled'] = $true }

    if ($null -eq $apps) {
        $steps['apps'] = @{
            enabled = $false
            processes = @()
            gracefulStopSeconds = 10
            forceStopSeconds = 5
            windowAfterStart = 'leave'
            minimizeTimeoutMs = 1200
            minimizeNoWindowGiveUpMs = 400
            stopMode = 'graceful-then-force'
            postStopDelayMs = 200
            postForceStopMs = 200
        }
        $apps = $steps['apps']
    }
    if (-not $apps.ContainsKey('enabled')) { $apps['enabled'] = $false }
    if (-not $apps.ContainsKey('gracefulStopSeconds')) { $apps['gracefulStopSeconds'] = 10 }
    if (-not $apps.ContainsKey('forceStopSeconds')) { $apps['forceStopSeconds'] = 5 }
    if (-not $apps.ContainsKey('minimizeTimeoutMs')) { $apps['minimizeTimeoutMs'] = 1200 }
    if (-not $apps.ContainsKey('minimizeNoWindowGiveUpMs')) { $apps['minimizeNoWindowGiveUpMs'] = 400 }
    if (-not $apps.ContainsKey('stopMode')) { $apps['stopMode'] = 'graceful-then-force' }
    else {
        $sm = ([string]$apps['stopMode']).Trim().ToLowerInvariant()
        if ($sm -notin @('graceful-then-force', 'force')) {
            throw "apps.stopMode must be 'graceful-then-force' or 'force' (got '$sm')."
        }
        $apps['stopMode'] = $sm
    }
    if (-not $apps.ContainsKey('postStopDelayMs')) { $apps['postStopDelayMs'] = 200 }
    if (-not $apps.ContainsKey('postForceStopMs')) { $apps['postForceStopMs'] = 200 }
    if (-not $apps.ContainsKey('windowAfterStart')) { $apps['windowAfterStart'] = 'leave' }
    else {
        $aw = ([string]$apps['windowAfterStart']).Trim().ToLowerInvariant()
        if ($aw -notin @('leave', 'minimize')) {
            throw "apps.windowAfterStart must be 'leave' or 'minimize' (got '$aw')."
        }
        $apps['windowAfterStart'] = $aw
    }
    if (-not $apps.ContainsKey('processes')) { $apps['processes'] = @() }
    $apps['processes'] = @(Normalize-ProcessEntries $apps['processes'])

    if ([bool]$apps.enabled) {
        if (@($apps.processes).Count -eq 0) {
            throw "apps.enabled is true but processes is empty: $SourcePath"
        }
    }

    if (-not $Profile.ContainsKey('delays') -or $null -eq $Profile.delays) {
        $Profile['delays'] = @{
            afterAudioEngineMs = 2000
            afterAppsMs        = 0
        }
    }
    else {
        $delays = $Profile.delays
        if ($delays -isnot [hashtable]) {
            $dht = @{}
            foreach ($p in $delays.PSObject.Properties) { $dht[$p.Name] = $p.Value }
            $delays = $dht
            $Profile.delays = $delays
        }
        if (-not $delays.ContainsKey('afterAudioEngineMs')) { $delays['afterAudioEngineMs'] = 2000 }
        if (-not $delays.ContainsKey('afterAppsMs')) { $delays['afterAppsMs'] = 0 }
    }

    if (-not $Profile.ContainsKey('name') -or [string]::IsNullOrWhiteSpace([string]$Profile.name)) {
        $Profile['name'] = [IO.Path]::GetFileNameWithoutExtension($SourcePath)
    }
}

function Get-ProfileStepMap {
    param($Parent, [string] $Name)
    if ($null -eq $Parent) { return $null }
    if ($Parent -is [hashtable]) {
        if (-not $Parent.ContainsKey($Name)) { return $null }
        $v = $Parent[$Name]
    }
    else {
        $prop = $Parent.PSObject.Properties[$Name]
        if (-not $prop) { return $null }
        $v = $prop.Value
    }
    if ($null -eq $v) { return $null }
    if ($v -is [hashtable]) { return $v }
    $ht = @{}
    foreach ($p in $v.PSObject.Properties) { $ht[$p.Name] = $p.Value }
    if ($Parent -is [hashtable]) { $Parent[$Name] = $ht }
    return $ht
}

function Normalize-ProcessEntries {
    param($Value)
    $result = @()
    if ($null -eq $Value) { return $result }
    foreach ($item in @($Value)) {
        if ($null -eq $item) { continue }
        $map = $null
        if ($item -is [hashtable]) {
            $map = $item
        }
        elseif ($item -is [string]) {
            $map = @{ path = $item }
        }
        else {
            $map = @{}
            foreach ($p in $item.PSObject.Properties) { $map[$p.Name] = $p.Value }
        }
        $path = $null
        $name = $null
        if ($map.ContainsKey('path')) { $path = [string]$map['path'] }
        if ($map.ContainsKey('name')) { $name = [string]$map['name'] }
        if ([string]::IsNullOrWhiteSpace($path) -and [string]::IsNullOrWhiteSpace($name)) {
            throw "Each apps.processes entry needs path and/or name."
        }
        $windowAfterStart = 'leave'
        if ($map.ContainsKey('windowAfterStart') -and -not [string]::IsNullOrWhiteSpace([string]$map['windowAfterStart'])) {
            $windowAfterStart = ([string]$map['windowAfterStart']).Trim().ToLowerInvariant()
        }
        if ($windowAfterStart -notin @('leave', 'minimize')) {
            throw "apps.processes.windowAfterStart must be 'leave' or 'minimize' (got '$windowAfterStart'). 'restore' is not implemented yet."
        }
        $result += @{ path = $path; name = $name; windowAfterStart = $windowAfterStart }
    }
    return $result
}
