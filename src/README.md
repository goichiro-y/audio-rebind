# AudioRebind runtime

PowerShell orchestrator for the resume rebind pipeline. Specs: [pipeline-spec](../docs/specs/pipeline-spec.md), [profile-spec](../docs/specs/profile-spec.md). Repo layout: [ADR 0008](../docs/decisions/0008-v1-repository-layout.md). Installed layout: [ADR 0010](../docs/decisions/0010-installed-layout-programfiles-localappdata.md). Trigger packaging: [ADR 0005](../docs/decisions/0005-resume-trigger-task-scheduler.md).

## Requirements

- Windows PowerShell **5.1** (`powershell.exe`) — [ADR 0009](../docs/decisions/0009-yaml-on-windows-powershell-51.md). An elevated session must be allowed to run local `.ps1` files; if Windows blocks the script, that is the host ExecutionPolicy, not something Install bypasses.
- **Administrator** elevation (service restart / PnP / task registration / Install). Supported operator model: [scope](../docs/scope.md) (elevate required; standard-user-only out of scope).
- Module **`powershell-yaml`** (CurrentUser). Manual install if needed:

```powershell
Install-Module powershell-yaml -Scope CurrentUser -Force
```

`Install-AudioRebind.ps1` and `Register-AudioRebindTask.ps1` install it automatically when missing (setup-time only; not on every resume). If PSGallery/network blocks install, setup fails with an actionable error.

## Double-click setup

