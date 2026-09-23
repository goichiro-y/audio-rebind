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
| `.github/` | Issue and pull request templates |
| `local/`, `notes/private/` | **Gitignored** machine-local notes — never commit |
| `local/profiles/` | Maintainer-private profiles (under `local/`) |

Where work lives (Issues vs ROADMAP vs docs): [CONTRIBUTING.md](CONTRIBUTING.md#where-work-lives). Do not add a `plans/` tree; keep when/status in `ROADMAP.md`.

## 2. Language (read this)

| Kind | Where to write | Rule |
|------|----------------|------|
| Canonical docs | `AGENTS.md`, `CONTRIBUTING.md`, `ROADMAP.md`, `CHANGELOG.md`, `docs/**/*.md` (no locale suffix), ADRs | **English** is the source of truth. No Japanese dual body in the same file |
| Root `README.md` | Japanese **landing at the top** + English landing of the same visitor density | English wins if they disagree. Do not put Event IDs / WASAPI diagnosis in README (`docs/` holds those). Do not duplicate the whole README in Japanese. See [docs/i18n.md](docs/i18n.md) |
| Japanese elsewhere | Sibling `*.ja.md` only | Optional; must not replace English. `README.ja.md` is a pointer, not a second full README |
| GitHub Issues | Japanese + short English summary / Acceptance | See [docs/i18n.md](docs/i18n.md) |
| Other locales | `*.<locale>.md` | Same sibling-file pattern |

Full policy: [docs/i18n.md](docs/i18n.md).

## 3. Documentation rules

- When specs and roadmap disagree, fix the durable spec in `docs/` first, then update `ROADMAP.md`.
- A version cut updates the ladder wording that names the ongoing line, in the ADR and in every place that quotes it, so an older minor is not left as the name of later cuts.
- Do not duplicate full specs inside the roadmap; link instead.
- Commit only public-safe text. Host identity, InstanceIds, raw logs, driver/VID-PID investigation detail, applied mitigations on a specific PC, and **personal app-stack** details belong under `local/` or `notes/private/` — see [docs/guides/local-notes.md](docs/guides/local-notes.md).
- Agents: when gathering or writing facts about *this* machine or *this* user’s apps, write them to `local/` first; only promote generalized wording into public docs.

## 4. Must not

- Commit secrets, tokens, or `.env` files
- Commit machine-specific absolute paths, personal usernames, motherboard/PC inventory, or full USB InstanceIds
- Commit personal stack inventories (specific installed apps, paths, process lists) — keep those in `local/`
- Treat this project as Yamaha-AG03-only (AG03-class gear may appear only as an example profile target)
- Put Japanese-only requirements in canonical English filenames

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
