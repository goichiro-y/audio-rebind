# Scope

## In scope

- Detect Windows resume from sleep / hibernate (or an equivalent trigger).
- Run an ordered **rebind pipeline**:
  1. **Audio engine** — restart Windows Audio related services (e.g. `Audiosrv`, `AudioEndpointBuilder`).
  2. **USB device** (optional, profile) — restart / disable-enable a configured audio interface when software recovery is not enough.
  3. **Apps** (optional, profile) — stop and start configured processes so they open fresh WASAPI sessions.
- Configuration-driven profiles (device match rules, process names, delays, which steps are enabled).
- Logging suitable for diagnosing which step ran and whether it succeeded.
- Documentation that treats any vendor mixer (for example an AG03-class USB interface) as an **example profile target**, not hard-coded product identity.

## Out of scope (initially)

- Replacing or resigning vendor kernel drivers.
- Guaranteeing audio through sleep without any resume action.
- Rewriting closed apps (dictation helpers, chat clients, browsers) to handle `DEVICE_INVALIDATED` themselves.
- A full virtual-cable / WASAPI proxy product (may be revisited later if the orchestrator is not enough).
- Non-Windows platforms (unless explicitly added later).

## Design stance

Prefer one orchestrator with three steps over three separate tools. Existing projects such as “restart Audiosrv on wake” or “restart mixer apps on wake” are complementary references, not the end state for this repository.
