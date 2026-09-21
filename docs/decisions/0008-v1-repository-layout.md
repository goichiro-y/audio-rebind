# 8. Repository layout for v1 runtime

- Status: Accepted
- Date: 2026-09-21

## Context

Before implementing the PowerShell orchestrator, contributors need a stable place for scripts, shared example profiles, and gitignored personal profiles so public history stays free of machine-specific paths.

## Decision

| Path | Role |
|------|------|
| `src/` | PowerShell orchestrator entrypoint and modules (v1 runtime) |
| `profiles/examples/` | Shared example YAML profiles with **placeholders only** (no real InstanceIds or personal absolute paths) |
| `local/profiles/` | Maintainer-private profiles (under gitignored `local/`) |

Do not invent a `plans/` tree; when/status remains [ROADMAP.md](../../ROADMAP.md).

## Consequences

- Issues [#5](https://github.com/goichiro-y/audio-rebind/issues/5)–[#7](https://github.com/goichiro-y/audio-rebind/issues/7) implement under `src/` and register tasks against that entrypoint.
- Example profiles ship in-repo; personal stacks copy/adapt under `local/profiles/`.
- A later packaging layout (installer paths under Program Files) can map onto the same script entrypoint without renaming the logical steps.
