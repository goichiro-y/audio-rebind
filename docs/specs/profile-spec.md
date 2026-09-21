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
  usbDevice:
    enabled: false
    hardwareIdPatterns:    # matched against DEVPKEY_Device_HardwareIds
      - "USB\\VID_XXXX&PID_YYYY"
    # Prefer Started/OK instances; do not use full InstanceIds in shared examples
  apps:
    enabled: false
    processes:
      - path: "C:\\Path\\To\\App.exe"   # prefer path; name-only allowed
        # name: "App.exe"
    gracefulStopSeconds: 10
    forceStopSeconds: 5

delays:
  afterAudioEngineMs: 2000
  afterUsbDeviceMs: 2000
  afterAppsMs: 0
```

## Matching rules

1. `hardwareIdPatterns`: substring or wildcard match against any HardwareId on the device (document exact matcher in implementation). See [discover-hardware-id.md](../guides/discover-hardware-id.md).
2. Ignore non-Started / problem devices when a healthy match exists.
3. Never commit machine-specific full InstanceIds or personal usernames into shared profiles.

## YAML loading (v1)

**Baseline:** Windows PowerShell **5.1** + **`powershell-yaml`** (or equivalent) — [ADR 0009](../decisions/0009-yaml-on-windows-powershell-51.md). Do not require PowerShell 7+ for Task Scheduler packaging.

Document the module install step in `src/` when the loader is implemented ([#6](https://github.com/goichiro-y/audio-rebind/issues/6)).

## Validation

- Unknown keys: warn or reject (implementation chooses; prefer reject in v1 for typos).
- If `usbDevice.enabled` is true and `hardwareIdPatterns` is empty → configuration error.
- If `apps.enabled` is true and `processes` is empty → configuration error.
