# Architecture Decision Records (ADRs)

Store **adopted** decisions here.

## Conventions

- One decision per file, for example `0001-use-mit-license.md`
- Record context, decision, and consequences
- Proposed or rejected ideas belong in [ROADMAP.md](../../ROADMAP.md) **Later** (or a Discussion), not here — open an Issue only after the work is accepted

## Index

| ADR | Decision |
|-----|----------|
| [0001-single-orchestrator-three-steps.md](0001-single-orchestrator-three-steps.md) | One orchestrator, three steps |
| [0002-name-audio-rebind.md](0002-name-audio-rebind.md) | Display name AudioRebind / repo `audio-rebind` |
| [0003-v1-powershell-orchestrator.md](0003-v1-powershell-orchestrator.md) | v1 stack: PowerShell orchestrator |
| [0004-profile-format-yaml.md](0004-profile-format-yaml.md) | Profiles are YAML |
| [0005-resume-trigger-task-scheduler.md](0005-resume-trigger-task-scheduler.md) | Task Scheduler + elevated task; Power-Troubleshooter/1 + Kernel-Power/107 |
| [0006-v1-step-defaults-engine-usb.md](0006-v1-step-defaults-engine-usb.md) | Restart both audio services; USB disable/enable by HardwareId |
| [0007-v1-mvp-boundaries.md](0007-v1-mvp-boundaries.md) | 0.1.x MVP boundaries (YAML, no GUI); ladder → [0011](0011-version-ladder-1-0-catalog-gui.md) |
| [0008-v1-repository-layout.md](0008-v1-repository-layout.md) | `src/`, `profiles/examples/`, `local/profiles/` |
| [0009-yaml-on-windows-powershell-51.md](0009-yaml-on-windows-powershell-51.md) | YAML via powershell-yaml on Windows PowerShell 5.1 |
| [0010-installed-layout-programfiles-localappdata.md](0010-installed-layout-programfiles-localappdata.md) | Program Files runtime + LocalAppData profiles/logs (#29/#30) |
| [0011-version-ladder-1-0-catalog-gui.md](0011-version-ladder-1-0-catalog-gui.md) | **1.0.0** = catalog + settings GUI; YAML polish stays on **0.x** after 0.3.0; no public **V2** / 2.0 destination |
| [0012-withdraw-usb-disable-enable.md](0012-withdraw-usb-disable-enable.md) | USB disable/enable withdrawn from the current pipeline; revisit when two steps are not enough |

## Template (copy into a new file)

```markdown
# <number>. <title>

- Status: Accepted
- Date: YYYY-MM-DD

## Context

<What problem or constraint prompted this decision?>

## Decision

<What we decided>

## Consequences

<Trade-offs, follow-ups, what becomes easier or harder>
```
