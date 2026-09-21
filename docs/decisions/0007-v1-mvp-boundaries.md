# 7. V1 MVP boundaries

- Status: Accepted
- Date: 2026-09-21

## Context

The product vision includes silent background behavior, built-in catalogs of apps/devices that typically need rebind, and a settings GUI for opt-out. Shipping all of that before a working personal pipeline would delay learning whether the ordered Engine → USB → Apps approach recovers audio on real hosts.

## Decision

**V1 (MVP)** is maintainer dogfood with these boundaries:

1. **Targets are explicit** in a YAML profile (process paths/names; USB HardwareId patterns when UsbDevice is enabled). No built-in “restart everything that looks like audio” catalog.
2. **No settings GUI** in V1. Edit the profile file (and optional helper scripts) instead.
3. **Automatic runs use Task Scheduler** on resume (ADR 0005), not a always-on agent process.
4. **Success bar:** after resume, with the maintainer profile, shared-mode WASAPI paths used by that profile work again without a reboot — documented via `local/` notes and a public CHANGELOG entry when exiting V1.

Catalog defaults, opt-out GUI, and always-on agents belong in **Later / V2+** on [ROADMAP.md](../../ROADMAP.md) until separately accepted.

## Consequences

- Implementation Issues for V1 stay scoped to orchestrator, profile loader, and trigger packaging.
- Expanding to “zero config” requires a new ADR and Milestone, not silent scope creep inside V1 Issues.
- Personal app paths and full InstanceIds remain in `local/` or private profiles — never in shared examples without placeholders.
