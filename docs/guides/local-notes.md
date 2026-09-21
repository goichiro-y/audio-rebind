# Local and private notes

Some details are useful on one machine or for one person’s app stack but should never enter public git history.

## Directories (gitignored)

| Path | Use |
|------|-----|
| `local/` | Working notes for this clone (default place for investigation dumps) |
| `notes/private/` | Optional alternate private notes tree |

Both paths are listed in `.gitignore` as `/local/` and `/notes/private/`.

## What must stay local (do not commit)

| Kind | Examples |
|------|----------|
| Host identity | Motherboard / PC model, Windows build tied to a specific machine, usernames, absolute paths |
| Device instance detail | Full USB InstanceId strings, serial-like IDs, raw Event Viewer / ETW dumps |
| Investigation thickness | Observed driver **versions**, VID/PID pairs used while debugging this host, step-by-step mitigations already applied on this PC |
| Personal stack | Specific apps the maintainer runs (dictation, browser, chat), install paths, process lists from this machine |

When writing or editing docs, **generalize** first. If a fact only helps the next agent on this PC, put it under `local/` (or `notes/private/`) and keep public docs free of it.

## What belongs in git instead

- Generalized symptoms and motivation → `docs/problem-and-motivation.md`
- Scope and architecture → `docs/scope.md`, `docs/architecture-overview.md`
- Step contracts → `docs/specs/`
- Decisions → `docs/decisions/`
- Plans → `ROADMAP.md`
- Light product-class examples (e.g. “AG03-class USB interface” as a **profile example**, not a host inventory) may appear in public docs when they explain scope — without VID/PID, InstanceId, or “what I installed on my PC”

## Agent workflow

1. Prefer reading `local/investigation-notes.md` (if present) for host-specific and personal-stack context.
2. Never copy those raw contents into commits, README, ADRs, or public `docs/`.
3. After investigation, split results: durable general findings → public docs; machine / stack specifics → update `local/` only.
