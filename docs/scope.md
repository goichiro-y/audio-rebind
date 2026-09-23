# Scope

## In scope

- Run an ordered **rebind pipeline** after a power-related resume leaves shared-mode WASAPI sessions invalid:
  1. **Audio engine** — restart Windows Audio related services (e.g. `Audiosrv`, `AudioEndpointBuilder`). This is the current requirement.
  2. **Apps** (profile) — stop and start configured processes so they open fresh WASAPI sessions. Stop may run while the audio engine restarts. Start waits until that restart has succeeded and the profile's post-engine delay has elapsed. This is the current requirement when those apps are listed.
- Configuration-driven profiles (process names, delays, which steps are enabled).
- Logging suitable for diagnosing which step ran and whether it succeeded.
- Documentation that treats any vendor mixer (for example an AG03-class USB interface) as an **example of the problem**, not hard-coded product identity. Disable/enable of a USB device is not in the current pipeline ([Later](../ROADMAP.md)).

### Pipeline vs automatic trigger

These are separate contracts:

| Layer | Meaning |
|-------|---------|
| **A — Pipeline** | What `Invoke-AudioRebind.ps1` does once started (engine, then apps when listed). |
| **B — Automatic trigger** | When Task Scheduler starts that script without a manual run ([ADR 0005](decisions/0005-resume-trigger-task-scheduler.md)). |

#### A — Pipeline (supported)

Manual elevated runs are **supported** whenever sessions die after a power-related resume (classic sleep, hibernate, or similar). The pipeline does not care which ACPI name Windows used; if you can start the script, the same steps run.

#### B — Automatic trigger (0.1.x claims)

