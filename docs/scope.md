# Scope

## In scope

- Run an ordered **rebind pipeline** after a power-related resume leaves shared-mode WASAPI sessions invalid:
  1. **Audio engine** — restart Windows Audio related services (e.g. `Audiosrv`, `AudioEndpointBuilder`).
  2. **USB device** (optional, profile) — restart / disable-enable a configured audio interface when software recovery is not enough.
  3. **Apps** (optional, profile) — stop and start configured processes so they open fresh WASAPI sessions.
- Configuration-driven profiles (device match rules, process names, delays, which steps are enabled).
- Logging suitable for diagnosing which step ran and whether it succeeded.
- Documentation that treats any vendor mixer (for example an AG03-class USB interface) as an **example profile target**, not hard-coded product identity.

### Pipeline vs automatic trigger

These are separate contracts:

| Layer | Meaning |
|-------|---------|
| **A — Pipeline** | What `Invoke-AudioRebind.ps1` does once started (engine → optional USB → optional apps). |
| **B — Automatic trigger** | When Task Scheduler starts that script without a manual run ([ADR 0005](decisions/0005-resume-trigger-task-scheduler.md)). |

#### A — Pipeline (supported)

Manual elevated runs are **supported** whenever sessions die after a power-related resume (classic sleep, hibernate, or similar). The pipeline does not care which ACPI name Windows used; if you can start the script, the same steps run.

#### B — Automatic trigger (0.1.x claims)

Auto triggers (one task, two subscriptions — [ADR 0005](decisions/0005-resume-trigger-task-scheduler.md), [#22](https://github.com/goichiro-y/audio-rebind/issues/22)):

1. `Microsoft-Windows-Power-Troubleshooter` **Event ID 1** (primary)
2. `Microsoft-Windows-Kernel-Power` **Event ID 107** (fallback when ID 1 is missing)

Overlap: `MultipleInstancesPolicy=IgnoreNew` plus ~120s orchestrator debounce so one resume that emits both events runs the pipeline at most once.

| Situation | Auto (Event ID 1 and/or Kernel-Power 107) | Notes |
|-----------|-------------------------------------------|--------|
| Classic sleep → resume (typical S3-class) | **Supported (verified on maintainer dogfood)** | Main 0.1.x battlefield; 107 covers hosts that skip Event ID 1 |
| Hibernate → resume (S4-class) | **Best-effort, unverified** | May fire if Event ID 1 and/or Kernel-Power 107 is logged — **not a maintainer commitment** to verify or officially support soon. Community reports / PRs that update this table with generalized findings are welcome (no full InstanceIds). |
| Shutdown / power-on (S5-class) | **Out of scope (auto)** | Cold start is a different model; use manual run if needed. No S5 auto trigger planned for now. |
| Unlock / sign-in only (no sleep resume event) | **Out of scope (auto)** | Needs a different trigger (ROADMAP Later: unlock / other). |
| Modern Standby (S0 low-power) | **Deferred** | OEM-dependent; not a near-term maintainer commitment. Community evidence welcome. |

**Hibernate / similar autos:** maintainer dogfood and claims center on classic sleep→resume. Do not treat hibernate (or Modern Standby) as “supported” in README copy. If both Event ID 1 and Kernel-Power 107 are missing on a host, unlock / other triggers stay Later. Contributions that only update this matrix from real-host observation are encouraged.

### Operator / privilege model

> **Supported operator model:** The person who installs and runs AudioRebind must be able to elevate (local administrator). This project does not target locked-down standard-user-only environments. Least-privilege / non-admin packaging is **not planned**.

Setup (task registration) and automatic runs assume an elevated scheduled task or an elevated manual invoke ([ADR 0005](decisions/0005-resume-trigger-task-scheduler.md)). Intended audience: people who administer their own PC (maintainer and similar).

| Commitment | Stance |
|------------|--------|
| **In scope (near term)** | Admin (or one-time admin registration) for setup and for the privileged steps (audio services / PnP). Daily resume can stay quiet after that registration — no UAC every wake. |
| **Out of scope (not a product promise)** | Completing the same recovery as a locked-down **standard user with no elevation**. Enterprise “standard-user-only” packaging. |
| **Not planned** | A least-privilege installer that splits elevation per step, or shipping a path where non-admins fully self-serve the same pipeline. Windows does not allow standard users to freely restart Audio services or toggle PnP; this project does not take on that product surface. |

Do **not** keep least-privilege installer on [ROADMAP Later](../ROADMAP.md) as a future improvement — it is declined for this product’s intended audience (people who administer their own PC).

## Version intent

Release and product-phase naming (full ladder: [ROADMAP.md](../ROADMAP.md)):

| Line | Intent | Tracking |
|------|--------|----------|
| **0.1.x** | Maintainer / personal dogfood MVP: **explicit** YAML targets (apps / USB), **no settings GUI**, resume via elevated Task Scheduler (not always-on). See [ADR 0007](decisions/0007-v1-mvp-boundaries.md). | Shipped [0.1.0](../CHANGELOG.md); Milestone `v1` closed |
| **0.x** (public prep) | Same MVP shape; polish docs/setup and dogfood follow-ups before calling the repo “ready for strangers.” | [ROADMAP](../ROADMAP.md) 0.x — [#15](https://github.com/goichiro-y/audio-rebind/issues/15) |
| **1.0.0** | First semver major aimed at README-led tryouts (still not catalog/GUI). | Not started |
| **V2** (product) | Defaults that “just work”: built-in catalog / heuristics + **opt-out**; settings GUI; always-on agent only if Event ID 1 is insufficient. | [ROADMAP](../ROADMAP.md) **Later** — no Issues until accepted |

0.1.x stays deliberately narrow so the ordered pipeline can be proven on a real host before investing in zero-config UX. Catalog work stays named **V2** (not renumbered to V3).

## Out of scope (initially)

- Replacing or resigning vendor kernel drivers.
- Guaranteeing audio through sleep without any resume action.
- Rewriting closed apps (dictation helpers, chat clients, browsers) to handle `DEVICE_INVALIDATED` themselves.
- A full virtual-cable / WASAPI proxy product (may be revisited later if the orchestrator is not enough).
- Non-Windows platforms (unless explicitly added later).
- MVP / 0.x settings GUI, built-in “restart all audio-looking apps” catalogs, or always-on agents (Later / **V2**).
- **Automatic** runs on shutdown/boot (S5), unlock-only, or Modern Standby (see table above). Manual pipeline runs remain available.
- Standard-user-only / no-elevation completion of the full pipeline; least-privilege “elevate only some steps” installer (see Operator / privilege model).

## Design stance

Prefer one orchestrator with three steps over three separate tools. Existing projects such as “restart Audiosrv on wake” or “restart mixer apps on wake” are complementary references, not the end state for this repository.
