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

## Version intent

| Version | Intent | Tracking |
|---------|--------|----------|
| **V1 (MVP)** | Maintainer dogfood: **explicit** YAML targets (apps / USB), **no settings GUI**, resume via elevated Task Scheduler (not always-on). See [ADR 0007](decisions/0007-v1-mvp-boundaries.md). | [ROADMAP](../ROADMAP.md) V1 + Milestone `v1` |
| **V2+ (not committed)** | Defaults that “just work”: built-in catalog / heuristics + **opt-out**; settings GUI; always-on agent only if Event ID 1 is insufficient. | [ROADMAP](../ROADMAP.md) **Later** — no Issues until accepted |

V1 stays deliberately narrow so the ordered pipeline can be proven on a real host before investing in zero-config UX.

## Out of scope (initially)

- Replacing or resigning vendor kernel drivers.
- Guaranteeing audio through sleep without any resume action.
- Rewriting closed apps (dictation helpers, chat clients, browsers) to handle `DEVICE_INVALIDATED` themselves.
- A full virtual-cable / WASAPI proxy product (may be revisited later if the orchestrator is not enough).
- Non-Windows platforms (unless explicitly added later).
- V1 settings GUI, built-in “restart all audio-looking apps” catalogs, or always-on agents (Later / V2+).

## Design stance

Prefer one orchestrator with three steps over three separate tools. Existing projects such as “restart Audiosrv on wake” or “restart mixer apps on wake” are complementary references, not the end state for this repository.
