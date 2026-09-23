# Resume pipeline specification

Thin contract for the orchestrator. v1 implementation is PowerShell ([ADR 0003](../decisions/0003-v1-powershell-orchestrator.md)); packaging may still evolve. This behavior should not.

## Inputs

| Input | Description |
|-------|-------------|
| Trigger | Resume (required for automatic mode); optional manual invoke |
| Profile | Enables steps, delays, app list |

## Steps

### 1. AudioEngine

- **Action:** Restart Windows Audio stack services used for shared WASAPI. **v1 default:** restart both `Audiosrv` and `AudioEndpointBuilder` ([ADR 0006](../decisions/0006-v1-step-defaults-engine-usb.md)).
- **Success:** Services report running after restart; no hard requirement to prove audible output in v1.
- **Failure:** Log error; abort later steps only if the profile marks this step as required (default: required).

### 2. Apps (optional)

- **Action:** Graceful stop if practical, else force terminate; start configured executables again.
- **Success:** Target processes are running after the step (or were not configured).
- **Notes:** Multi-process apps (Electron + helper bridges) may need process-group or path-based rules.

## Ordering and timing

1. When AudioEngine and Apps are both enabled, stop configured apps while AudioEngine restarts. Stopping does not wait for the endpoint ([#39](https://github.com/goichiro-y/audio-rebind/issues/39)).
2. Start configured apps only after AudioEngine succeeds and `delays.afterAudioEngineMs` has elapsed, and after that stop has finished. The delay is so endpoints can reappear before apps attach.
3. If AudioEngine fails, do not start apps. A stop that already started is allowed to finish.
4. If AudioEngine is disabled, stop apps and then start them, in that order.
5. Idempotent re-runs should be safe (restarting already-healthy services/apps is acceptable).

## Logging

| Topic | v1 contract |
|-------|-------------|
| Content | Trigger time, profile name/path, step outcomes, high-level errors |
| Location | Per-user directory under `%LOCALAPPDATA%\AudioRebind\logs\` (create if missing). One text log file per run (timestamped name). |
| Secrets | Do not write secrets or raw ETW dumps by default |

## Exit codes

| Code | Meaning |
|------|---------|
| `0` | Run finished; every **required** enabled step succeeded (optional steps may have been skipped or soft-failed per fail-soft rules) |
| `1` | Usage / profile validation error (bad args, missing profile, schema error) |
| `2` | A **required** step failed |
| `3` | Unexpected terminating error |

Scheduled tasks should treat non-zero as failure for Event Viewer / task history.
