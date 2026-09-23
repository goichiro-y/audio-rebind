<#
.SYNOPSIS
  Elevate once, run Install, then register the Program Files scheduled task.

.NOTES
  Launched by Install-AudioRebind.cmd at the repository root.
  Not copied to Program Files. Does not change the machine ExecutionPolicy.
  Declining elevation shows a dialog and does not install or register.
  Setup-failure dialogs (execution policy, powershell-yaml, Program Files write,
  task registration) are out of scope here.
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-IsAdmin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-IsElevationDeclined {
    param($ErrorRecord)

    # Windows localizes this text. Compare against that string so ja-JP and en-US both match.
    $canceled = [string](New-Object System.ComponentModel.Win32Exception 1223).Message

    $ex = $ErrorRecord.Exception
    while ($null -ne $ex) {
        $win32 = $ex -as [System.ComponentModel.Win32Exception]
        if ($null -ne $win32 -and $win32.NativeErrorCode -eq 1223) {
            return $true
        }
        if (-not [string]::IsNullOrEmpty($canceled) -and ([string]$ex.Message).Contains($canceled)) {
            return $true
        }
        $ex = $ex.InnerException
    }

    return $false
}

function Show-AdminRequiredDialog {
    Add-Type -AssemblyName System.Windows.Forms
    $text = @(
        '管理者権限が必要です。タスクは登録していません。'
        'Administrator permission is required. The scheduled task was not registered.'
    ) -join "`r`n"
    [void][System.Windows.Forms.MessageBox]::Show(
        $text,
        'AudioRebind',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )
}

$powershellExe = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'

if (-not (Test-IsAdmin)) {
    $quotedPath = $PSCommandPath.Replace('"', '""')
    $arg = '-NoProfile -ExecutionPolicy Bypass -File "{0}"' -f $quotedPath
    try {
        # -Verb RunAs -Wait can return before the user answers UAC. Wait on the process handle
        # so a decline still reaches the dialog below.
        $proc = Start-Process -FilePath $powershellExe -Verb RunAs -PassThru -ArgumentList $arg
    }
    catch {
        if (Test-IsElevationDeclined $_) {
            Show-AdminRequiredDialog
            exit 1
        }
        Write-Error -ErrorRecord $_
        exit 1
    }

    if ($null -eq $proc) {
        Show-AdminRequiredDialog
        exit 1
    }

    $null = $proc.Handle
    $proc.WaitForExit()
    if ($null -eq $proc.ExitCode) {
        exit 1
    }
    exit $proc.ExitCode
}

$installScript = Join-Path $PSScriptRoot 'Install-AudioRebind.ps1'
& $powershellExe -NoProfile -ExecutionPolicy Bypass -File $installScript
if ($LASTEXITCODE -ne 0) {
    if ($null -eq $LASTEXITCODE) { exit 1 }
    exit $LASTEXITCODE
}

$registerScript = Join-Path $env:ProgramFiles 'AudioRebind\Register-AudioRebindTask.ps1'
if (-not (Test-Path -LiteralPath $registerScript)) {
    Write-Error "Installed Register script not found: $registerScript"
    exit 1
}

& $powershellExe -NoProfile -ExecutionPolicy Bypass -File $registerScript
if ($LASTEXITCODE -ne 0) {
    if ($null -eq $LASTEXITCODE) { exit 1 }
    exit $LASTEXITCODE
}

$defaultProfile = Join-Path $env:LOCALAPPDATA 'AudioRebind\profiles\default.yaml'
Write-Host ''
Write-Host 'Setup finished.'
Write-Host "  Runtime: $env:ProgramFiles\AudioRebind"
Write-Host "  Task profile (edit this; read on each resume): $defaultProfile"
Write-Host ''
Write-Host 'Press Enter to close.'
[void](Read-Host)
exit 0
