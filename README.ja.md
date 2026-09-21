# AudioRebind

Windows **スリープ／復帰**のあと、設定では生きているように見えて共有モード **WASAPI** の再生やマイクが死んでいるとき、**音声エンジン →（任意）USB →（任意）アプリ**の順で張り直します。

特定メーカー専用ではありません。設定はデバイス ID・プロセス名などの汎用プロファイルです。常駐ではなく **タスク スケジューラ**が PowerShell を起動します（管理者必須）。

正本は英語の [README.md](README.md) です（冒頭に短い日本語要約あり）。このファイルは**より詳しい日本語**用です。`docs/` / ADR は英語正本のみ（必要なら兄弟 `*.ja.md`）。Issue は日本語＋短い English summary / Acceptance。言語方針: [docs/i18n.md](docs/i18n.md)。

## 単層ツールとの違い

公開されているツールは多くの場合どちらか一層だけです。AudioRebind は順序付きの組み合わせです。

| やり方 | カバー | 足りないところ |
|--------|--------|----------------|
| `Audiosrv` / `AudioEndpointBuilder` だけ再起動（[AudioWakeFix](https://jdslabs.com/support/troubleshooting/) 系） | エンジン | USB もアプリ再起動も無し — 長寿命キャプチャが残りがち |
| ミキサー／キャプチャアプリだけ再起動（[SAMISH](https://github.com/thomwithah/samish) 系） | アプリ | サービス再起動も USB も無し |
| 手動の抜き差し／デバイスの無効化 | デバイス | 自動化されない |
| **AudioRebind** | エンジン → 任意 USB → 任意アプリ | YAML で明示指定（組み込みカタログはまだ Later／V2） |

詳細（英語）: [docs/architecture-overview.md](docs/architecture-overview.md)。

## クイックスタート

管理者の Windows PowerShell 5.1 で、このリポジトリの clone から:

1. [`profiles/examples/example-usb-interface.yaml`](profiles/examples/example-usb-interface.yaml) を `local/profiles/my.yaml` にコピーし、ファイル先頭のチェックリストどおりプレースホルダを埋める
2. `.\src\Register-AudioRebindTask.ps1 -ProfilePath .\local\profiles\my.yaml`  
   （無ければ `powershell-yaml` を CurrentUser に入れる）
3. スリープ → 復帰 → `%LOCALAPPDATA%\AudioRebind\logs\` を確認

手動1回: `.\src\Invoke-AudioRebind.ps1 -ProfilePath .\local\profiles\my.yaml`  
詳細・タイミング: 英語の [src/README.md](src/README.md)。

## 仕組み

常駐エージェントではありません。復帰時に Windows が電源イベントを出し、**タスク スケジューラ**がスクリプトを起動し、パイプラインが走ります。

```text
スリープ → 復帰
    → Power-Troubleshooter Event ID 1
      および／または Kernel-Power Event ID 107
    → タスク スケジューラ（IgnoreNew + 約120秒 debounce）
    → powershell.exe が Invoke-AudioRebind.ps1 を実行
    → AudioEngine →（任意）UsbDevice →（任意）Apps
```

同じ入口は、管理者の PowerShell から**手動実行**もできます（セッションが死んだあとの復帰一般）。**自動**はクラシックなスリープ復帰で Event ID 1 および／または Kernel-Power 107 が来るケースを主張します（[#22](https://github.com/goichiro-y/audio-rebind/issues/22)）。休止などの自動はどちらかのイベントが出れば動く**かもしれません**が、**未検証で、メンテナが近いうちに検証・公式サポートする約束はしません**。確認できたら、一般化した結果だけで [scope](docs/scope.md) の表を直す Issue / PR を歓迎します（フル InstanceId は不可。個人実験はフォークで）。シャットダウン起動やロック解除のみの自動はいま対象外です。詳細は英語の [src/README.md](src/README.md)、[ADR 0005](docs/decisions/0005-resume-trigger-task-scheduler.md)。

## 必要なもの

> **対象オペレータ:** インストール／実行できる人は昇格（ローカル管理者）できること。標準ユーザーのみのロックダウン環境は対象外。詳細: [docs/scope.md](docs/scope.md)。

- Windows PowerShell **5.1**、**管理者**で実行（サービス再起動 / PnP / タスク登録）
- モジュール **`powershell-yaml`**（初回: `Install-Module powershell-yaml -Scope CurrentUser -Force`）
- 対象アプリ（と任意の USB HardwareId）を書いた **YAML プロファイル**。[`profiles/examples/`](profiles/examples/README.md) をコピーし、個人用は `local/profiles/`（gitignore）へ

## 現状

**[0.2.0](CHANGELOG.md)** がいまのメンテナ向け **0.x** ドッグフード線です（二重トリガー、実用速度、静かめなアプリ起動）。プロファイルを書き、[`src/Register-AudioRebindTask.ps1`](src/Register-AudioRebindTask.ps1) で登録し、スリープ復帰で確認します。

**0.1.0** は最初の MVP 出口でした（[ADR 0007](docs/decisions/0007-v1-mvp-boundaries.md)）。

バージョン階段: **0.1.x** = 自分用 MVP · **0.x** = 公開準備（いま **0.2.0**） · **1.0.0** = README どおり試せる · **V2**（semver **2.0.0** カタログ／GUI、Later）。英語の [ROADMAP.md](ROADMAP.md)、[CHANGELOG.md](CHANGELOG.md)。

**0.x** 公開準備（プライバシースキャン）完了: [#15](https://github.com/goichiro-y/audio-rebind/issues/15)。任意: [#28](https://github.com/goichiro-y/audio-rebind/issues/28)。見知らぬ人向け Install は **1.0.0**（[#29](https://github.com/goichiro-y/audio-rebind/issues/29)–[#30](https://github.com/goichiro-y/audio-rebind/issues/30)）。

置き場ルール: [CONTRIBUTING.md](CONTRIBUTING.md#where-work-lives)。
