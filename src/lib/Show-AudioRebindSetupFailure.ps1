# Dialog for setup failures (#35). Japanese first, then English. No machine paths.

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
        [string] $Kind = 'Other',
        [string] $Detail = ''
    )

    $detail = ([string]$Detail).Trim()
    if ($detail.Length -gt 700) {
        $detail = $detail.Substring(0, 700) + '...'
    }
    if ([string]::IsNullOrWhiteSpace($detail)) {
        $detail = '導入スクリプトが理由を残さずに終了しました。 / The setup script exited without a reason.'
    }

    $next = @(
        'もう一度、フォルダ直下の Install-AudioRebind.cmd をダブルクリックしてください。'
        'PC全体の実行ポリシーは変えません。この起動だけスクリプトの実行を許可します。'
        'すでに作ったプロファイルは上書きしません。'
        'Double-click Install-AudioRebind.cmd again. This launch allows scripts once and does not change the PC execution policy. An existing profile is kept.'
    ) -join [Environment]::NewLine

    switch ($Kind) {
        'Policy' {
            $what = 'スクリプトの実行が、このPCの実行ポリシーで止まっています。 / Local scripts are blocked by the execution policy.'
        }
        'Module' {
            $what = 'powershell-yaml を入れられませんでした。 / powershell-yaml could not be installed.'
        }
        'ProgramFiles' {
            $what = 'Program Files に書けませんでした。管理者の許可が必要です。 / Setup could not write under Program Files. Administrator permission is required.'
        }
        'Task' {
            $what = 'タスクを登録できませんでした。 / The scheduled task was not registered.'
        }
        default {
            $what = '導入を完了できませんでした。 / Setup did not finish.'
        }
    }

    $text = @(
        $what
        ''
        '理由 / Reason:'
        $detail
        ''
        '次の操作 / What to do:'
        $next
    ) -join [Environment]::NewLine

    Add-Type -AssemblyName System.Windows.Forms
    [void][System.Windows.Forms.MessageBox]::Show(
        $text,
        'AudioRebind',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
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
        Show-AudioRebindSetupFailure -Kind $Kind -Detail $Detail
    }
    exit $Code
}
