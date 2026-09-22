<#
.SYNOPSIS
  Register an elevated Task Scheduler task that runs AudioRebind on resume.

.PARAMETER ProfilePath
  Profile YAML path. Relative paths are resolved against the current location.
  When omitted, defaults to %LOCALAPPDATA%\AudioRebind\profiles\default.yaml (ADR 0010).

.PARAMETER TaskName
  Scheduled task name (default: AudioRebind-Resume).

.NOTES
  Requires administrator elevation.
  Ensures module powershell-yaml is installed for CurrentUser when missing (setup-time only).
  Runs as the registering user with highest privileges (so CurrentUser modules like powershell-yaml resolve).
  Entrypoint is always $PSScriptRoot\Invoke-AudioRebind.ps1 (Program Files after Install, or repo src\ for dev).
  Triggers (ADR 0005 / #22):
    - Microsoft-Windows-Power-Troubleshooter Event ID 1 (primary)
    - Microsoft-Windows-Kernel-Power Event ID 107 (fallback when ID 1 is missing)
  MultipleInstancesPolicy=IgnoreNew; Invoke-AudioRebind also debounce-skips near-duplicate starts.
#>
[CmdletBinding()]
param(
    [string] $ProfilePath,

    [string] $TaskName = 'AudioRebind-Resume'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-IsAdmin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
    Write-Error "Administrator elevation is required to register the task."
    exit 1
}

# Setup-time only: ensure CurrentUser can load YAML (scheduled task runs as this user).
function Install-AudioRebindYamlModuleIfMissing {
    if (Get-Module -ListAvailable -Name powershell-yaml) {
        Write-Host "powershell-yaml: already available for CurrentUser"
        return
    }

    Write-Host "powershell-yaml: not found; installing with Install-Module -Scope CurrentUser ..."
    try {
        # PS 5.1 + PSGallery often needs TLS 1.2
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

Install-AudioRebindYamlModuleIfMissing

$invokePath = Join-Path $PSScriptRoot 'Invoke-AudioRebind.ps1'
if (-not (Test-Path -LiteralPath $invokePath)) {
    Write-Error "Missing entrypoint: $invokePath"
    exit 1
}
$invokePath = (Resolve-Path -LiteralPath $invokePath).Path

if (-not $ProfilePath) {
    $ProfilePath = Join-Path $env:LOCALAPPDATA 'AudioRebind\profiles\default.yaml'
    Write-Host "ProfilePath omitted; using $ProfilePath"
}

if (-not (Test-Path -LiteralPath $ProfilePath)) {
    Write-Error @"
Profile not found: $ProfilePath

Run Install-AudioRebind.ps1 first (seeds default.yaml), or pass -ProfilePath explicitly.
"@
    exit 1
}
$profileAbs = (Resolve-Path -LiteralPath $ProfilePath).Path

$userId = [Security.Principal.WindowsIdentity]::GetCurrent().Name
$powershellExe = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$arg = '-NoProfile -ExecutionPolicy Bypass -File "{0}" -ProfilePath "{1}"' -f $invokePath, $profileAbs

$queryPowerTroubleshooter1 = @'
<QueryList><Query Id="0" Path="System"><Select Path="System">*[System[Provider[@Name='Microsoft-Windows-Power-Troubleshooter'] and (EventID=1)]]</Select></Query></QueryList>
'@

$queryKernelPower107 = @'
<QueryList><Query Id="0" Path="System"><Select Path="System">*[System[Provider[@Name='Microsoft-Windows-Kernel-Power'] and (EventID=107)]]</Select></Query></QueryList>
'@

function Escape-Xml([string] $s) {
    if ($null -eq $s) { return '' }
    return ($s -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' -replace '"', '&quot;')
}

$xml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>AudioRebind: resume pipeline on Power-Troubleshooter Event ID 1 or Kernel-Power Event ID 107</Description>
    <Author>$([System.Security.SecurityElement]::Escape($userId))</Author>
  </RegistrationInfo>
  <Triggers>
    <EventTrigger>
      <Enabled>true</Enabled>
      <Subscription>$(Escape-Xml $queryPowerTroubleshooter1)</Subscription>
    </EventTrigger>
    <EventTrigger>
      <Enabled>true</Enabled>
      <Subscription>$(Escape-Xml $queryKernelPower107)</Subscription>
    </EventTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>$(Escape-Xml $userId)</UserId>
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT1H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>$(Escape-Xml $powershellExe)</Command>
      <Arguments>$(Escape-Xml $arg)</Arguments>
    </Exec>
  </Actions>
</Task>
"@

Register-ScheduledTask -TaskName $TaskName -Xml $xml -Force | Out-Null

$task = Get-ScheduledTask -TaskName $TaskName -ErrorAction Stop
Write-Host "Registered task: $($task.TaskName) State=$($task.State)"
Write-Host "  Entrypoint: $invokePath"
Write-Host "  Profile:    $profileAbs"
Write-Host "  Run as:     $userId (InteractiveToken, HighestAvailable)"
Write-Host "  Triggers:   System / Microsoft-Windows-Power-Troubleshooter / EventID=1"
Write-Host "              System / Microsoft-Windows-Kernel-Power / EventID=107 (fallback)"
Write-Host "  Overlap:    MultipleInstancesPolicy=IgnoreNew; Invoke debounce ~120s"
exit 0
