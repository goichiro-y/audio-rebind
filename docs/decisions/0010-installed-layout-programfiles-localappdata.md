# 10. Installed layout: Program Files runtime + LocalAppData settings

- Status: Accepted
- Date: 2026-09-22
- Issues: [#29](https://github.com/goichiro-y/audio-rebind/issues/29), [#30](https://github.com/goichiro-y/audio-rebind/issues/30)

## Context

Clone- or unpack-based Task Scheduler registration stores absolute paths to `Invoke-AudioRebind.ps1` and the profile YAML. Moving the folder breaks the task. Strangers need a thin fixed install without MSI, Setup.exe, or standard-user-only packaging ([scope](../scope.md)).

Repository development layout remains [ADR 0008](0008-v1-repository-layout.md) (`src/`, `profiles/examples/`, `local/profiles/`).

## Decision

Two layers:

| Layer | Path | Contents |
|-------|------|----------|
| **Runtime** | `%ProgramFiles%\AudioRebind\` | `Invoke-AudioRebind.ps1`, `Register-AudioRebindTask.ps1`, `Unregister-AudioRebindTask.ps1`, `Install-AudioRebind.ps1`, `Uninstall-AudioRebind.ps1`, `lib\`, `examples\` (placeholders copied from repo `profiles/examples`) |
| **User data** | `%LOCALAPPDATA%\AudioRebind\` | `profiles\` (editable YAML), `logs\`, `last-run.stamp` |

**Default profile:** `%LOCALAPPDATA%\AudioRebind\profiles\default.yaml`. `Install-AudioRebind.ps1` seeds it from `examples\example-usb-interface.yaml` only when missing (never clobber). Personal / machine paths stay under LocalAppData — not under Program Files.

**Upgrade:** overwrite Program Files runtime, re-run Register; preserve LocalAppData profiles and logs.

**Uninstall:** remove scheduled task and Program Files payload; **keep** LocalAppData by default (`-RemoveUserData` to delete).

**Dev clone:** registering from a repo checkout (`.\src\Register-AudioRebindTask.ps1`) remains supported; `$PSScriptRoot` resolves the entrypoint. Public Quick start prefers Install → edit `default.yaml` → Register from Program Files.

No MSI / signed Setup.exe requirement; no least-privilege or standard-user-only install.

## Consequences

- [#30](https://github.com/goichiro-y/audio-rebind/issues/30) implements Install / Uninstall and Register defaults against these paths.
- Moving or deleting the git clone after Install must not break the scheduled task.
- Catalog / GUI and richer installers stay **V2** / Later.
