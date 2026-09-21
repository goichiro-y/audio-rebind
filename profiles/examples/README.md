# Example profiles

Shared YAML examples with **placeholders only**. Copy into `local/profiles/` for personal use — never commit real VID/PID, InstanceIds, or personal absolute paths back into this folder.

## Checklist (first-time fill)

1. Copy [example-usb-interface.yaml](example-usb-interface.yaml) → `local/profiles/<your-name>.yaml`.
2. **VID/PID (`XXXX` / `YYYY`)** — read a HardwareId *pattern* (not full InstanceId) via [discover-hardware-id](../../docs/guides/discover-hardware-id.md). Put `USB\VID_xxxx&PID_yyyy` under `hardwareIdPatterns`.
3. **App path** — set `apps.processes[].path` to your executable, or set `apps.enabled: false`.
4. **USB toggle timing** — with `usbDevice.enabled: true`, disable/enable runs **when the orchestrator runs** (manual invoke or scheduled resume), after AudioEngine and before Apps. It does **not** run at sleep entry or when you only edit the YAML. If PnP disable fails on your host, set `usbDevice.enabled: false`.
5. Optional: `windowAfterStart: minimize`; shorter stop timeouts for Electron-style apps (see [src/README](../../src/README.md) Resume timing tips).

| File | Purpose |
|------|---------|
| [example-usb-interface.yaml](example-usb-interface.yaml) | USB HardwareId pattern + one app path (replace before run) |

Schema: [docs/specs/profile-spec.md](../../docs/specs/profile-spec.md). Layout: [ADR 0008](../../docs/decisions/0008-v1-repository-layout.md).
