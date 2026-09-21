# 6. v1 step defaults for AudioEngine and UsbDevice

- Status: Accepted
- Date: 2026-09-21

## Context

The pipeline spec left AudioEndpointBuilder conditional (“when required for a clean rebuild”) and UsbDevice action ambiguous (restart vs disable/enable; audio function vs USB composite parent). Host baseline investigation showed a live MEDIA node matchable by HardwareId, with parent often a generic hub that must not be toggled.

## Decision

**AudioEngine (v1 default):** Always restart both `Audiosrv` and `AudioEndpointBuilder` (order: stop/restart in a documented safe sequence). Profiles may later narrow this; v1 does not require a heuristic for “when EndpointBuilder is needed.”

**UsbDevice (v1 default when enabled):**

- Match devices by **HardwareId pattern** (and prefer Started/OK instances).
- Act on the matched **audio function / USB audio device node**, not an upstream hub parent.
- Prefer **disable then enable** over a vague “restart” API when both are available.
- Document “reboot pending” as a known Windows limitation when PnP cannot complete.

## Consequences

- Simpler AudioEngine implementation and closer parity with common wake fixes that restart both services.
- Profile schema needs `hardwareIdPatterns` (or equivalent), not InstanceId lists for shared examples.
- Some hosts may do slightly more work than strictly necessary on Engine step; acceptable for v1 reliability.
