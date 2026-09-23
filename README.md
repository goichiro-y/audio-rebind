# AudioRebind

[日本語](#日本語) · [English](#english) · Language policy: [docs/i18n.md](docs/i18n.md)

## 日本語

本ツールは、PCをスリープから復帰させたとき、「なぜか音が出ない」「なぜかマイクが反応しない」を直します。

これまでは直すために、手作業でアプリを再起動したり、USBケーブルを抜き差ししたりしていました。本ツールは、この面倒な復旧作業を代行します。特定のUSB機器やメーカー専用ではありません。

**仕組みについて**

本ツールは、常駐ソフトではありません。Windowsタスクスケジューラに処理を登録して使います。PCがスリープから戻ると、タスクスケジューラが本ツールを呼び出し、復旧処理を1回だけ走らせて終了します。

**復旧する順番**

以下の順番で処理を自動実行します。

1. Windowsの音声サービスの再起動（標準で実行）
2. （設定した場合のみ）USB機器を一度無効にして有効にする処理
3. （設定した場合のみ）指定した音声アプリの再起動

### 注意点・対象外となる環境

ツールの導入および実行には、Windowsの**管理者権限**が必要です（将来のバージョン1.0.0でも同様です）。

**音楽制作ソフト（DAW）等を利用中の方への注意**

本ツールはWindowsの音声サービスを再起動するため、音を独占して使っているソフトが止まったり、不安定になったりする場合があります。基本的には日常使いでのストレス軽減用としてご利用ください。

また、以下の環境や状態では、自動で復旧処理が動きません。

* スリープではなく、モニターの画面だけが消えていた場合
* アプリが自分で終了してしまった場合（落ちたアプリを監視して再起動するソフトではありません）
* モダンスタンバイ（ノートPCなどでよくある、画面オフに近い省電力機能）のみのPC。本ツールの自動起動はいまは保証していません。
* 会社のPCなど、管理者権限が使えない環境

### いつタスクスケジューラが起動するか

| 直前のPCの状態 | ACPI | タスクスケジューラによる起動 |
| --- | --- | --- |
| スリープ | S3 | **起動する（推奨ルート）** |
| 休止状態 | S4 | 未確認（S3同様に起動する可能性あり） |
| 画面オフのみ | S0 | 起動しない |
| モダンスタンバイ | S0低電力 | いまは保証しない |
| シャットダウンからの起動 | S5 | 起動しない |
| ロック画面の解除のみ | — | 起動しない |

自動では動かない状態でも、自分でスクリプトを起動すれば復旧できます。

### はじめ方

ダウンロードしたフォルダの直下にある `Install-AudioRebind.cmd` をダブルクリックします。管理者の許可は1回です。

- 許可すると、ツール本体を Program Files に置き、そのコピーと `%LOCALAPPDATA%\AudioRebind\profiles\default.yaml` に対してタスクを登録します。
- 許可しなかったときは、管理者権限が必要なので、タスクは登録されません。

そのあと `default.yaml` を編集します（再起動したいアプリなど。USB機器の指定は任意です）。中身は復帰のたびに読むので、編集のあと登録し直す必要はありません。

PCを一度スリープさせてから復帰し、音が鳴るか確認します。動作ログは `%LOCALAPPDATA%\AudioRebind\logs\` に保存されます。

コマンドで行う場合は、管理者の PowerShell 5.1 で次の順です。

1. `.\src\Install-AudioRebind.ps1`
2. `default.yaml` を編集
3. `& "$env:ProgramFiles\AudioRebind\Register-AudioRebindTask.ps1"`

**今すぐ手動で復旧させたいとき:**

タスクスケジューラを待たずに、以下のコマンドで直接ツールを走らせることもできます。
`& "$env:ProgramFiles\AudioRebind\Invoke-AudioRebind.ps1"`

詳しい仕様や他ツールとの比較は、この下の英語（[English](#english)）と [docs/](docs/README.md) を参照してください。協力する場合は [CONTRIBUTING.md](CONTRIBUTING.md) です。

---

## English

This tool is for when a PC resumes from sleep and, for no obvious reason, there is no sound or the microphone does not pick up.

People used to fix this by hand, restarting apps or unplugging a USB cable. AudioRebind does that recovery for you. It is not limited to a particular USB device or manufacturer.

**How it runs**

It is not a resident program. You register it with Windows Task Scheduler. After the PC resumes from sleep, Task Scheduler launches this tool, it runs the recovery once, and it exits.

**Recovery order**

1. Restart Windows Audio services (runs by default)
2. (If configured) Disable then enable a USB audio device
3. (If configured) Restart the listed audio apps

### Limits

Install and run require **Administrator** elevation (still required at **1.0.0**).

**DAW and exclusive-mode software**

Restarting Windows Audio can stop or destabilize apps that hold the device exclusively. This is meant to reduce daily friction, not as something you run through a studio session.

Automatic recovery does **not** run when:

- The display was off but the PC did not sleep
- An app quit by itself (this is not a crashed-app watchdog)
- The PC is Modern Standby-only (common on notebooks; automatic start is not a current promise)
- You cannot elevate (for example a locked-down work PC)

### When Task Scheduler starts

| Previous PC state | ACPI | Task Scheduler start |
| --- | --- | --- |
| Sleep | S3 | **Yes (supported path)** |
| Hibernate | S4 | Unverified (may start the same way as S3) |
| Display off only | S0 | No |
| Modern Standby | S0 low-power | Not a current promise |
| Power on from shutdown | S5 | No |
| Unlock only | — | No |

If the task does not start, you can still recover by running the script yourself.

Details: [docs/scope.md](docs/scope.md). Runtime notes: [src/README.md](src/README.md), [ADR 0005](docs/decisions/0005-resume-trigger-task-scheduler.md). Why an ordered package was uncommon: [docs/problem-and-motivation.md](docs/problem-and-motivation.md).

Japanese landing is at the top of this file (not a second full README).

## Compared to single-layer tools

Public utilities often cover only one layer. AudioRebind is the ordered combination:

| Approach | Covers | Typical gap |
|----------|--------|-------------|
| Restart `Audiosrv` / `AudioEndpointBuilder` only (e.g. [AudioWakeFix](https://jdslabs.com/support/troubleshooting/)-style) | Engine | No USB rebind; no app recycle — long-lived capture clients often stay broken |
| Close/restart mixer or capture apps only (e.g. [SAMISH](https://github.com/thomwithah/samish)-style) | Apps | No service restart; no USB PnP |
| Manual unplug / Device Manager toggle | Device | Not automated |
| **AudioRebind** | Engine → optional USB → optional apps | Explicit YAML profile (built-in catalog is **1.0.0** / Later) |

More detail: [docs/architecture-overview.md](docs/architecture-overview.md). Why an ordered package was uncommon: [docs/problem-and-motivation.md](docs/problem-and-motivation.md).

## Quick start

From a clone or unpack of this repo, double-click `Install-AudioRebind.cmd` at the repository root. Windows asks for Administrator once.

- If you accept, it copies the runtime to `%ProgramFiles%\AudioRebind\` and registers the scheduled task against that copy and `%LOCALAPPDATA%\AudioRebind\profiles\default.yaml`.
- If you decline, a message says Administrator is required and the task was not registered.

Then edit `default.yaml` (apps to restart; USB device IDs are optional. Checklist at the top of the file). The task reads that file on each resume, so you do not re-register after an edit.

Sleep → resume, then check `%LOCALAPPDATA%\AudioRebind\logs\`.

The same steps from an elevated Windows PowerShell 5.1 prompt:

1. `.\src\Install-AudioRebind.ps1`  
   (copies runtime to `%ProgramFiles%\AudioRebind\`, seeds `default.yaml`, ensures `powershell-yaml`)
2. Edit `default.yaml`
3. `& "$env:ProgramFiles\AudioRebind\Register-AudioRebindTask.ps1"`  
   (task points at Program Files — moving the clone later is safe)

Manual one-shot (installed):  
`& "$env:ProgramFiles\AudioRebind\Invoke-AudioRebind.ps1"`  
(or pass `-ProfilePath` explicitly)

Dev clone Register (path-locked to the checkout) remains available — see [src/README.md](src/README.md). Uninstall: `& "$env:ProgramFiles\AudioRebind\Uninstall-AudioRebind.ps1"` (keeps LocalAppData by default).

## Requirements

> **Supported operator model:** you must be able to elevate (local administrator). Locked-down standard-user-only environments, Modern Standby-only hosts, and other cases outside [docs/scope.md](docs/scope.md) are not targeted.

- Windows PowerShell **5.1**, run **elevated** (service restart / PnP / task registration)
- Module **`powershell-yaml`** (one-time: `Install-Module powershell-yaml -Scope CurrentUser -Force`)
- A **YAML profile** under `%LOCALAPPDATA%\AudioRebind\profiles\` (Install seeds `default.yaml` from [`profiles/examples/`](profiles/examples/README.md)). Do not put personal paths under Program Files. Layout: [ADR 0010](docs/decisions/0010-installed-layout-programfiles-localappdata.md)

## Status

**[0.3.0](CHANGELOG.md):** thin Install to Program Files + LocalAppData profiles; scheduled task need not depend on a durable clone path. Current polish is **0.3.x** (same YAML product). Semver **1.0.0** is catalog + settings GUI and is not shipped until that exists; **admin is still required then**. Version ladder: [ROADMAP.md](ROADMAP.md).

## Layout

| Path | Purpose |
|------|---------|
| [Install-AudioRebind.cmd](Install-AudioRebind.cmd) | Double-click setup: Install, then register the Program Files task |
| [src/](src/README.md) | Orchestrator, Install/Uninstall, Task Scheduler register/unregister |
| [docs/](docs/README.md) | Scope, specs, ADRs, guides |
| [profiles/examples/](profiles/examples/README.md) | Placeholder example profiles |
| [ROADMAP.md](ROADMAP.md) | Status and planned work |

## Contributing

Bug reports and small fixes are welcome; this is not an active contributor-recruitment project. See [CONTRIBUTING.md](CONTRIBUTING.md) and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Security

See [SECURITY.md](SECURITY.md).

## License

[MIT](LICENSE)
