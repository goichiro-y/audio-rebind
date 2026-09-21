# AudioRebind

スリープ／復帰のあとに Windows のオーディオセッションを張り直すツールです。Windows Audio エンジンの再起動、任意の USB オーディオデバイスの再初期化、設定したアプリの再起動を、決まった順番で行います。

特定メーカー専用ではありません。USB オーディオインターフェースや常駐の音声キャプチャアプリでの不具合が設計のきっかけですが、設定は汎用（デバイス ID・プロセス名）にします。

## 現状

**V1 MVP（0.1.0）** はメンテナ犬食い向けに利用可能です。[`src/Register-AudioRebindTask.ps1`](src/Register-AudioRebindTask.ps1) でタスク登録し、YAML プロファイルを指定してスリープ復帰で実行します。詳細は英語の [src/README.md](src/README.md)、[CHANGELOG.md](CHANGELOG.md)、[ROADMAP.md](ROADMAP.md) を参照してください。

後続の磨き込み: UsbDevice disable（[#12](https://github.com/goichiro-y/audio-rebind/issues/12)）、復帰の高速化（[#13](https://github.com/goichiro-y/audio-rebind/issues/13)）。

正本は英語の [README.md](README.md) と [docs/](docs/README.md) です。言語方針は [docs/i18n.md](docs/i18n.md) を参照してください。置き場ルールは [CONTRIBUTING.md](CONTRIBUTING.md#where-work-lives) です。
