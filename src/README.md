# AudioRebind runtime (0.1.x)

PowerShell orchestrator for the resume rebind pipeline. Specs: [pipeline-spec](../docs/specs/pipeline-spec.md), [profile-spec](../docs/specs/profile-spec.md). Layout: [ADR 0008](../docs/decisions/0008-v1-repository-layout.md). Trigger packaging: [ADR 0005](../docs/decisions/0005-resume-trigger-task-scheduler.md).

## Requirements

- Windows PowerShell **5.1** (`powershell.exe`) — [ADR 0009](../docs/decisions/0009-yaml-on-windows-powershell-51.md)
- **Administrator** elevation (service restart / PnP / task registration). Supported operator model: [scope](../docs/scope.md) (elevate required; standard-user-only out of scope).
- Module **`powershell-yaml`** (CurrentUser). Manual install if needed:

```powershell
Install-Module powershell-yaml -Scope CurrentUser -Force
```

`Register-AudioRebindTask.ps1` installs it automatically when missing (setup-time only; not on every resume). If PSGallery/network blocks install, registration fails with an actionable error.

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

On hosts where UsbDevice disable fails (see closed [#12](https://github.com/goichiro-y/audio-rebind/issues/12)), set `usbDevice.enabled: false` in the profile to skip that step before Apps. For Electron-style apps, lower `gracefulStopSeconds` / `forceStopSeconds` (e.g. `2`) so recycle finishes sooner ([#13](https://github.com/goichiro-y/audio-rebind/issues/13)).

To avoid recycled apps stealing focus, set `windowAfterStart: minimize` on `apps` or per process ([#16](https://github.com/goichiro-y/audio-rebind/issues/16)). Launch uses Win32 `CreateProcess` + `SW_SHOWMINNOACTIVE` (not `Start-Process -WindowStyle Minimized`) ([#21](https://github.com/goichiro-y/audio-rebind/issues/21)); a short minimize poll remains as fallback when the app creates a window later. Electron-style apps may still flash briefly — that is an OS/app limit, not something AudioRebind can fully erase for arbitrary GUIs. Minimize polling early-exits on success and gives up quickly when there is no main window; tune `minimizeTimeoutMs` / `minimizeNoWindowGiveUpMs` if needed ([#18](https://github.com/goichiro-y/audio-rebind/issues/18)).

For faster recycle of Electron-style apps, prefer `stopMode: force`, keep `gracefulStopSeconds` / `forceStopSeconds` small, and rely on `postStopDelayMs` / `postForceStopMs` instead of long fixed sleeps ([#19](https://github.com/goichiro-y/audio-rebind/issues/19)).

`delays.afterAudioEngineMs` defaults to 2000 in examples. If the audio engine comes back quickly on your machine, try **500–1000**; if sessions still fail until a longer wait, keep 2000 ([#20](https://github.com/goichiro-y/audio-rebind/issues/20)). Within AudioEngine, service restarts wait via Running poll (not fixed 1s sleeps). Apps stop all configured process entries in one batched phase.

## Automatic run (Task Scheduler)

Register (elevated) so resume events start the orchestrator. Also ensures `powershell-yaml` for CurrentUser when missing:

```powershell
cd <repo>
.\src\Register-AudioRebindTask.ps1 -ProfilePath .\local\profiles\maintainer.yaml
```

Unregister (removes the whole task, including both event triggers):

```powershell
.\src\Unregister-AudioRebindTask.ps1
```

- Task name default: `AudioRebind-Resume`
- Triggers (same task):
  - System / `Microsoft-Windows-Power-Troubleshooter` / Event ID **1** (primary)
  - System / `Microsoft-Windows-Kernel-Power` / Event ID **107** (fallback when ID 1 is missing — [#22](https://github.com/goichiro-y/audio-rebind/issues/22))
- Dedup: `MultipleInstancesPolicy=IgnoreNew` while a run is live; `Invoke-AudioRebind.ps1` also skips if the last non-WhatIf run was within ~120s (`%LOCALAPPDATA%\AudioRebind\last-run.stamp`)
- Principal: registering user, **HighestAvailable** (so CurrentUser modules resolve)
- Same entrypoint as manual run
- Classic sleep→resume verified; hibernate best-effort/unverified — see [scope](../docs/scope.md)

After upgrading from a single-trigger install, **re-run Register** so Kernel-Power 107 is added.

Verify:

```powershell
Get-ScheduledTask -TaskName AudioRebind-Resume | Format-List TaskName, State
(Get-ScheduledTask -TaskName AudioRebind-Resume).Triggers | Format-List
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
