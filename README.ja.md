# AudioRebind

スリープ／復帰のあとに Windows のオーディオセッションを張り直すツールです。Windows Audio エンジンの再起動、任意の USB オーディオデバイスの再初期化、設定したアプリの再起動を、決まった順番で行います。

特定メーカー専用ではありません。USB オーディオインターフェースや常駐の音声キャプチャアプリでの不具合が設計のきっかけですが、設定は汎用（デバイス ID・プロセス名）にします。

## 現状

ドキュメントと V1 設計 ADR（0003–0009）まで完了。手動オーケストレータは [`src/Invoke-AudioRebind.ps1`](src/Invoke-AudioRebind.ps1)。Task Scheduler による自動復帰は未着手です。進捗は英語の [ROADMAP.md](ROADMAP.md) と Milestone [v1](https://github.com/goichiro-y/audio-rebind/milestone/1) を見てください。

- **V1:** 自分用。YAML で対象を明示。設定 GUI なし。Task Scheduler で復帰時実行（常駐エージェントなし）。
- **Later / V2+:** カタログ既定＋オプトアウト、設定 GUI など（未コミット。Issue には積まない）。

正本は英語の [README.md](README.md) と [docs/](docs/README.md) です。言語方針は [docs/i18n.md](docs/i18n.md) を参照してください。置き場ルールは [CONTRIBUTING.md](CONTRIBUTING.md#where-work-lives) です。
