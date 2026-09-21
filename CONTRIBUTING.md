# Contributing

Thanks for your interest in contributing.

## Where work lives

| Kind | Where | Open a GitHub Issue? |
|------|--------|----------------------|
| Product version intent (0.1.x / 0.x / 1.0 / V2) | [ROADMAP.md](ROADMAP.md) version ladder | No (versions are not Issues) |
| 0.1.x / 0.x delivery work | [ROADMAP.md](ROADMAP.md) | Yes — committed phase work only |
| **Accepted, actionable** work | GitHub Issues + Milestone | **Yes** |
| **Uncommitted** ideas / V2 sketches | [ROADMAP.md](ROADMAP.md) **Later** | **No** until accepted |
| Adopted design | [docs/decisions/](docs/decisions/README.md) | Proposed ideas stay out of ADR files |
| Stable what/why | [docs/](docs/README.md) | No progress tables in docs |
| Machine / personal stack detail | `local/` (gitignored) | Never paste raw host inventory into Issues |

Committed work only in Issues. Uncommitted ideas stay on ROADMAP **Later** (enable GitHub Discussions for Ideas later if the project needs intake).

## Good first contributions

Welcome without requiring deep runtime changes:

- Improve [`profiles/examples/`](profiles/examples/) comments or placeholders (no personal paths)
- Docs-only fixes: typos, clearer Quick start, links
- Generalized updates to the power-transition table in [docs/scope.md](docs/scope.md) from your host (no full InstanceIds, usernames, or raw logs)
- Issues labeled [`good first issue`](https://github.com/goichiro-y/audio-rebind/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22)

Prefer a small PR that explains **what** and **why**. Machine-specific detail stays in `local/` (gitignored) — see [docs/guides/local-notes.md](docs/guides/local-notes.md).

## How to contribute

1. For larger changes, open an issue **after** the work is in scope for a Milestone (or discuss via ROADMAP / maintainers first).
2. Fork the repository (or create a branch if you have write access).
3. Make focused changes with a clear description.
4. Open a pull request that explains **what** changed and **why**.

## Code of conduct

Participation is governed by [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Documentation language

English is the source of truth for durable docs. Japanese uses sibling `*.ja.md` files (optional), not in-file dual bodies for `docs/` / ADRs. Root `README.md` may include a **short** Japanese blurb; fuller Japanese is [`README.ja.md`](README.ja.md).

**Issues:** prefer Japanese plus a short English summary and Acceptance checklist. Details: [docs/i18n.md](docs/i18n.md).

## What not to commit

- Secrets, tokens, `.env` files, or credentials
- Machine-specific absolute paths or personal usernames
- Large generated artifacts that belong in `.gitignore`

## Local development

See [README.md](README.md) Quick start and [src/README.md](src/README.md). Runtime is PowerShell under `src/`; register or invoke with an elevated Windows PowerShell 5.1 prompt.
