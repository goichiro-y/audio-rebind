# 7. V1 MVP boundaries

- Status: Accepted
- Date: 2026-09-21

## Context

The product vision includes silent background behavior, built-in catalogs of apps/devices that typically need rebind, and a settings GUI for opt-out. Shipping all of that before a working personal pipeline would delay learning whether the ordered Engine → USB → Apps approach recovers audio on real hosts.

## Decision

**V1 (MVP)** — shipped as semver **0.1.x** — is maintainer / personal dogfood with these boundaries:

1. **Targets are explicit** in a YAML profile (process paths/names; USB HardwareId patterns when UsbDevice is enabled). No built-in “restart everything that looks like audio” catalog.
2. **No settings GUI** in this MVP. Edit the profile file (and optional helper scripts) instead.
3. **Automatic runs use Task Scheduler** on resume (ADR 0005), not a always-on agent process.
4. **Success bar:** after resume, with the maintainer profile, shared-mode WASAPI paths used by that profile work again without a reboot — documented via `local/` notes and a public CHANGELOG entry when exiting 0.1.x.

**Version ladder** (do not rename catalog work to “V3”): **0.1.x** = this MVP; **0.x** = public-prep polish (incl. **0.3.0** thin install); **1.0.0** = polished strangers-can-follow-README; **V2** = catalog / GUI as semver **2.0.0** (Later). See [ROADMAP.md](../../ROADMAP.md).

Catalog defaults, opt-out GUI, and always-on agents belong in **Later / V2** on [ROADMAP.md](../../ROADMAP.md) until separately accepted.

## Consequences

- Implementation Issues for 0.1.x stayed scoped to orchestrator, profile loader, and trigger packaging.
- Public-prep work continues under **0.x** Issues without expanding into catalog/GUI.
- Expanding to “zero config” requires a new ADR and Milestone (`v2`), not silent scope creep inside 0.x Issues.
- Personal app paths and full InstanceIds remain in `local/` or private profiles — never in shared examples without placeholders.
