<#
.SYNOPSIS
  Elevate once, run Install, then register the Program Files scheduled task.

.NOTES
  Launched by Install-AudioRebind.cmd at the repository root.
  Not copied to Program Files. Does not change the machine ExecutionPolicy.
  Declining elevation shows a dialog and does not install or register.
  Other setup failures show a dialog with the reason and what to do next (#35).
  Success shows a completion dialog and does not wait for Enter (#38).
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

function Show-SetupFinishedDialog {
    Show-AudioRebindNotice -Code 'SETUP-4HNW' -Icon Information
}

function Show-AdminRequiredDialog {
    Show-AudioRebindNotice -Code 'SETUP-8CQT' -Icon Information
}

$powershellExe = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
. (Join-Path $PSScriptRoot 'lib\Show-AudioRebindSetupFailure.ps1')

function Invoke-AudioRebindCapturedScript {
    param(
        [string] $ScriptPath,
        [string] $FallbackKind
    )

    $previous = $env:AUDIOREBIND_SETUP_CAPTURE
    $env:AUDIOREBIND_SETUP_CAPTURE = '1'
    try {
        $lines = @(& $powershellExe -NoProfile -ExecutionPolicy Bypass -File $ScriptPath 2>&1 | ForEach-Object { "$_" })
        $code = $LASTEXITCODE
    }
    finally {
        if ([string]::IsNullOrEmpty($previous)) {
            Remove-Item Env:AUDIOREBIND_SETUP_CAPTURE -ErrorAction SilentlyContinue
        }
        else {
            $env:AUDIOREBIND_SETUP_CAPTURE = $previous
        }
    }

    if ($code -ne 0) {
        $text = ($lines -join [Environment]::NewLine).Trim()
        $kind = Get-AudioRebindSetupFailureKind -Text $text
        if ($kind -eq 'Other') { $kind = $FallbackKind }
        Show-AudioRebindSetupFailure -Kind $kind
        if ($null -eq $code) { exit 1 }
        exit $code
    }
}

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
        Write-Output $_.Exception.Message
        Show-AudioRebindSetupFailure -Kind Other
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
Invoke-AudioRebindCapturedScript -ScriptPath $installScript -FallbackKind ProgramFiles

$registerScript = Join-Path $env:ProgramFiles 'AudioRebind\Register-AudioRebindTask.ps1'
if (-not (Test-Path -LiteralPath $registerScript)) {
    $detail = "Installed Register script not found: $registerScript"
    Write-Output $detail
    Show-AudioRebindSetupFailure -Kind Task
    exit 1
}

Invoke-AudioRebindCapturedScript -ScriptPath $registerScript -FallbackKind Task

Show-SetupFinishedDialog
exit 0
