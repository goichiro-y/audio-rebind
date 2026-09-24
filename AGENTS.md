# Agent and contributor conventions

AudioRebind — rebind Windows audio (and related apps) after sleep/resume

This file is self-contained. Do not require external personal rule repositories.

## 1. Directory roles

| Path | Role |
|------|------|
| Repository root | Product entry points (`README.md`, `LICENSE`, `ROADMAP.md`, `CHANGELOG.md`) |
| `docs/` | Durable specifications and guides (what / why) |
| `docs/decisions/` | Adopted ADRs only |
| `docs/i18n.md` | Language / translation rules |
| `ROADMAP.md` | Status and planned work (when / status); uncommitted ideas under **Later** |
| `src/` | PowerShell orchestrator (runtime; see ADR 0008 / installed layout ADR 0010) |
| `profiles/examples/` | Shared example YAML profiles (placeholders only) |
| `.github/` | Issue and pull request templates, plus `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, and `SECURITY.md` |
| `local/`, `notes/private/` | **Gitignored** machine-local notes — never commit |
| `local/profiles/` | Maintainer-private profiles (under `local/`) |

Where work lives (Issues vs ROADMAP vs docs): [.github/CONTRIBUTING.md](.github/CONTRIBUTING.md#where-work-lives). Do not add a `plans/` tree; keep when/status in `ROADMAP.md`.

## 2. Language (read this)

| Kind | Where to write | Rule |
|------|----------------|------|
| Canonical docs | `AGENTS.md`, `.github/CONTRIBUTING.md`, `ROADMAP.md`, `CHANGELOG.md`, `docs/**/*.md` (no locale suffix), ADRs | **English** is the source of truth. No Japanese dual body in the same file |
| Root `README.md` | Japanese **landing at the top** + English landing of the same visitor density | English wins if they disagree. Do not put Event IDs / WASAPI diagnosis in README (`docs/` holds those). Do not duplicate the whole README in Japanese. See [docs/i18n.md](docs/i18n.md) |
| Japanese elsewhere | Sibling `*.ja.md` only | Optional; must not replace English. The Japanese landing is the top of `README.md` |
| GitHub Issues | Japanese + short English summary / Acceptance | See [docs/i18n.md](docs/i18n.md) |
| Other locales | `*.<locale>.md` | Same sibling-file pattern |
| Setup dialogs | MessageBox text in `src/` | English block first, then a Japanese block, then the notice code alone on the last line. The sentences and the code are one row in `src/lib/Show-AudioRebindSetupFailure.ps1`. Short: what failed, and the next click. Do not explain execution policy, profile handling, or paste exception text and paths. Do not copy the sentences into another list. Prefixes: `SETUP-` (install, register, uninstall), `REBIND-` (pipeline, including a manual run), `SETTINGS-` (settings window). A row under those three may be added when that notice exists. Do not add any other prefix in the same change: propose the word to the user first, and wait for acceptance. See [docs/i18n.md](docs/i18n.md) |

Full policy: [docs/i18n.md](docs/i18n.md).

## 3. Documentation rules

- When specs and roadmap disagree, fix the durable spec in `docs/` first, then update `ROADMAP.md`.
- A version cut updates the ladder wording that names the ongoing line, in the ADR and in every place that quotes it, so an older minor is not left as the name of later cuts.
- Labels mark the kind of an issue (`bug`, `enhancement`, `decision`, `investigation`, `optional`). A label is not a version. Do not add a version label.
- When a version is cut, create a milestone titled with that version and no `v` prefix. Assign it to closed issues that shipped in the cut, then close the milestone. Leave open issues, and issues closed without shipping, without a milestone. An issue does not decide the release name ([.github/CONTRIBUTING.md](.github/CONTRIBUTING.md#where-work-lives)).
- Close an issue when its acceptance has been checked. Code landing in the tree is not that check.
- A `CHANGELOG.md` version section records what shipped in that version. Still-open work stays on `ROADMAP.md` and in Issues, not as bullets under that version.
- The git tag `v` plus that version, and its GitHub Release, mark the commit. Release の本文は、次のとおり書く。
  - そのページだけを開いた人向けに、製品が何をするかを一文で始める。日本語が先で、短い英語が続く。
  - 載せるのは、その版を入れた人が、説明なしで「そうなった」と分かる変化だけ。時制は過去にする。「した」「なった」。これからの話や、できる能力の説明にしない。
  - 以前より良くなった変更は、何をしたかと、それによって何が良くなったかを、「したことで、〜なった」でつなぐ。「ので」は使わない。見本は「アプリ停止処理を、音声復旧と同時に行うよう変更したことで、リバインド完了までの時間が短くなった。」原因は日常の言葉にし、段の順番までは書かない。
  - 「A を B と同時に変更した」とは書かず、「同時に行うよう変更した」と書く。変更した時刻と読まれないようにする。
  - 一連の処理が終わるまでの時間は「リバインド完了まで」と書いてよい。新しい呼び名は作らない。
  - その版で初めて入った機能は、以前との比較がない。結果だけを過去で書く。見本は「インストールできるようにした」「アンインストールできるようにした」。
  - クリックの手順、ファイルの置き場所、止めてから起動する順番は書かない。プロファイルのキー名、段の名前、前の版までの経緯は `CHANGELOG.md` と `README.md` に残す。
  - 機能をやめたときは「ツールのスコープ外に変更した」と書く。見本は「USB 機器の抜き差しをツールのスコープ外に変更した。」「しなくなった」は、故障のように読める。
  - 設定がまだ選べる不具合修正を、選べなくなったように書かない。読者がその不具合を知らなければ、Release には出さず `CHANGELOG.md` に残す。
- Do not duplicate full specs inside the roadmap; link instead.
- Commit only public-safe text. Host identity, InstanceIds, raw logs, driver/VID-PID investigation detail, applied mitigations on a specific PC, and **personal app-stack** details belong under `local/` or `notes/private/` — see [docs/guides/local-notes.md](docs/guides/local-notes.md).
- Agents: when gathering or writing facts about *this* machine or *this* user’s apps, write them to `local/` first; only promote generalized wording into public docs.

## 4. Must not

- Commit secrets, tokens, or `.env` files
- Commit machine-specific absolute paths, personal usernames, motherboard/PC inventory, or full USB InstanceIds
- Commit personal stack inventories (specific installed apps, paths, process lists) — keep those in `local/`
- Treat this project as Yamaha-AG03-only (AG03-class gear may appear only as an example profile target)
- Put Japanese-only requirements in canonical English filenames. Instructions that decide Japanese output may be written in Japanese in that section. That is not a Japanese translation of an English spec beside it

## 5. PowerShell file encoding

Windows PowerShell 5.1 (`powershell.exe`) is the runtime. It reads a `.ps1` with no BOM as the system ANSI code page (Shift-JIS on a Japanese Windows). UTF-8 without a BOM is safe only while every byte is ASCII. A `.ps1` that contains any non-ASCII character must be saved as UTF-8 **with** a BOM. Otherwise 5.1 can fail to parse it before the script runs.

Editor and agent writes default to UTF-8 without a BOM. A small edit often keeps a BOM that was already on the file; creating or rewriting a file does not add one. After creating or rewriting a non-ASCII `.ps1`, put the BOM back and parse the file with `powershell.exe` 5.1. PowerShell 7 accepts UTF-8 without a BOM, so a parse check there does not prove the double-click path works.

Do not put a BOM on `Install-AudioRebind.cmd`. A BOM before `@echo off` breaks cmd.

## 6. What a sleep run uses

The scheduled task runs `%ProgramFiles%\AudioRebind\`, not the git clone. Editing `src/` does not change the next sleep until `Install-AudioRebind.cmd` succeeds. Do not move or delete the clone to test that. Layout: [ADR 0010](docs/decisions/0010-installed-layout-programfiles-localappdata.md).

Install copies `lib\` onto that folder and does not delete files removed from the source. A script deleted in the repo can still be sitting in Program Files after a successful install.

| Path | Role |
|------|------|
| `%LOCALAPPDATA%\AudioRebind\profiles\default.yaml` | What the task reads, unless Register was given another `-ProfilePath` |
| `profiles/examples/` | Shared placeholders. Install seeds `default.yaml` from the example only when that file is missing |
| `local/profiles/` | Gitignored maintainer profiles. The task does not read them |

An edit to the example, or to `local/profiles/`, is not what the next sleep runs. Do not copy maintainer-only settings onto the example or onto `default.yaml` as the product default.

## 7. Optional tooling

Editor-specific rule directories (for example Cursor `.cursor/rules/`) are optional. If present, keep them thin and repository-specific; they must not replace this file.