Auto triggers (one task, two subscriptions — [ADR 0005](decisions/0005-resume-trigger-task-scheduler.md), [#22](https://github.com/goichiro-y/audio-rebind/issues/22)):

1. `Microsoft-Windows-Power-Troubleshooter` **Event ID 1** (primary)
2. `Microsoft-Windows-Kernel-Power` **Event ID 107** (fallback when ID 1 is missing)

Overlap: `MultipleInstancesPolicy=IgnoreNew` plus ~120s orchestrator debounce so one resume that emits both events runs the pipeline at most once.

Automatic start happens only when Windows logs a **resume from sleep** (Event ID 1 and/or 107). The ACPI name in Settings is a hint, not a second trigger.

| What the PC is doing | ACPI | Automatic | Manual run |
|----------------------|------|-----------|------------|
| On, display off (not sleep) | S0 | No | Yes, if you start the script |
| Modern Standby | S0 low-power | Not a current promise | Yes, if you start the script |
| Sleep | S3 | **Yes** — this is the supported path | Yes |
| Hibernate | S4 | Maybe, if the same wake events are logged (not verified) | Yes |
| Shut down, then power on | S5 | No | Yes, if you start the script |
| Unlock / sign-in only (no sleep) | — | No | Yes, if you start the script |

S1 / S2 are unused on most PCs and are not a product claim.

Do not describe hibernate or Modern Standby as a supported automatic path. If a host never logs Event ID 1 or Kernel-Power 107, use a manual run; other automatic triggers stay [ROADMAP Later](../ROADMAP.md).

#### Updating the Automatic trigger table

If you observe a row that should change, a short Issue or PR that updates **one cell** with a **generalized** sentence is enough (e.g. which events fired on hibernate resume). Do **not** paste full InstanceIds, hostnames, usernames, or raw Event Viewer dumps ([local-notes](guides/local-notes.md)). No scheduler/orchestrator code unless separately agreed.

### Operator / privilege model

> **Supported operator model:** The person who installs and runs AudioRebind must be able to elevate (local administrator). This project does not target locked-down standard-user-only environments. Least-privilege / non-admin packaging is **not planned**.

Setup (task registration) and automatic runs assume an elevated scheduled task or an elevated manual invoke ([ADR 0005](decisions/0005-resume-trigger-task-scheduler.md)). Intended audience: people who administer their own PC (maintainer and similar).

| Commitment | Stance |
|------------|--------|
| **In scope (near term)** | Admin (or one-time admin registration) for setup and for the privileged steps (audio services, and stopping or starting listed apps). Daily resume can stay quiet after that registration — no UAC every wake. Thin elevated Install copies runtime to Program Files and keeps profiles under LocalAppData ([ADR 0010](decisions/0010-installed-layout-programfiles-localappdata.md)). |
| **Out of scope (not a product promise)** | Completing the same recovery as a locked-down **standard user with no elevation**. Enterprise “standard-user-only” packaging. |
| **Not planned** | A least-privilege installer that splits elevation per step, or shipping a path where non-admins fully self-serve the same pipeline. Windows does not allow standard users to freely restart Audio services; this project does not take on that product surface. |

Do **not** keep least-privilege installer on [ROADMAP Later](../ROADMAP.md) as a future improvement — it is declined for this product’s intended audience (people who administer their own PC). Semver **1.0.0** (catalog / settings GUI) still requires elevation ([ADR 0011](decisions/0011-version-ladder-1-0-catalog-gui.md)).

### Cautions (not out of scope)

Restarting Windows Audio can stop or destabilize **exclusive-mode** clients (DAWs and similar). That is a usage caution, not a product exclusion: the pipeline is for daily friction after classic sleep, not a studio-session companion. User-facing wording: [README.md](../README.md).

## Version intent

Release and product-phase naming (full ladder: [ROADMAP.md](../ROADMAP.md)):

| Line | Intent | Tracking |
|------|--------|----------|
| **0.1.x** | Maintainer / personal dogfood MVP: **explicit** YAML targets (apps / USB), **no settings GUI**, resume via elevated Task Scheduler (not always-on). See [ADR 0007](decisions/0007-v1-mvp-boundaries.md). | Shipped [0.1.0](../CHANGELOG.md); Milestone `0.1.0` closed |
| **0.x** (public prep) | Safe private→public flip (privacy scan); maintainer dogfood shipped as 0.2.0 | Done — [#15](https://github.com/goichiro-y/audio-rebind/issues/15) |
| **0.3.0** | Thin fixed install (Program Files + LocalAppData); clone path not required for the task | Shipped [0.3.0](../CHANGELOG.md); Milestone `0.3.0` — [#29](https://github.com/goichiro-y/audio-rebind/issues/29)–[#31](https://github.com/goichiro-y/audio-rebind/issues/31) |
| **0.4.0** | Same YAML product: double-click setup, USB step withdrawn, stop overlaps the engine, setup dialogs | Shipped [0.4.0](../CHANGELOG.md) |
| **0.3.x** | YAML-line polish (README-led tryouts, Install dogfood, first-run errors). Same shape; not a major. | **0.4.0** is the latest cut — [ROADMAP](../ROADMAP.md) |
| **1.0.0** | First semver major: catalog / heuristics + **opt-out**, and settings GUI so typical stacks need not hand-edit YAML. **Admin still required.** Do not ship before that line exists. | [ROADMAP](../ROADMAP.md) **Later** — no Issues until accepted |

0.1.x stays deliberately narrow so the ordered pipeline can be proven on a real host before investing in zero-config UX. Catalog / GUI is **1.0.0**, not a second public major ([ADR 0011](decisions/0011-version-ladder-1-0-catalog-gui.md)). A long **0.x** is accepted.

## Out of scope (initially)

- Replacing or resigning vendor kernel drivers.
- Guaranteeing audio through sleep without any resume action.
- Rewriting closed apps (dictation helpers, chat clients, browsers) to handle `DEVICE_INVALIDATED` themselves.
- A full virtual-cable / WASAPI proxy product (may be revisited later if the orchestrator is not enough).
- Non-Windows platforms (unless explicitly added later).
- MVP / 0.x settings GUI, built-in “restart all audio-looking apps” catalogs, or always-on agents (**1.0.0** / Later for catalog+GUI; always-on only if resume events are insufficient).
- **Automatic** runs on display-off-only (S0, not sleep), shutdown/boot (S5), unlock-only, or Modern Standby (see table above). Manual pipeline runs remain available.
- Watching or relaunching apps that **exited on their own** (including after display-off while the PC stayed awake). This is not a crashed-app watchdog; optional Apps recycle runs only when the pipeline itself starts.
- Standard-user-only / no-elevation completion of the full pipeline; least-privilege “elevate only some steps” installer (see Operator / privilege model).

## Design stance

Prefer one orchestrator for the current steps (audio engine, then apps) over separate tools. USB disable/enable is not in the current pipeline ([Later](../ROADMAP.md)). Existing projects such as “restart Audiosrv on wake” or “restart mixer apps on wake” are complementary references, not the end state for this repository.

Stay on classic sleep/resume rebind; do not grow into every silent playback or dead mic. User-facing wording: [README.md](../README.md). Why: [problem-and-motivation.md](problem-and-motivation.md). New automatic patterns (display-off, extra event IDs, health probes) need an explicit scope change before code.
