<#
.SYNOPSIS
  Copy AudioRebind runtime to Program Files and seed LocalAppData profiles (ADR 0010).

.PARAMETER SourceRoot
  Optional path to a runtime folder that already contains Invoke-AudioRebind.ps1 and lib\.
  Default: this script's directory ($PSScriptRoot), i.e. repo src\ or an installed copy.

.PARAMETER InstallRoot
  Destination runtime root (default: %ProgramFiles%\AudioRebind).

.NOTES
  Requires administrator elevation.
  Ensures powershell-yaml for CurrentUser (setup-time only).
  Does not register the scheduled task — edit default.yaml, then run Register from InstallRoot.
#>
[CmdletBinding()]
param(
    [string] $SourceRoot,

    [string] $InstallRoot = (Join-Path $env:ProgramFiles 'AudioRebind')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-IsAdmin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-AudioRebindYamlModuleIfMissing {
    if (Get-Module -ListAvailable -Name powershell-yaml) {
        Write-Host "powershell-yaml: already available for CurrentUser"
        return
    }

    Write-Host "powershell-yaml: not found; installing with Install-Module -Scope CurrentUser ..."
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        Install-Module -Name powershell-yaml -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
    }
    catch {
        Write-Error @"
Failed to install module 'powershell-yaml' for CurrentUser.
$($_.Exception.Message)

Fix network / PSGallery access, then either re-run this script or:
  Install-Module powershell-yaml -Scope CurrentUser -Force
"@
        exit 1
    }

    if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
        Write-Error "Install-Module finished but 'powershell-yaml' is still not listed for this user."
        exit 1
    }
    Write-Host "powershell-yaml: installed for CurrentUser"
}

if (-not (Test-IsAdmin)) {
    Write-Error "Administrator elevation is required to install under Program Files."
    exit 1
}

if (-not $SourceRoot) {
    $SourceRoot = $PSScriptRoot
}
$SourceRoot = (Resolve-Path -LiteralPath $SourceRoot).Path

$invokeSrc = Join-Path $SourceRoot 'Invoke-AudioRebind.ps1'
$libSrc = Join-Path $SourceRoot 'lib'
if (-not (Test-Path -LiteralPath $invokeSrc)) {
    Write-Error "Missing entrypoint: $invokeSrc (pass -SourceRoot to a folder that contains Invoke-AudioRebind.ps1)."
    exit 1
}
if (-not (Test-Path -LiteralPath $libSrc)) {
    Write-Error "Missing lib folder: $libSrc"
    exit 1
}

Install-AudioRebindYamlModuleIfMissing

Write-Host "Installing runtime to: $InstallRoot"
New-Item -ItemType Directory -Force -Path $InstallRoot | Out-Null

$scriptNames = @(
    'Invoke-AudioRebind.ps1',
    'Register-AudioRebindTask.ps1',
    'Unregister-AudioRebindTask.ps1',
    'Install-AudioRebind.ps1',
    'Uninstall-AudioRebind.ps1'
)
foreach ($name in $scriptNames) {
    $from = Join-Path $SourceRoot $name
    if (Test-Path -LiteralPath $from) {
        Copy-Item -LiteralPath $from -Destination (Join-Path $InstallRoot $name) -Force
    }
}

$libDest = Join-Path $InstallRoot 'lib'
New-Item -ItemType Directory -Force -Path $libDest | Out-Null
Copy-Item -Path (Join-Path $libSrc '*') -Destination $libDest -Recurse -Force

# examples: prefer sibling profiles\examples (repo layout), else SourceRoot\examples (already installed)
$examplesDest = Join-Path $InstallRoot 'examples'
New-Item -ItemType Directory -Force -Path $examplesDest | Out-Null
$examplesCandidates = @(
    (Join-Path (Split-Path -Parent $SourceRoot) 'profiles\examples'),
    (Join-Path $SourceRoot 'examples')
)
$examplesSrc = $null
foreach ($c in $examplesCandidates) {
    if (Test-Path -LiteralPath $c) {
        $examplesSrc = $c
        break
    }
}
if ($examplesSrc) {
    Copy-Item -Path (Join-Path $examplesSrc '*') -Destination $examplesDest -Recurse -Force
    Write-Host "examples: copied from $examplesSrc"
}
else {
    Write-Host "examples: no source found (skip); seed profile may be missing"
}

$userRoot = Join-Path $env:LOCALAPPDATA 'AudioRebind'
$profilesDir = Join-Path $userRoot 'profiles'
$logsDir = Join-Path $userRoot 'logs'
New-Item -ItemType Directory -Force -Path $profilesDir | Out-Null
New-Item -ItemType Directory -Force -Path $logsDir | Out-Null

$defaultProfile = Join-Path $profilesDir 'default.yaml'
$seedFrom = Join-Path $examplesDest 'example-usb-interface.yaml'
if (-not (Test-Path -LiteralPath $defaultProfile)) {
    if (Test-Path -LiteralPath $seedFrom) {
        Copy-Item -LiteralPath $seedFrom -Destination $defaultProfile -Force
        Write-Host "Seeded profile (placeholders): $defaultProfile"
    }
    else {
        Write-Host "WARNING: could not seed default.yaml (missing $seedFrom)"
    }
}
else {
    Write-Host "Profile already present (not overwritten): $defaultProfile"
}

Write-Host ""
Write-Host "Install complete."
Write-Host "  Runtime:  $InstallRoot"
Write-Host "  Profiles: $profilesDir"
Write-Host "  Logs:     $logsDir"
Write-Host ""
Write-Host "Next:"
Write-Host "  1. Edit $defaultProfile (fill VID/PID and app path; see checklist in the file)."
Write-Host "  2. Elevated: & '$InstallRoot\Register-AudioRebindTask.ps1'"
Write-Host "     (defaults to default.yaml under LocalAppData)"
exit 0