`Install-AudioRebind.cmd` at the repository root asks for elevation once. If accepted, it runs `Install-AudioRebind.ps1`, then `%ProgramFiles%\AudioRebind\Register-AudioRebindTask.ps1` (the installed copy and LocalAppData `default.yaml`). That process uses `-ExecutionPolicy Bypass` only for itself; it does not change the machine policy. If elevation is declined, a dialog says Administrator is required and the task was not registered. If setup fails after that, a dialog states what failed and to double-click `Install-AudioRebind.cmd` again, then a `SETUP-` code ([#35](https://github.com/goichiro-y/audio-rebind/issues/35), [#40](https://github.com/goichiro-y/audio-rebind/issues/40)). Success shows a completion dialog; closing it ends the window ([#38](https://github.com/goichiro-y/audio-rebind/issues/38)). An existing profile is kept. The launcher is not copied to Program Files.

## Quick start (installed — preferred)

Double-click `Install-AudioRebind.cmd`, then edit `%LOCALAPPDATA%\AudioRebind\profiles\default.yaml`. The task reads that file on each resume.

The same steps from an elevated Windows PowerShell 5.1 prompt, from a clone or unpack of this repo:

```powershell
cd <repo>
.\src\Install-AudioRebind.ps1
```

1. Edit `%LOCALAPPDATA%\AudioRebind\profiles\default.yaml` (placeholders — see checklist in the file).
2. Register (defaults to that profile; entrypoint is under Program Files):

```powershell
& "$env:ProgramFiles\AudioRebind\Register-AudioRebindTask.ps1"
```

3. Sleep → resume, then check `%LOCALAPPDATA%\AudioRebind\logs\`

Moving or deleting the clone after Install must not break the scheduled task.

Uninstall (keeps LocalAppData profiles/logs by default):

```powershell
& "$env:ProgramFiles\AudioRebind\Uninstall-AudioRebind.ps1"
# optional: -RemoveUserData
```

Upgrade: re-run `Install-AudioRebind.ps1` (overwrites Program Files), edit profile if needed, re-run Register.

## Dev clone (optional)

From an **elevated** prompt at the repository root (paths locked to the clone until you re-register):

```powershell
cd <repo>
.\src\Invoke-AudioRebind.ps1 -ProfilePath .\local\profiles\maintainer.yaml
.\src\Register-AudioRebindTask.ps1 -ProfilePath .\local\profiles\maintainer.yaml
```

Dry run:

```powershell
.\src\Invoke-AudioRebind.ps1 -ProfilePath .\profiles\examples\example-usb-interface.yaml -WhatIf
```

Exit codes: `0` ok, `1` usage/profile/module, `2` required step failed, `3` unexpected — see pipeline-spec.

Logs: `%LOCALAPPDATA%\AudioRebind\logs\`

### Resume timing tips

`gracefulStopSeconds` defaults to **2**: the max wait for an app to exit after a close request, before force-kill. Apps that exit sooner do not wait out the ceiling. `stopMode: force` skips that wait ([#13](https://github.com/goichiro-y/audio-rebind/issues/13), [#19](https://github.com/goichiro-y/audio-rebind/issues/19)).

To avoid recycled apps stealing focus, set `windowAfterStart: minimize` on `apps` or per process ([#16](https://github.com/goichiro-y/audio-rebind/issues/16)). Launch uses Win32 `CreateProcess` + `SW_SHOWMINNOACTIVE` (not `Start-Process -WindowStyle Minimized`) ([#21](https://github.com/goichiro-y/audio-rebind/issues/21)); a short minimize poll remains as fallback when the app creates a window later. Electron-style apps may still flash briefly — that is an OS/app limit, not something AudioRebind can fully erase for arbitrary GUIs. Minimize polling early-exits on success and gives up quickly when there is no main window; tune `minimizeTimeoutMs` / `minimizeNoWindowGiveUpMs` if needed ([#18](https://github.com/goichiro-y/audio-rebind/issues/18)).

For faster recycle of Electron-style apps, prefer `stopMode: force`, keep `gracefulStopSeconds` / `forceStopSeconds` small, and rely on `postStopDelayMs` / `postForceStopMs` instead of long fixed sleeps ([#19](https://github.com/goichiro-y/audio-rebind/issues/19)).

`delays.afterAudioEngineMs` defaults to 2000 in examples. If the audio engine comes back quickly on your machine, try **500–1000**; if sessions still fail until a longer wait, keep 2000 ([#20](https://github.com/goichiro-y/audio-rebind/issues/20)). Within AudioEngine, service restarts wait via Running poll (not fixed 1s sleeps). App stop runs during that restart; the delay is only before apps start ([#39](https://github.com/goichiro-y/audio-rebind/issues/39)). Apps stop all configured process entries in one batched phase.

## Automatic run (Task Scheduler)

- Task name default: `AudioRebind-Resume`
- Triggers (same task):
  - System / `Microsoft-Windows-Power-Troubleshooter` / Event ID **1** (primary)
  - System / `Microsoft-Windows-Kernel-Power` / Event ID **107** (fallback when ID 1 is missing — [#22](https://github.com/goichiro-y/audio-rebind/issues/22))
- Dedup: `MultipleInstancesPolicy=IgnoreNew` while a run is live; `Invoke-AudioRebind.ps1` also skips if the last non-WhatIf run was within ~120s (`%LOCALAPPDATA%\AudioRebind\last-run.stamp`)
- Principal: registering user, **HighestAvailable** (so CurrentUser modules resolve)
- Classic sleep→resume verified; hibernate best-effort/unverified — see [scope](../docs/scope.md)

After upgrading from a single-trigger install, **re-run Register** so Kernel-Power 107 is added.

Verify:

```powershell
Get-ScheduledTask -TaskName AudioRebind-Resume | Format-List TaskName, State
(Get-ScheduledTask -TaskName AudioRebind-Resume).Triggers | Format-List
(Get-ScheduledTask -TaskName AudioRebind-Resume).Actions
```

## Layout

| Path | Role |
|------|------|
| `Start-AudioRebindSetup.ps1` | Called by repo-root `Install-AudioRebind.cmd` (not copied to Program Files) |
| `Install-AudioRebind.ps1` | Copy runtime to Program Files; seed LocalAppData profile |
| `Uninstall-AudioRebind.ps1` | Remove task + Program Files; keep user data by default |
| `Invoke-AudioRebind.ps1` | Pipeline entrypoint |
| `Register-AudioRebindTask.ps1` | Install resume scheduled task |
| `Unregister-AudioRebindTask.ps1` | Remove scheduled task only |
| `lib/Import-AudioRebindProfile.ps1` | YAML load + validation |
| `lib/Write-AudioRebindLog.ps1` | Logging |
| `lib/Step-AudioEngine.ps1` | Restart EndpointBuilder + Audiosrv |
| `lib/Step-Apps.ps1` | Stop/start configured processes |

Installed profiles: `%LOCALAPPDATA%\AudioRebind\profiles\` (default `default.yaml`). Dev personal profiles: `local/profiles/` (gitignored). Shared placeholders: `profiles/examples/`.
