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
    $usb = Get-ProfileStepMap -Parent $steps -Name 'usbDevice'
    $apps = Get-ProfileStepMap -Parent $steps -Name 'apps'

    if ($null -eq $ae) {
        $steps['audioEngine'] = @{ enabled = $true }
        $ae = $steps['audioEngine']
    }
    if (-not $ae.ContainsKey('enabled')) { $ae['enabled'] = $true }

    if ($null -eq $usb) {
        $steps['usbDevice'] = @{ enabled = $false; hardwareIdPatterns = @() }
        $usb = $steps['usbDevice']
    }
    if (-not $usb.ContainsKey('enabled')) { $usb['enabled'] = $false }
    if (-not $usb.ContainsKey('hardwareIdPatterns')) { $usb['hardwareIdPatterns'] = @() }
    $usb['hardwareIdPatterns'] = @(ConvertTo-StringArray $usb['hardwareIdPatterns'])

    if ($null -eq $apps) {
        $steps['apps'] = @{
            enabled = $false
            processes = @()
            gracefulStopSeconds = 10
            forceStopSeconds = 5
        }
        $apps = $steps['apps']
    }
    if (-not $apps.ContainsKey('enabled')) { $apps['enabled'] = $false }
    if (-not $apps.ContainsKey('gracefulStopSeconds')) { $apps['gracefulStopSeconds'] = 10 }
    if (-not $apps.ContainsKey('forceStopSeconds')) { $apps['forceStopSeconds'] = 5 }
    if (-not $apps.ContainsKey('processes')) { $apps['processes'] = @() }
    $apps['processes'] = @(Normalize-ProcessEntries $apps['processes'])

    if ([bool]$usb.enabled) {
        if (@($usb.hardwareIdPatterns | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }).Count -eq 0) {
            throw "usbDevice.enabled is true but hardwareIdPatterns is empty: $SourcePath"
        }
    }

    if ([bool]$apps.enabled) {
        if (@($apps.processes).Count -eq 0) {
            throw "apps.enabled is true but processes is empty: $SourcePath"
        }
    }

    if (-not $Profile.ContainsKey('delays') -or $null -eq $Profile.delays) {
        $Profile['delays'] = @{
            afterAudioEngineMs = 2000
            afterUsbDeviceMs   = 2000
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
        if (-not $delays.ContainsKey('afterUsbDeviceMs')) { $delays['afterUsbDeviceMs'] = 2000 }
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

function ConvertTo-StringArray {
    param($Value)
    if ($null -eq $Value) { return @() }
    if ($Value -is [string]) { return @($Value) }
    $list = @()
    foreach ($item in @($Value)) {
        if ($null -ne $item -and -not [string]::IsNullOrWhiteSpace([string]$item)) {
            $list += [string]$item
        }
    }
    return $list
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
        $result += @{ path = $path; name = $name }
    }
    return $result
}
