# AudioRebind runtime (v1)

PowerShell orchestrator for the resume rebind pipeline. Specs: [pipeline-spec](../docs/specs/pipeline-spec.md), [profile-spec](../docs/specs/profile-spec.md). Layout: [ADR 0008](../docs/decisions/0008-v1-repository-layout.md). Trigger packaging: [ADR 0005](../docs/decisions/0005-resume-trigger-task-scheduler.md).

## Requirements

- Windows PowerShell **5.1** (`powershell.exe`) — [ADR 0009](../docs/decisions/0009-yaml-on-windows-powershell-51.md)
- **Administrator** elevation (service restart / PnP / task registration)
- Module **`powershell-yaml`** (CurrentUser is enough for manual runs and for the scheduled task, which runs as your user)

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

### Resume timing tips

On hosts where UsbDevice disable always fails ([#12](https://github.com/goichiro-y/audio-rebind/issues/12)), set `usbDevice.enabled: false` in the profile to avoid retry delay before Apps. For Electron-style apps, lower `gracefulStopSeconds` / `forceStopSeconds` so recycle finishes sooner ([#13](https://github.com/goichiro-y/audio-rebind/issues/13)).

## Automatic run (Task Scheduler)

Register (elevated) so resume fires Event ID 1 → orchestrator:

```powershell
cd <repo>
.\src\Register-AudioRebindTask.ps1 -ProfilePath .\local\profiles\maintainer.yaml
```

Unregister:

```powershell
.\src\Unregister-AudioRebindTask.ps1
```

- Task name default: `AudioRebind-Resume`
- Trigger: System log / `Microsoft-Windows-Power-Troubleshooter` / Event ID **1**
- Principal: registering user, **HighestAvailable** (so CurrentUser modules resolve)
- Same entrypoint as manual run

Verify:

```powershell
Get-ScheduledTask -TaskName AudioRebind-Resume | Format-List TaskName, State
```

## Layout

| Path | Role |
|------|------|
| `Invoke-AudioRebind.ps1` | Pipeline entrypoint |
| `Register-AudioRebindTask.ps1` | Install resume scheduled task |
| `Unregister-AudioRebindTask.ps1` | Remove scheduled task |
| `lib/Import-AudioRebindProfile.ps1` | YAML load + validation |
| `lib/Write-AudioRebindLog.ps1` | Logging |
| `lib/Step-AudioEngine.ps1` | Restart EndpointBuilder + Audiosrv |
| `lib/Step-UsbDevice.ps1` | HardwareId match + disable/enable (+ pnputil fallback) |
| `lib/Step-Apps.ps1` | Stop/start configured processes |

Personal profiles belong under `local/profiles/` (gitignored). Shared placeholders: `profiles/examples/`.
