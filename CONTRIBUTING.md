# Contributing

Thanks for your interest in contributing.

## Where work lives

| Kind | Where | Open a GitHub Issue? |
|------|--------|----------------------|
| Product version intent (V1 / V2) | [ROADMAP.md](ROADMAP.md) | No (versions are not Issues) |
| V1 delivery phases | [ROADMAP.md](ROADMAP.md) V1 sequence | Yes — committed phase work only |
| **Accepted, actionable** work | GitHub Issues + Milestone | **Yes** |
| **Uncommitted** ideas / V2+ sketches | [ROADMAP.md](ROADMAP.md) **Later** | **No** until accepted |
| Adopted design | [docs/decisions/](docs/decisions/README.md) | Proposed ideas stay out of ADR files |
| Stable what/why | [docs/](docs/README.md) | No progress tables in docs |
| Machine / personal stack detail | `local/` (gitignored) | Never paste raw host inventory into Issues |

Committed work only in Issues. Uncommitted ideas stay on ROADMAP **Later** (enable GitHub Discussions for Ideas later if the project goes public and needs intake).

## How to contribute

1. For larger changes, open an issue **after** the work is in scope for a Milestone (or discuss via ROADMAP / maintainers first).
2. Fork the repository (or create a branch if you have write access).
3. Make focused changes with a clear description.
4. Open a pull request that explains **what** changed and **why**.

## Code of conduct

Participation is governed by [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Documentation language

English is the source of truth. Japanese and other translations use sibling `*.ja.md` (or `*.<locale>.md`) files and must not replace English originals.

See [docs/i18n.md](docs/i18n.md).

## What not to commit

- Secrets, tokens, `.env` files, or credentials
- Machine-specific absolute paths or personal usernames
- Large generated artifacts that belong in `.gitignore`

## Local development

See [README.md](README.md) and [ROADMAP.md](ROADMAP.md). There is no runtime package yet; start with documentation and the planned resume orchestrator.
