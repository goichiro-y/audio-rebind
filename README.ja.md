# AudioRebind

Windows **スリープ／復帰**のあと、設定では生きているように見えて共有モード **WASAPI** の再生やマイクが死んでいるとき、**音声エンジン →（任意）USB →（任意）アプリ**の順で張り直します。

特定メーカー専用ではありません。設定はデバイス ID・プロセス名などの汎用プロファイルです。常駐ではなく **タスク スケジューラ**が PowerShell を起動します（管理者必須）。

> **対象外の目安:** ローカル管理者に昇格できない、Modern Standby のみ（クラシックなスリープではない）、企業ロックダウンで管理者不可 — 詳細は [docs/scope.md](docs/scope.md)。対応の中心はクラシックなスリープ復帰＋管理者です。

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

管理者の Windows PowerShell 5.1 で、このリポジトリの clone／解凍から:

1. `.\src\Install-AudioRebind.ps1`  
   （`%ProgramFiles%\AudioRebind\` にランタイム、`%LOCALAPPDATA%\AudioRebind\profiles\default.yaml` をシード、必要なら `powershell-yaml`）
2. `default.yaml` を編集（ファイル先頭のチェックリスト；VID/PID とアプリパス）
3. `& "$env:ProgramFiles\AudioRebind\Register-AudioRebindTask.ps1"`  
   （既定でそのプロファイル；タスクは Program Files を指すので、あとで clone を動かしても安全）
4. スリープ → 復帰 → `%LOCALAPPDATA%\AudioRebind\logs\` を確認

手動1回（インストール後）: `& "$env:ProgramFiles\AudioRebind\Invoke-AudioRebind.ps1"`  
開発用の clone 直 Register（パス固定）は英語の [src/README.md](src/README.md)。アンインストール: `& "$env:ProgramFiles\AudioRebind\Uninstall-AudioRebind.ps1"`（LocalAppData は既定で残す）。

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

同じ入口は、管理者の PowerShell から**手動実行**もできます（セッションが死んだあとの復帰一般）。**自動**はクラシックなスリープ復帰で Event ID 1 および／または Kernel-Power 107 が来るケースを主張します（[#22](https://github.com/goichiro-y/audio-rebind/issues/22)）。休止の自動は**ベストエフォート／未検証**。シャットダウン起動やロック解除のみの自動は対象外。主張と対象外の詳細: [docs/scope.md](docs/scope.md)。実行メモ: 英語の [src/README.md](src/README.md)、[ADR 0005](docs/decisions/0005-resume-trigger-task-scheduler.md)。

## 必要なもの

> **対象オペレータ:** 昇格（ローカル管理者）できること。標準ユーザーのみのロックダウン、Modern Standby のみ、その他 [docs/scope.md](docs/scope.md) 外は対象外。

- Windows PowerShell **5.1**、**管理者**で実行（サービス再起動 / PnP / タスク登録 / Install）
- モジュール **`powershell-yaml`**（初回: `Install-Module powershell-yaml -Scope CurrentUser -Force`）
- **YAML プロファイル**は `%LOCALAPPDATA%\AudioRebind\profiles\`（Install が `default.yaml` をシード）。個人パスは Program Files に置かない。配置: [ADR 0010](docs/decisions/0010-installed-layout-programfiles-localappdata.md)

## 現状

**[0.3.0](CHANGELOG.md):** Program Files への薄い Install + LocalAppData プロファイル。タスクは clone パスに依存しなくてよい。semver **1.0.0**（見知らぬ人向けの仕上げ）はこれから。版ラダー: [ROADMAP.md](ROADMAP.md)。

## 構成（入口）

| パス | 用途 |
|------|------|
| [src/](src/README.md) | オーケストレータ、Install/Uninstall、タスク登録 |
| [docs/](docs/README.md) | スコープ・仕様・ADR・ガイド |
| [profiles/examples/](profiles/examples/README.md) | 例プロファイル（プレースホルダ） |
| [ROADMAP.md](ROADMAP.md) | 状況と予定 |

## 貢献

バグ報告や小さな修正は歓迎しますが、積極的な貢献者募集のプロジェクトではありません。英語の [CONTRIBUTING.md](CONTRIBUTING.md)、[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)。
