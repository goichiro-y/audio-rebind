<#
.SYNOPSIS
  Register an elevated Task Scheduler task that runs AudioRebind on resume.

.PARAMETER ProfilePath
  Profile YAML path. Relative paths are resolved against the current location.

.PARAMETER TaskName
  Scheduled task name (default: AudioRebind-Resume).

.NOTES
  Requires administrator elevation.
  Runs as the registering user with highest privileges (so CurrentUser modules like powershell-yaml resolve).
  Trigger: Microsoft-Windows-Power-Troubleshooter Event ID 1 (ADR 0005).
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
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

$invokePath = Join-Path $PSScriptRoot 'Invoke-AudioRebind.ps1'
if (-not (Test-Path -LiteralPath $invokePath)) {
    Write-Error "Missing entrypoint: $invokePath"
    exit 1
}
$invokePath = (Resolve-Path -LiteralPath $invokePath).Path

if (-not (Test-Path -LiteralPath $ProfilePath)) {
    Write-Error "Profile not found: $ProfilePath"
    exit 1
}
$profileAbs = (Resolve-Path -LiteralPath $ProfilePath).Path

$userId = [Security.Principal.WindowsIdentity]::GetCurrent().Name
$powershellExe = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$arg = '-NoProfile -ExecutionPolicy Bypass -File "{0}" -ProfilePath "{1}"' -f $invokePath, $profileAbs

$query = @'
<QueryList><Query Id="0" Path="System"><Select Path="System">*[System[Provider[@Name='Microsoft-Windows-Power-Troubleshooter'] and (EventID=1)]]</Select></Query></QueryList>
'@

function Escape-Xml([string] $s) {
    if ($null -eq $s) { return '' }
    return ($s -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' -replace '"', '&quot;')
}

$xml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>AudioRebind: run resume pipeline on Power-Troubleshooter Event ID 1</Description>
    <Author>$([System.Security.SecurityElement]::Escape($userId))</Author>
  </RegistrationInfo>
  <Triggers>
    <EventTrigger>
      <Enabled>true</Enabled>
      <Subscription>$(Escape-Xml $query)</Subscription>
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
Write-Host "  Trigger:    System / Microsoft-Windows-Power-Troubleshooter / EventID=1"
exit 0
