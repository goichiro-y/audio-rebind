# Resume pipeline specification

Thin contract for the orchestrator. Implementation languages and packaging may change; this behavior should not.

## Inputs

| Input | Description |
|-------|-------------|
| Trigger | Resume (required for automatic mode); optional manual invoke |
| Profile | Enables steps, delays, device match, app list |

## Steps

### 1. AudioEngine

- **Action:** Restart Windows Audio stack services used for shared WASAPI (at minimum `Audiosrv`; include `AudioEndpointBuilder` when required for a clean rebuild).
- **Success:** Services report running after restart; no hard requirement to prove audible output in v1.
- **Failure:** Log error; abort later steps only if the profile marks this step as required (default: required).

### 2. UsbDevice (optional)

- **Action:** Restart or disable/enable a matched PnP device (prefer the audio function or its USB composite parent when that is what recovers the device).
- **Success:** Device returns to a started state without requiring a machine reboot when the OS allows it.
- **Notes:** Some hosts leave devices in “reboot pending”; document that limitation. Do not commit machine-specific instance IDs into shared profiles without placeholders.

### 3. Apps (optional)

- **Action:** Graceful stop if practical, else force terminate; start configured executables again.
- **Success:** Target processes are running after the step (or were not configured).
- **Notes:** Multi-process apps (Electron + helper bridges) may need process-group or path-based rules.

## Ordering and timing

1. Run enabled steps in order 1 → 2 → 3.
2. Apply profile delays after each step so endpoints can reappear before apps attach.
3. Idempotent re-runs should be safe (restarting already-healthy services/apps is acceptable).

## Logging

Each run records: trigger time, profile name, step outcomes, and high-level errors. Do not write secrets or full raw ETW dumps into public logs by default.
