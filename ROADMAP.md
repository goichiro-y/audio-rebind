# Roadmap

Thin when/status overview. Durable specs: [`docs/`](docs/README.md). Adopted decisions: [`docs/decisions/`](docs/decisions/README.md). Placement rules: [CONTRIBUTING.md](CONTRIBUTING.md#where-work-lives). Actionable work: [GitHub Issues](https://github.com/goichiro-y/audio-rebind/issues).

**Committed work lives in Issues.** Uncommitted ideas stay in **Later** below — do not open Issues for them until accepted.

## Version ladder

Product phases use **semver** for releases and keep **V2** as the name for catalog/defaults work (do not renumber V2 → V3).

| Line | Meaning | Status |
|------|---------|--------|
| **0.1.x** | Maintainer / personal dogfood MVP ([ADR 0007](docs/decisions/0007-v1-mvp-boundaries.md)): explicit YAML, no GUI, Task Scheduler resume | **Shipped** as [0.1.0](CHANGELOG.md) (GitHub Milestone `v1` closed) |
| **0.x** (after 0.1) | **Public-prep** polish: clearer docs/setup UX, known dogfood follow-ups — still pre-1.0 | **Current** — shipped **[0.2.0](CHANGELOG.md)**; open [#15](https://github.com/goichiro-y/audio-rebind/issues/15); optional [#28](https://github.com/goichiro-y/audio-rebind/issues/28) |
| **1.0.0** | First release aimed at strangers following the README (same MVP shape; not catalog/GUI) | **Not started** |
| **V2** (product name) | Built-in app/USB catalog + opt-out; settings GUI and related | **Later** (not committed) — see below |

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

## 0.x — public prep (open)

| Item | Tracking |
|------|----------|
| Scan Issues/git for personal / host-private data | [#15](https://github.com/goichiro-y/audio-rebind/issues/15) |

Done in 0.x: [#13](https://github.com/goichiro-y/audio-rebind/issues/13), [#14](https://github.com/goichiro-y/audio-rebind/issues/14), [#16](https://github.com/goichiro-y/audio-rebind/issues/16), [#18](https://github.com/goichiro-y/audio-rebind/issues/18), [#19](https://github.com/goichiro-y/audio-rebind/issues/19), [#20](https://github.com/goichiro-y/audio-rebind/issues/20), [#21](https://github.com/goichiro-y/audio-rebind/issues/21) (no-activate CreateProcess launch), [#22](https://github.com/goichiro-y/audio-rebind/issues/22) (Kernel-Power 107 co-trigger), [#23](https://github.com/goichiro-y/audio-rebind/issues/23) (engine poll / batched stop / profile timing). Umbrella [#17](https://github.com/goichiro-y/audio-rebind/issues/17) split into #18–#21. Closed without blocking: [#12](https://github.com/goichiro-y/audio-rebind/issues/12). Comparison [#3](https://github.com/goichiro-y/audio-rebind/issues/3) done.

Optional further speed ideas (explicitly **may never do**, label `optional`): [#28](https://github.com/goichiro-y/audio-rebind/issues/28) (supersedes closed #24–#27).

Ship further **0.x** CHANGELOG entries as needed; **0.2.0** is the first post-0.1 usable dogfood cut. Do not call the line **1.0.0** until README-led tryouts feel ready for strangers.

## Done (summary)

| Item | Notes |
|------|--------|
| Docs bootstrap + ADRs 0001–0009 | Specs, placement rules, example profiles |
| Manual + scheduled orchestrator | `src/`; maintainer dogfood OK |
| 0.1.0 maintainer MVP exit | [CHANGELOG 0.1.0](CHANGELOG.md); Milestone `v1` closed |

## Later (not committed)

Do not file Issues for these until the version is accepted.

| Theme | Sketch |
|-------|--------|
| **V2** defaults | Built-in app/USB catalog + opt-out (GUI not required at first) |
| Settings GUI | Opt-out checkboxes / tray settings over the same profile model |
| Always-on agent | Only if Event ID 1 + Kernel-Power 107 still prove insufficient |
| Single-layer tool comparison | Done (optional) — [#3](https://github.com/goichiro-y/audio-rebind/issues/3); generalized in [architecture-overview](docs/architecture-overview.md) |
| Optional WASAPI proxy | Only if orchestrator is not enough (was [#9](https://github.com/goichiro-y/audio-rebind/issues/9)) |
| Secondary triggers | Unlock / other fallbacks if both Event ID 1 and Kernel-Power 107 miss (was [#10](https://github.com/goichiro-y/audio-rebind/issues/10); Kernel-Power 107 landed as [#22](https://github.com/goichiro-y/audio-rebind/issues/22)); not S5 auto for now |
| Modern Standby | Deferred; community evidence welcome (see [scope](docs/scope.md)) — not a near-term maintainer verification task |

**Not on Later (declined as maintainer work):** scheduled “verify hibernate (S4)” — auto on hibernate is best-effort/unverified only; updates via community Issue/PR to [scope](docs/scope.md). See Operator-style expectation notes there.

**Not on Later (declined):** least-privilege / standard-user-only packaging — see [docs/scope.md](docs/scope.md) Operator / privilege model (was sketched as [#8](https://github.com/goichiro-y/audio-rebind/issues/8)).

When an item is accepted: add Milestone (e.g. `v2` for catalog work, or track **1.0.0** via Issues), open Issues, and update specs/ADRs as needed.
