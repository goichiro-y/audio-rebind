# docs

Durable specifications and guides (**what / why**).

Progress and open questions belong in [ROADMAP.md](../ROADMAP.md) or GitHub Issues — do not duplicate the same content here.

Language policy (English canonical, `*.ja.md` for Japanese): [i18n.md](i18n.md).

## Index

| Document | Purpose |
|----------|---------|
| [problem-and-motivation.md](problem-and-motivation.md) | Sleep/resume failure and why AudioRebind exists |
| [scope.md](scope.md) | In / out of scope |
| [architecture-overview.md](architecture-overview.md) | Resume pipeline and relation to other tools |
| [specs/pipeline-spec.md](specs/pipeline-spec.md) | Step contracts for the orchestrator |
| [decisions/](decisions/README.md) | Adopted ADRs |
| [guides/local-notes.md](guides/local-notes.md) | Gitignored `local/` and `notes/private/` |
| [i18n.md](i18n.md) | Language / translation rules |

## Where to put things

| Content | Location |
|---------|----------|
| Architecture overview, stable specs, how-to guides | `docs/` |
| Adopted design decisions (ADRs) | [`decisions/`](decisions/README.md) |
| How-to guides | [`guides/`](guides/README.md) |
| Area-specific specs | [`specs/`](specs/README.md) |
| Language / translation rules | [`i18n.md`](i18n.md) |
| Roadmap / status | [ROADMAP.md](../ROADMAP.md) |
| Machine-local investigation notes | `local/` or `notes/private/` (not committed) |

## Layout

| Path | Purpose |
|------|---------|
| `README.md` | This index |
| `problem-and-motivation.md` | Problem statement |
| `scope.md` | Scope |
| `architecture-overview.md` | Architecture |
| `i18n.md` | Language policy |
| `decisions/` | Adopted ADRs |
| `guides/` | How-to guides |
| `specs/` | Area-specific specs |
