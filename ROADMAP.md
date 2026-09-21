# Roadmap

Thin when/status overview. Durable specs: [`docs/`](docs/README.md). Adopted decisions: [`docs/decisions/`](docs/decisions/README.md). Placement rules: [CONTRIBUTING.md](CONTRIBUTING.md#where-work-lives). Actionable work: [GitHub Issues](https://github.com/goichiro-y/audio-rebind/issues).

**Committed work lives in Issues.** Uncommitted ideas stay in **Later** below — do not open Issues for them until accepted.

## V1 (MVP) — shipped 0.1.0

Maintainer dogfood: explicit YAML profile (apps / USB), no settings GUI, resume via elevated Task Scheduler (not an always-on agent). See [ADR 0007](docs/decisions/0007-v1-mvp-boundaries.md). Layout: [ADR 0008](docs/decisions/0008-v1-repository-layout.md).

### Delivery sequence

| # | Phase | Status | Tracking |
|---|--------|--------|----------|
| 1 | Host investigation (layer isolation after resume) | Done | [#1](https://github.com/goichiro-y/audio-rebind/issues/1), [#2](https://github.com/goichiro-y/audio-rebind/issues/2) |
| 2 | Resume orchestrator core (PowerShell) | Done | [#5](https://github.com/goichiro-y/audio-rebind/issues/5) — `src/Invoke-AudioRebind.ps1` |
| 3 | Profile loader + explicit personal targets | Done | [#6](https://github.com/goichiro-y/audio-rebind/issues/6) |
| 4 | Resume trigger packaging (Task Scheduler) | Done | [#7](https://github.com/goichiro-y/audio-rebind/issues/7) |
| 5 | Dogfood on maintainer machine | Done | Auto task on resume; playback quick; capture apps after recycle |
| 6 | V1 exit (works, docs, CHANGELOG) | Done | [#11](https://github.com/goichiro-y/audio-rebind/issues/11); [CHANGELOG 0.1.0](CHANGELOG.md) |

Milestone [v1](https://github.com/goichiro-y/audio-rebind/milestone/1) closed with 0.1.0.

### Post-V1 polish (still open)

| Item | Tracking |
|------|----------|
| UsbDevice disable refusal / pnputil | [#12](https://github.com/goichiro-y/audio-rebind/issues/12) |
| Faster resume (skip bad USB / shorter graceful stop) | [#13](https://github.com/goichiro-y/audio-rebind/issues/13) |

## Done (summary)

| Item | Notes |
|------|--------|
| Docs bootstrap + ADRs 0001–0009 | Specs, placement rules, example profiles |
| Manual + scheduled orchestrator | `src/`; maintainer dogfood OK |
| V1 MVP exit | Tagged as release notes in CHANGELOG **0.1.0** |

## Later (not committed)

Do not file Issues for these until the version is accepted.

| Theme | Sketch |
|-------|--------|
| V2 defaults | Built-in app/USB catalog + opt-out (GUI not required at first) |
| Settings GUI | Opt-out checkboxes / tray settings over the same profile model |
| Always-on agent | Only if Power-Troubleshooter Event ID 1 proves insufficient |
| Single-layer tool comparison | Optional investigation ([#3](https://github.com/goichiro-y/audio-rebind/issues/3)) |
| Least-privilege installer | Elevate only steps that need it (was [#8](https://github.com/goichiro-y/audio-rebind/issues/8)) |
| Optional WASAPI proxy | Only if orchestrator is not enough (was [#9](https://github.com/goichiro-y/audio-rebind/issues/9)) |
| Secondary triggers | Unlock / other fallbacks (was [#10](https://github.com/goichiro-y/audio-rebind/issues/10)) |

When an item is accepted: add Milestone `v2` (or later), open Issues, and update specs/ADRs as needed.
