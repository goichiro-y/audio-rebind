# Roadmap

Thin when/status overview. Durable specs: [`docs/`](docs/README.md). Adopted decisions: [`docs/decisions/`](docs/decisions/README.md). Placement rules: [CONTRIBUTING.md](CONTRIBUTING.md#where-work-lives). Actionable work: [GitHub Issues](https://github.com/goichiro-y/audio-rebind/issues).

**Committed work lives in Issues.** Uncommitted ideas stay in **Later** below — do not open Issues for them until accepted.

## Version ladder

Product phases use **semver** for releases and keep **V2** as the name for catalog/defaults work (do not renumber V2 → V3).

| Line | Meaning | Status |
|------|---------|--------|
| **0.1.x** | Maintainer / personal dogfood MVP ([ADR 0007](docs/decisions/0007-v1-mvp-boundaries.md)): explicit YAML, no GUI, Task Scheduler resume | **Shipped** as [0.1.0](CHANGELOG.md) (GitHub Milestone `0.1.0` closed) |
| **0.x** (after 0.1) | **Public-prep** for a safe private→public flip (privacy scan, honesty in Status) — not stranger UX polish | **Ready to flip** after **[0.2.0](CHANGELOG.md)** + [#15](https://github.com/goichiro-y/audio-rebind/issues/15) done (Milestone `0.2.0` closed) |
| **0.3.0** | Thin fixed install (Program Files + LocalAppData); clone path no longer required for the scheduled task | **Shipped** as [0.3.0](CHANGELOG.md) (Milestone [`0.3.0`](https://github.com/goichiro-y/audio-rebind/milestone/3): [#29](https://github.com/goichiro-y/audio-rebind/issues/29)–[#31](https://github.com/goichiro-y/audio-rebind/issues/31)) |
| **1.0.0** | First semver major aimed at polished README-led tryouts (same MVP shape; still not catalog/GUI) | **Not started** — after further Install-path dogfood / stranger-friction polish |
| **V2** (product name) | Built-in app/USB catalog + opt-out; settings GUI and related — ship as semver **2.0.0** (not 1.1.x): breaks the “explicit YAML only / no catalog” product promise of the 1.x line | **Later** (not committed) — see below |

Power-transition and privilege contracts: [docs/scope.md](docs/scope.md).

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

Gate for flipping the repo public. Maintainer-usable dogfood is **0.2.0**. Privacy scan [#15](https://github.com/goichiro-y/audio-rebind/issues/15) is **done**. Thin Install landed as **0.3.0**; polished stranger **1.0.0** is still ahead.

| Item | Tracking |
|------|----------|
| Scan Issues/git for personal / host-private data | Done — [#15](https://github.com/goichiro-y/audio-rebind/issues/15) |

Done in 0.x: [#13](https://github.com/goichiro-y/audio-rebind/issues/13), [#14](https://github.com/goichiro-y/audio-rebind/issues/14), [#15](https://github.com/goichiro-y/audio-rebind/issues/15), [#16](https://github.com/goichiro-y/audio-rebind/issues/16), [#18](https://github.com/goichiro-y/audio-rebind/issues/18), [#19](https://github.com/goichiro-y/audio-rebind/issues/19), [#20](https://github.com/goichiro-y/audio-rebind/issues/20), [#21](https://github.com/goichiro-y/audio-rebind/issues/21) (no-activate CreateProcess launch), [#22](https://github.com/goichiro-y/audio-rebind/issues/22) (Kernel-Power 107 co-trigger), [#23](https://github.com/goichiro-y/audio-rebind/issues/23) (engine poll / batched stop / profile timing). Umbrella [#17](https://github.com/goichiro-y/audio-rebind/issues/17) split into #18–#21. Closed without blocking: [#12](https://github.com/goichiro-y/audio-rebind/issues/12). Comparison [#3](https://github.com/goichiro-y/audio-rebind/issues/3) done. Thin install: [#29](https://github.com/goichiro-y/audio-rebind/issues/29)–[#31](https://github.com/goichiro-y/audio-rebind/issues/31) as **0.3.0**.

Public flip is OK on clone+Register or Install. Further stranger polish belongs under **1.0.0**.

## 0.3.0 — thin install (shipped)

Same MVP shape (YAML, Task Scheduler, admin). Thin fixed install so the task is not stuck on “move the folder and it dies.” Layout: [ADR 0010](docs/decisions/0010-installed-layout-programfiles-localappdata.md).

| Item | Tracking |
|------|----------|
| Packaging layout: Program Files runtime + LocalAppData settings (ADR/docs) | Done — [#29](https://github.com/goichiro-y/audio-rebind/issues/29) |
| Implement Install/Uninstall + task paths for that layout | Done — [#30](https://github.com/goichiro-y/audio-rebind/issues/30) |
| README Install Quick start (after thin install) | Done — [#31](https://github.com/goichiro-y/audio-rebind/issues/31) |

## 1.0.0 — strangers can follow the README (not started)

Polished README-led tryouts on top of **0.3.0** install (Install-path dogfood, clearer first-run failures, etc.). Catalog/GUI stay **V2**.

## Done (summary)

| Item | Notes |
|------|--------|
| Docs bootstrap + ADRs 0001–0010 | Specs, placement rules, example profiles, installed layout |
| Manual + scheduled orchestrator | `src/`; maintainer dogfood OK |
| 0.1.0 maintainer MVP exit | [CHANGELOG 0.1.0](CHANGELOG.md); Milestone `0.1.0` closed |
| 0.3.0 thin install + README Install path | [CHANGELOG 0.3.0](CHANGELOG.md); Milestone `0.3.0` |

## Later (not committed)

Do not file Issues for these until the version is accepted.

| Theme | Sketch |
|-------|--------|
| **V2** defaults | Built-in app/USB catalog + opt-out (GUI not required at first) |
| Settings GUI | Opt-out checkboxes / tray settings over the same profile model (edits LocalAppData YAML; does not replace [#29](https://github.com/goichiro-y/audio-rebind/issues/29)–[#30](https://github.com/goichiro-y/audio-rebind/issues/30) thin install) |
| Always-on agent | Only if Event ID 1 + Kernel-Power 107 still prove insufficient |
| Single-layer tool comparison | Done (optional) — [#3](https://github.com/goichiro-y/audio-rebind/issues/3); generalized in [architecture-overview](docs/architecture-overview.md) |
| Optional WASAPI proxy | Only if orchestrator is not enough (was [#9](https://github.com/goichiro-y/audio-rebind/issues/9)) |
| Secondary triggers | Unlock / other fallbacks if both Event ID 1 and Kernel-Power 107 miss (was [#10](https://github.com/goichiro-y/audio-rebind/issues/10); Kernel-Power 107 landed as [#22](https://github.com/goichiro-y/audio-rebind/issues/22)); not S5 auto for now |
| Modern Standby | Deferred; community evidence welcome (see [scope](docs/scope.md)) — not a near-term maintainer verification task |
| Optional further resume-speed ideas | May never do (profile micro-timing, Apps stop refinements, async overlap, latency measurement). Was [#28](https://github.com/goichiro-y/audio-rebind/issues/28) / closed #24–#27 — not an open backlog |

**Not on Later (declined as maintainer work):** scheduled “verify hibernate (S4)” — auto on hibernate is best-effort/unverified only; updates via community Issue/PR to [scope](docs/scope.md). See Operator-style expectation notes there.

**Not on Later (declined):** least-privilege / standard-user-only packaging — see [docs/scope.md](docs/scope.md) Operator / privilege model (was sketched as [#8](https://github.com/goichiro-y/audio-rebind/issues/8)).

When an item is accepted: add Milestone (e.g. `1.0.0` or `2.0.0` for catalog work), open Issues, and update specs/ADRs as needed.
