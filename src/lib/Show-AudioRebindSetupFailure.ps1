# Setup notices (#35, #40). One row is English, Japanese, and a stable code.
# Prefixes: SETUP (rows below), REBIND (pipeline, no rows yet), SETTINGS (no rows yet).
# Do not reuse a code. Do not copy these sentences into another list.

$AudioRebindNotices = @{
    'SETUP-4HNW' = @{
        En = 'Installation complete.'
        Ja = 'インストールが完了しました。'
    }
    'SETUP-8CQT' = @{
        En = 'Administrator permission is required. The scheduled task was not registered.'
        Ja = '管理者権限が必要です。タスクは登録していません。'
    }
    'SETUP-K7PM' = @{
        En = "Windows blocked the script.`r`nDouble-click Install-AudioRebind.cmd again."
        Ja = "スクリプトが止まりました。`r`nもう一度、Install-AudioRebind.cmd をダブルクリックしてください。"
    }
    'SETUP-2RVD' = @{
        En = "powershell-yaml could not be installed.`r`nDouble-click Install-AudioRebind.cmd again."
        Ja = "powershell-yaml を入れられませんでした。`r`nもう一度、Install-AudioRebind.cmd をダブルクリックしてください。"
    }
    'SETUP-9MFK' = @{
        En = "Setup could not write under Program Files. Administrator permission is required.`r`nDouble-click Install-AudioRebind.cmd again."
        Ja = "Program Files に書けませんでした。管理者の許可が必要です。`r`nもう一度、Install-AudioRebind.cmd をダブルクリックしてください。"
    }
    'SETUP-HW3C' = @{
        En = "The scheduled task was not registered.`r`nDouble-click Install-AudioRebind.cmd again."
        Ja = "タスクを登録できませんでした。`r`nもう一度、Install-AudioRebind.cmd をダブルクリックしてください。"
    }
    'SETUP-5BJY' = @{
        En = "Setup did not finish.`r`nDouble-click Install-AudioRebind.cmd again."
        Ja = "導入を完了できませんでした。`r`nもう一度、Install-AudioRebind.cmd をダブルクリックしてください。"
    }
}

function Get-AudioRebindNoticeText {
    param([string] $Code)

    $row = $AudioRebindNotices[$Code]
    if ($null -eq $row) {
        return $Code
    }
    return (($row.En, '', $row.Ja, '', $Code) -join [Environment]::NewLine)
}

function Show-AudioRebindNotice {
    param(
        [string] $Code,
        [ValidateSet('Error', 'Information')]
        [string] $Icon = 'Error'
    )

    Add-Type -AssemblyName System.Windows.Forms
    $boxIcon = [System.Windows.Forms.MessageBoxIcon]::Error
    if ($Icon -eq 'Information') {
        $boxIcon = [System.Windows.Forms.MessageBoxIcon]::Information
    }
    [void][System.Windows.Forms.MessageBox]::Show(
        (Get-AudioRebindNoticeText -Code $Code),
        'AudioRebind',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        $boxIcon
    )
}

function Get-AudioRebindSetupFailureKind {
    param([string] $Text)

    if ([string]::IsNullOrWhiteSpace($Text)) { return 'Other' }
    if ($Text -match 'execution policy|ExecutionPolicy|PSSecurityException|running scripts is disabled|スクリプトの実行が無効|実行ポリシー') {
        return 'Policy'
    }
    if ($Text -match 'powershell-yaml') { return 'Module' }
    if ($Text -match 'required to register|Register-ScheduledTask|Register script not found|task registration') {
        return 'Task'
    }
    if ($Text -match 'required to install|Program Files|Access is denied|UnauthorizedAccess|アクセスが拒否') {
        return 'ProgramFiles'
    }
    return 'Other'
}

function Show-AudioRebindSetupFailure {
    param(
        [string] $Kind = 'Other'
    )

    switch ($Kind) {
        'Policy' { $code = 'SETUP-K7PM' }
        'Module' { $code = 'SETUP-2RVD' }
        'ProgramFiles' { $code = 'SETUP-9MFK' }
        'Task' { $code = 'SETUP-HW3C' }
        default { $code = 'SETUP-5BJY' }
    }
    Show-AudioRebindNotice -Code $code -Icon 'Error'
}

function Exit-AudioRebindSetupFailure {
    param(
        [string] $Kind = 'Other',
        [string] $Detail = '',
        [int] $Code = 1
    )

    if (-not [string]::IsNullOrWhiteSpace($Detail)) {
        Write-Output $Detail
    }
    if ($env:AUDIOREBIND_SETUP_CAPTURE -ne '1') {
        Show-AudioRebindSetupFailure -Kind $Kind
    }
    exit $Code
}
