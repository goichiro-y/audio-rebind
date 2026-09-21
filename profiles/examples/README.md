# Example profiles

Shared YAML examples with **placeholders only**. Copy into `local/profiles/` for personal use.

## What to fill in

Open [example-usb-interface.yaml](example-usb-interface.yaml) and complete the checklist at the top of the file:

1. `hardwareIdPatterns` (`VID_XXXX` / `PID_YYYY`) — see [discover-hardware-id](../../docs/guides/discover-hardware-id.md)
2. `apps.processes[].path` (or disable Apps)
3. Optionally turn off UsbDevice / set `windowAfterStart: minimize` / shorten stop timeouts

| File | Purpose |
|------|---------|
| [example-usb-interface.yaml](example-usb-interface.yaml) | USB HardwareId pattern + one app path (replace before run) |

Schema: [docs/specs/profile-spec.md](../../docs/specs/profile-spec.md). Layout: [ADR 0008](../../docs/decisions/0008-v1-repository-layout.md).
