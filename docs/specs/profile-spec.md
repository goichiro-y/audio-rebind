# Profile specification

On-disk profile contract for the resume orchestrator. Format decision: YAML ([ADR 0004](../decisions/0004-profile-format-yaml.md)). Step behavior: [pipeline-spec](pipeline-spec.md), [ADR 0006](../decisions/0006-v1-step-defaults-engine-usb.md).

## File

- Extension: `.yaml` / `.yml`
- One profile per file; orchestrator selects a profile by name or path

## Schema (v1)

```yaml
name: example-usb-interface
description: Optional human-readable note

steps:
  audioEngine:
    enabled: true          # default true; required by default when enabled
  apps:
    enabled: false
    # windowAfterStart: minimize
    # minimizeTimeoutMs: 1200
    # minimizeNoWindowGiveUpMs: 400
    # stopMode: force                 # or graceful-then-force
    # postStopDelayMs: 200
    # postForceStopMs: 200
    processes:
      - path: "C:\\Path\\To\\App.exe"   # prefer path; name-only allowed
        # name: "App.exe"
        # windowAfterStart: minimize   # per-process override
    gracefulStopSeconds: 2
    forceStopSeconds: 5

delays:
  afterAudioEngineMs: 2000   # safe default; try 500–1000 on fast hosts (#20)
  afterAppsMs: 0
```

## Matching rules

Never commit machine-specific full InstanceIds or personal usernames into shared profiles.

## YAML loading (v1)

**Baseline:** Windows PowerShell **5.1** + **`powershell-yaml`** (or equivalent) — [ADR 0009](../decisions/0009-yaml-on-windows-powershell-51.md). Do not require PowerShell 7+ for Task Scheduler packaging.

Document the module install step in `src/` when the loader is implemented ([#6](https://github.com/goichiro-y/audio-rebind/issues/6)).

## Validation

- Unknown keys: warn or reject (implementation chooses; prefer reject in v1 for typos).
- If `apps.enabled` is true and `processes` is empty → configuration error.
- `gracefulStopSeconds` (default **2**) is the max wait for an app to exit after a close request, before force-kill. Apps that exit sooner do not wait out the ceiling. `stopMode: force` skips that wait ([#13](https://github.com/goichiro-y/audio-rebind/issues/13), [#19](https://github.com/goichiro-y/audio-rebind/issues/19)).
- `windowAfterStart` (`leave` | `minimize`) on `apps` and/or each `processes[]` entry. A process entry overrides `apps.windowAfterStart` only when that entry sets the key. An entry that omits it inherits the apps-level value. When both omit it, the value is `leave`. `restore` is not implemented yet ([#16](https://github.com/goichiro-y/audio-rebind/issues/16), [#37](https://github.com/goichiro-y/audio-rebind/issues/37)).
- When `minimize`: start via Win32 `CreateProcess` with `SW_SHOWMINNOACTIVE` (avoid `Start-Process -WindowStyle Minimized` foreground flash) ([#21](https://github.com/goichiro-y/audio-rebind/issues/21)), then a short fallback poll still applies `SW_SHOWMINNOACTIVE` if a window appears later. **Limits:** Electron/Chromium apps often create their own window after launch and may still flash briefly; OS/app behavior can override the initial show flag. There is no reliable generic “tray-only / never paint” launch for arbitrary GUI apps.
- When minimizing: `minimizeTimeoutMs` (default **1200**) caps how long to wait for a window; **early-exit** after the first successful minimize. `minimizeNoWindowGiveUpMs` (default **400**) stops waiting sooner if no main window appears (e.g. helper/bridge processes) — [#18](https://github.com/goichiro-y/audio-rebind/issues/18).
- Stop path ([#19](https://github.com/goichiro-y/audio-rebind/issues/19)): `stopMode` = `graceful-then-force` (default) or `force` (skip CloseMainWindow wait). `forceStopSeconds` is the **max wait after force-kill** for processes to exit (poll), not a blind sleep. `postForceStopMs` (default 200) optional settle after force; `postStopDelayMs` (default 200) between stop phase and start (replaces a fixed 1s sleep).
- `delays.afterAudioEngineMs` is profile-driven (loader default / example **2000**). It is the wait after AudioEngine succeeds and before apps start. App stop may already be running during the engine restart ([#39](https://github.com/goichiro-y/audio-rebind/issues/39)). On hosts where endpoints reappear quickly, **500–1000** can cut wall-clock; if playback/capture is flaky after resume, raise it again ([#20](https://github.com/goichiro-y/audio-rebind/issues/20)).
- AudioEngine restarts wait for services to report **Running** (poll, short timeout) instead of fixed multi-second sleeps between restarts.
- Apps stop is **batched** across all `processes` entries (shared graceful/force wait), not sequential per entry.
