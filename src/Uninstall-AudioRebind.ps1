<#
.SYNOPSIS
  Remove the AudioRebind scheduled task and Program Files runtime (ADR 0010).

.PARAMETER InstallRoot
  Runtime root to remove (default: %ProgramFiles%\AudioRebind).

.PARAMETER TaskName
  Scheduled task name (default: AudioRebind-Resume).

.PARAMETER RemoveUserData
  Also delete %LOCALAPPDATA%\AudioRebind (profiles, logs, stamps). Off by default.

.NOTES
  Requires administrator elevation.
#>
[CmdletBinding()]
param(
    [string] $InstallRoot = (Join-Path $env:ProgramFiles 'AudioRebind'),

    [string] $TaskName = 'AudioRebind-Resume',

    [switch] $RemoveUserData
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-IsAdmin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
    Write-Error "Administrator elevation is required to uninstall."
    exit 1
}

$existing = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($existing) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    Write-Host "Unregistered task: $TaskName"
}
else {
    Write-Host "Task not found: $TaskName (nothing to do)"
}

if (Test-Path -LiteralPath $InstallRoot) {
    Remove-Item -LiteralPath $InstallRoot -Recurse -Force
    Write-Host "Removed runtime: $InstallRoot"
}
else {
    Write-Host "Runtime not found: $InstallRoot (nothing to do)"
}

$userRoot = Join-Path $env:LOCALAPPDATA 'AudioRebind'
if ($RemoveUserData) {
    if (Test-Path -LiteralPath $userRoot) {
        Remove-Item -LiteralPath $userRoot -Recurse -Force
        Write-Host "Removed user data: $userRoot"
    }
    else {
        Write-Host "User data not found: $userRoot"
    }
}
else {
    Write-Host "Kept user data (profiles/logs): $userRoot"
    Write-Host "  Pass -RemoveUserData to delete LocalAppData\AudioRebind as well."
}

exit 0
