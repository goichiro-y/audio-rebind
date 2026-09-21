<#
.SYNOPSIS
  Remove the AudioRebind resume scheduled task.

.PARAMETER TaskName
  Scheduled task name (default: AudioRebind-Resume).
#>
[CmdletBinding()]
param(
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
    Write-Error "Administrator elevation is required to unregister the task."
    exit 1
}

$existing = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if (-not $existing) {
    Write-Host "Task not found: $TaskName (nothing to do)"
    exit 0
}

Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
Write-Host "Unregistered task: $TaskName"
exit 0
