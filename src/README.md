# AudioRebind runtime (v1)

PowerShell orchestrator for the resume rebind pipeline. Specs: [pipeline-spec](../docs/specs/pipeline-spec.md), [profile-spec](../docs/specs/profile-spec.md). Layout: [ADR 0008](../docs/decisions/0008-v1-repository-layout.md).

## Requirements

- Windows PowerShell **5.1** (`powershell.exe`) — [ADR 0009](../docs/decisions/0009-yaml-on-windows-powershell-51.md)
- **Administrator** elevation (service restart / PnP)
- Module **`powershell-yaml`** (CurrentUser is enough)

```powershell
Install-Module powershell-yaml -Scope CurrentUser -Force
```

## Manual run

From an **elevated** Windows PowerShell 5.1 prompt, repository root:

```powershell
cd <repo>
.\src\Invoke-AudioRebind.ps1 -ProfilePath .\local\profiles\maintainer.yaml
```

Dry run (no service/PnP/app changes):

```powershell
.\src\Invoke-AudioRebind.ps1 -ProfilePath .\profiles\examples\example-usb-interface.yaml -WhatIf
```

Exit codes: `0` ok, `1` usage/profile/module, `2` required step failed, `3` unexpected — see pipeline-spec.

Logs: `%LOCALAPPDATA%\AudioRebind\logs\`

## Layout

| Path | Role |
|------|------|
| `Invoke-AudioRebind.ps1` | Entrypoint |
| `lib/Import-AudioRebindProfile.ps1` | YAML load + validation |
| `lib/Write-AudioRebindLog.ps1` | Logging |
| `lib/Step-AudioEngine.ps1` | Restart EndpointBuilder + Audiosrv |
| `lib/Step-UsbDevice.ps1` | HardwareId match + disable/enable |
| `lib/Step-Apps.ps1` | Stop/start configured processes |

Personal profiles belong under `local/profiles/` (gitignored). Shared placeholders: `profiles/examples/`.

## Not in this folder yet

Task Scheduler registration is Issue [#7](https://github.com/goichiro-y/audio-rebind/issues/7).
