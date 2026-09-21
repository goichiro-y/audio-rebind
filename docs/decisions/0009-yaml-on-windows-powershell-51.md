# 9. YAML on Windows PowerShell 5.1

- Status: Accepted
- Date: 2026-09-21

## Context

Profiles are YAML ([ADR 0004](0004-profile-format-yaml.md)). Automatic runs use Task Scheduler, which typically invokes `powershell.exe` (Windows PowerShell 5.1). PowerShell 7+ (`pwsh`) is a side-by-side install and is not present on every Windows machine. Shipping a “just works” experience favors the OS-default host.

## Decision

Load profiles on **Windows PowerShell 5.1** using a small YAML module (**`powershell-yaml`** or an equivalent maintained package). Do **not** require PowerShell 7+ for v1.

Installation of the module (CurrentUser or as part of a later installer) is an implementation detail of [#6](https://github.com/goichiro-y/audio-rebind/issues/6); document the exact install command in `src/` when the loader lands.

## Consequences

- Scheduled tasks can target `powershell.exe` without depending on `pwsh` being on PATH.
- Contributors and end users need a one-time module install (or a bundled install step later).
- PowerShell 7 remains usable for development if the same module works there; it is not the supported runtime baseline for v1 packaging.
