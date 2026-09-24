# Roadmap

Thin when/status overview. Durable specs: [`docs/`](docs/README.md). Adopted decisions: [`docs/decisions/`](docs/decisions/README.md). Placement rules: [.github/CONTRIBUTING.md](.github/CONTRIBUTING.md#where-work-lives). Actionable work: [GitHub Issues](https://github.com/goichiro-y/audio-rebind/issues).

**Committed work lives in Issues.** Uncommitted ideas stay in **Later** below — do not open Issues for them until accepted.

## Version ladder

Product phases use **semver**. The next public major is **1.0.0** (catalog + settings GUI). There is no headline **2.0.0** / **V2** destination. Decision: [ADR 0011](docs/decisions/0011-version-ladder-1-0-catalog-gui.md).

| Line | Meaning | Status |
|------|---------|--------|
| **0.1.x** | Maintainer / personal dogfood MVP ([ADR 0007](docs/decisions/0007-v1-mvp-boundaries.md)): explicit YAML, no GUI, Task Scheduler resume | **Shipped** as [0.1.0](CHANGELOG.md) (GitHub Milestone `0.1.0` closed) |
| **0.x** (after 0.1) | **Public-prep** for a safe private→public flip (privacy scan, honesty in Status) | **Ready to flip** after **[0.2.0](CHANGELOG.md)** + [#15](https://github.com/goichiro-y/audio-rebind/issues/15) done (Milestone `0.2.0` closed) |
| **0.3.0** | Thin fixed install (Program Files + LocalAppData); clone path no longer required for the scheduled task | **Shipped** as [0.3.0](CHANGELOG.md) (Milestone [`0.3.0`](https://github.com/goichiro-y/audio-rebind/milestone/3): [#29](https://github.com/goichiro-y/audio-rebind/issues/29)–[#31](https://github.com/goichiro-y/audio-rebind/issues/31)) |
| **0.x** after **0.3.0** | YAML-line polish on the same product (explicit YAML, admin, Task Scheduler). A long **0.x** is OK | Latest shipped cut is **0.4.0**. The open line is **0.5.0**. Hand-edit error copy and README YAML lessons are not opened |
| **0.4.0** | Same YAML product after that install: double-click setup, USB step withdrawn, stop overlaps the engine, setup dialogs | **Shipped** as [0.4.0](CHANGELOG.md) (Milestone [`0.4.0`](https://github.com/goichiro-y/audio-rebind/milestone/4): [#32](https://github.com/goichiro-y/audio-rebind/issues/32), [#34](https://github.com/goichiro-y/audio-rebind/issues/34), [#37](https://github.com/goichiro-y/audio-rebind/issues/37)–[#39](https://github.com/goichiro-y/audio-rebind/issues/39)) |
| **0.5.0** | Next 0.x cut after 0.4.0. Same YAML product. Not the catalog or settings GUI | **Not shipped.** Milestone [`0.5.0`](https://github.com/goichiro-y/audio-rebind/milestone/5) is open ([#35](https://github.com/goichiro-y/audio-rebind/issues/35), [#40](https://github.com/goichiro-y/audio-rebind/issues/40)) |
| **1.0.0** | First semver major: catalog / defaults + settings GUI so typical stacks need not hand-edit YAML. **Admin still required.** Do not ship until that line exists | **Not a release yet.** Related work is [#33](https://github.com/goichiro-y/audio-rebind/issues/33). The issues do not decide this name. A later check, outside the issues, decides when a release may be called **1.0.0** |

Power-transition and privilege contracts: [docs/scope.md](docs/scope.md). Elevation is required on **0.x and 1.0.0**.

## 0.1.x — maintainer MVP (shipped)

Explicit YAML profile (apps / USB), no settings GUI, resume via elevated Task Scheduler (not an always-on agent). See [ADR 0007](docs/decisions/0007-v1-mvp-boundaries.md). Layout: [ADR 0008](docs/decisions/0008-v1-repository-layout.md).

### Delivery sequence (done)

| # | Phase | Status | Tracking |
|---|--------|--------|----------|
| 1 | Host investigation (layer isolation after resume) | Done | [#1](https://github.com/goichiro-y/audio-rebind/issues/1), [#2](https://github.com/goichiro-y/audio-rebind/issues/2) |
| 2 | Resume orchestrator core (PowerShell) | Done | [#5](https://github.com/goichiro-y/audio-rebind/issues/5) — `src/Invoke-AudioRebind.ps1` |
| 3 | Profile loader + explicit personal targets | Done | [#6](https://github.com/goichiro-y/audio-rebind/issues/6) |
| 4 | Resume trigger packaging (Task Scheduler) | Done | [#7](https://github.com/goichiro-y/audio-rebind/issues/7) |
| 5 | Dogfood on maintainer machine | Done | Auto task on resume; playback quick; capture apps after recycle |
| 6 | 0.1 exit (works, docs, CHANGELOG) | Done | [#11](https://github.com/goichiro-y/audio-rebind/issues/11); [CHANGELOG 0.1.0](CHANGELOG.md) |

## 0.x — public prep (done for flip)

Gate for flipping the repo public. Maintainer-usable dogfood is **0.2.0**. Privacy scan [#15](https://github.com/goichiro-y/audio-rebind/issues/15) is **done**. Thin Install landed as **0.3.0**. Further YAML tryout polish stays on **0.x** after 0.3.0 (**0.4.0** is one cut). **1.0.0** is catalog + settings GUI.

| Item | Tracking |
|------|----------|
| Scan Issues/git for personal / host-private data | Done — [#15](https://github.com/goichiro-y/audio-rebind/issues/15) |

Done in 0.x: [#13](https://github.com/goichiro-y/audio-rebind/issues/13), [#14](https://github.com/goichiro-y/audio-rebind/issues/14), [#15](https://github.com/goichiro-y/audio-rebind/issues/15), [#16](https://github.com/goichiro-y/audio-rebind/issues/16), [#18](https://github.com/goichiro-y/audio-rebind/issues/18), [#19](https://github.com/goichiro-y/audio-rebind/issues/19), [#20](https://github.com/goichiro-y/audio-rebind/issues/20), [#21](https://github.com/goichiro-y/audio-rebind/issues/21) (no-activate CreateProcess launch), [#22](https://github.com/goichiro-y/audio-rebind/issues/22) (Kernel-Power 107 co-trigger), [#23](https://github.com/goichiro-y/audio-rebind/issues/23) (engine poll / batched stop / profile timing). Umbrella [#17](https://github.com/goichiro-y/audio-rebind/issues/17) split into #18–#21. Closed without blocking: [#12](https://github.com/goichiro-y/audio-rebind/issues/12). Comparison [#3](https://github.com/goichiro-y/audio-rebind/issues/3) done. Thin install: [#29](https://github.com/goichiro-y/audio-rebind/issues/29)–[#31](https://github.com/goichiro-y/audio-rebind/issues/31) as **0.3.0**.

Public flip is OK on clone+Register or Install.

## 0.3.0 — thin install (shipped)

Same MVP shape (YAML, Task Scheduler, admin). Thin fixed install so the task is not stuck on “move the folder and it dies.” Layout: [ADR 0010](docs/decisions/0010-installed-layout-programfiles-localappdata.md).

| Item | Tracking |
|------|----------|
| Packaging layout: Program Files runtime + LocalAppData settings (ADR/docs) | Done — [#29](https://github.com/goichiro-y/audio-rebind/issues/29) |
| Implement Install/Uninstall + task paths for that layout | Done — [#30](https://github.com/goichiro-y/audio-rebind/issues/30) |
| README Install Quick start (after thin install) | Done — [#31](https://github.com/goichiro-y/audio-rebind/issues/31) |

## Open work

[#33](https://github.com/goichiro-y/audio-rebind/issues/33), [#35](https://github.com/goichiro-y/audio-rebind/issues/35), and [#36](https://github.com/goichiro-y/audio-rebind/issues/36) do not depend on each other. Any can be done first. They do not decide a version number.

| Issue | Work |
|-------|------|
| [#33](https://github.com/goichiro-y/audio-rebind/issues/33) | Settings window: choose apps, write the existing LocalAppData profile |
| [#35](https://github.com/goichiro-y/audio-rebind/issues/35) | Setup failures (execution policy, `powershell-yaml`, Program Files write, task registration) show a dialog |
| [#36](https://github.com/goichiro-y/audio-rebind/issues/36) | Remove `AudioRebind-Resume` from a window. On open, unregister it when its action file is already missing |

Hand-edit first-run copy and a README YAML lesson are not opened. Display-off auto, a hibernate verification campaign, standard-user-only packaging, and an always-on agent stay out of these issues.

## Done (summary)

| Item | Notes |
|------|--------|
| Docs bootstrap + ADRs 0001–0011 | Specs, placement rules, example profiles, installed layout, version ladder |
| Manual + scheduled orchestrator | `src/`; maintainer dogfood OK |
| 0.1.0 maintainer MVP exit | [CHANGELOG 0.1.0](CHANGELOG.md); Milestone `0.1.0` closed |
| 0.3.0 thin install + README Install path | [CHANGELOG 0.3.0](CHANGELOG.md); Milestone `0.3.0` |
| Double-click setup | Done — [#34](https://github.com/goichiro-y/audio-rebind/issues/34). Decline shows that admin is required. Accept copies to Program Files and registers the task |
| Program Files task does not depend on the clone | Done — [#32](https://github.com/goichiro-y/audio-rebind/issues/32). Task action is under Program Files. One classic sleep/resume started the pipeline and finished with exit 0 |
| Process inherits apps windowAfterStart | Done — [#37](https://github.com/goichiro-y/audio-rebind/issues/37). An entry overrides only when it sets the key. Both omitted stays `leave` |
| Setup completion dialog | Done — [#38](https://github.com/goichiro-y/audio-rebind/issues/38). Success shows two short lines. Closing the dialog ends the window |
| Setup notice codes | Done — [#40](https://github.com/goichiro-y/audio-rebind/issues/40). Each current setup dialog keeps its text and ends with a `SETUP-` code from one table |
| App stop overlaps the audio restart | Done — [#39](https://github.com/goichiro-y/audio-rebind/issues/39). One classic sleep: stop ran during the engine restart, start was after the attach delay, exit 0 |

## Later (not committed)

Do not file Issues for these until the version is accepted.

| Theme | Sketch |
|-------|--------|
| Always-on agent | Only if Event ID 1 + Kernel-Power 107 still prove insufficient — not a product version |
| Single-layer tool comparison | Done (optional) — [#3](https://github.com/goichiro-y/audio-rebind/issues/3); generalized in [architecture-overview](docs/architecture-overview.md) |
| Optional WASAPI proxy | Only if orchestrator is not enough (was [#9](https://github.com/goichiro-y/audio-rebind/issues/9)) |
| Secondary triggers | Unlock / other fallbacks if both Event ID 1 and Kernel-Power 107 miss (was [#10](https://github.com/goichiro-y/audio-rebind/issues/10); Kernel-Power 107 landed as [#22](https://github.com/goichiro-y/audio-rebind/issues/22)); not S5 auto for now |
| Modern Standby | Deferred; community evidence welcome (see [scope](docs/scope.md)) — not a near-term maintainer verification task |
| Optional further resume-speed ideas | May never do (profile micro-timing, Apps stop refinements, latency measurement, async minimize, playback-first, thin hot-path profile). Engine and app-stop overlap shipped as [#39](https://github.com/goichiro-y/audio-rebind/issues/39). Was [#28](https://github.com/goichiro-y/audio-rebind/issues/28) / closed #24–#27 — the rest is not an open backlog |
| Task identity beyond the name | [#36](https://github.com/goichiro-y/audio-rebind/issues/36) finds `AudioRebind-Resume` by name. Enough while that name is unchanged. Later only: follow the task after a rename, and do not remove a different task that reused the same name. Not current work |
| Log retention | Each run adds a file under `%LOCALAPPDATA%\AudioRebind\logs\`. No deletion rule. Harmless short-term; files accumulate over years. Not current work |
| Re-register overwrites task edits | `Register-AudioRebindTask.ps1` replaces the same task name with `-Force`. A person who edited triggers in Task Scheduler loses that on the next setup. Later: warn before overwrite. Not current work |
| Windows 11 dialog style | Setup notices use the classic `MessageBox`. A Windows 11 card dialog (WinUI `ContentDialog`) waits until the settings window (#33, **1.0.0** GUI) chooses a UI stack. Not current work; do not file an Issue for the decline dialog alone |
| USB disable/enable as a required fix | Not in the current pipeline. Why it was withdrawn: [ADR 0012](docs/decisions/0012-withdraw-usb-disable-enable.md). Bring it back only after a case is separated where Windows Audio restart and app restart both fail, and disable/enable is what recovers it. Do not file an Issue until then. Not current work |

**Not on Later (declined as maintainer work):** scheduled “verify hibernate (S4)” — auto on hibernate is best-effort/unverified only; updates via community Issue/PR to [scope](docs/scope.md). See Operator-style expectation notes there.

**Not on Later (declined):** least-privilege / standard-user-only packaging — see [docs/scope.md](docs/scope.md) Operator / privilege model (was sketched as [#8](https://github.com/goichiro-y/audio-rebind/issues/8)).

When an item is accepted: open an Issue. When a version is released, close its milestone and do not assign that milestone afterward. At the same time, open the next version's milestone, titled with that version and no `v` prefix. An issue closed as completed after the release gets that open milestone. Do not assign a milestone to an open issue or to an issue closed as not planned. Closed as not planned is the mark that the issue was not done. Naming a release **1.0.0** is a separate check after the work has moved, not a field on the Issue. The open line now is **0.5.0**, not **1.0.0**.
