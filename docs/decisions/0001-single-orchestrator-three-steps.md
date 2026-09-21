# 1. Single orchestrator with three steps

- Status: Accepted
- Date: 2026-09-21

## Context

Resume audio failures need recovery at the Windows audio engine, sometimes at the USB device, and often inside long-lived apps. Existing utilities usually automate only one of those layers. Splitting AudioRebind into three public tools would recreate the fragmented workaround landscape.

## Decision

Ship **one** orchestrator product with three ordered steps (AudioEngine, UsbDevice, Apps), controlled by profiles. Do not publish separate repos/tools for each step as the primary UX.

## Consequences

- Clearer mental model and a single install path.
- Profiles must express optional steps instead of optional binaries.
- Implementation can still use internal modules that mirror the three steps.
