# Roadmap

Thin when/status overview. Durable specs: [`docs/`](docs/README.md). Adopted decisions: [`docs/decisions/`](docs/decisions/README.md). Placement rules: [CONTRIBUTING.md](CONTRIBUTING.md#where-work-lives). Actionable work: [GitHub Issues](https://github.com/goichiro-y/audio-rebind/issues) + Milestone `v1`.

**Committed work lives in Issues.** Uncommitted ideas stay in **Later** below — do not open Issues for them until accepted.

## V1 (MVP)

Maintainer dogfood: explicit YAML profile (apps / USB), no settings GUI, resume via elevated Task Scheduler (not an always-on agent). See [ADR 0007](docs/decisions/0007-v1-mvp-boundaries.md). Layout: [ADR 0008](docs/decisions/0008-v1-repository-layout.md).

### Delivery sequence

| # | Phase | Status | Tracking |
|---|--------|--------|----------|
| 1 | Host investigation (layer isolation after resume) | Done | [#1](https://github.com/goichiro-y/audio-rebind/issues/1), [#2](https://github.com/goichiro-y/audio-rebind/issues/2) — Engine restores playback; Apps recycle restores capture dictation; Event ID 1 OK (`local/` for host detail) |
| 2 | Resume orchestrator core (PowerShell) | Planned | [#5](https://github.com/goichiro-y/audio-rebind/issues/5) — include PnP/service spikes |
| 3 | Profile loader + explicit personal targets | Planned | [#6](https://github.com/goichiro-y/audio-rebind/issues/6) — YAML via powershell-yaml on PS 5.1 (ADR 0009); example in `profiles/examples/` |
| 4 | Resume trigger packaging (Task Scheduler) | Planned | [#7](https://github.com/goichiro-y/audio-rebind/issues/7) |
| 5 | Dogfood on maintainer machine | Planned | Record results under `local/` only; private profile under `local/profiles/` |
| 6 | V1 exit (works, docs, CHANGELOG) | Planned | [#11](https://github.com/goichiro-y/audio-rebind/issues/11) |

Milestone: [v1](https://github.com/goichiro-y/audio-rebind/milestone/1)

### Pre-implementation spikes (tracked on Issues, not separate Issues)

Document findings in the Issue or `local/` as appropriate:

- YAML load on Windows PowerShell 5.1 vs PowerShell 7 (`powershell-yaml` module vs built-in)
- Elevated `Disable-PnpDevice` / `Enable-PnpDevice` vs `pnputil` fallback
- Log path `%LOCALAPPDATA%\AudioRebind\logs\` and exit codes `0`/`1`/`2`/`3` ([pipeline-spec](docs/specs/pipeline-spec.md))

## Done

| Item | Notes |
|------|--------|
| Docs bootstrap | Problem, scope, architecture, pipeline spec, naming ADRs, local-notes guide |
| v1 design decisions | ADR 0003–0009; [profile-spec](docs/specs/profile-spec.md); tracker [#4](https://github.com/goichiro-y/audio-rebind/issues/4) |
| Work-placement rules | Issues = committed; Later = uncommitted; ADR 0007 MVP boundaries |
| Repo layout + example profile | ADR 0008; `profiles/examples/example-usb-interface.yaml` |
| Scope version intent | V1 vs Later/V2 sketched in [scope.md](docs/scope.md) |
| Host investigation (first probe) | Playback needs Engine; capture dictation needs Apps; Event ID 1 OK — see #1 / #2 |

## Later (not committed)

Do not file Issues for these until the version is accepted.

| Theme | Sketch |
|-------|--------|
| V2 defaults | Built-in app/USB catalog + opt-out (GUI not required at first) |
| Settings GUI | Opt-out checkboxes / tray settings over the same profile model |
| Always-on agent | Only if Power-Troubleshooter Event ID 1 proves insufficient ([#2](https://github.com/goichiro-y/audio-rebind/issues/2)) |
| Single-layer tool comparison | Optional investigation ([#3](https://github.com/goichiro-y/audio-rebind/issues/3); not on Milestone `v1`) |
| Least-privilege installer | Elevate only steps that need it (was [#8](https://github.com/goichiro-y/audio-rebind/issues/8)) |
| Optional WASAPI proxy | Only if orchestrator is not enough (was [#9](https://github.com/goichiro-y/audio-rebind/issues/9)) |
| Secondary triggers | Unlock / other fallbacks (was [#10](https://github.com/goichiro-y/audio-rebind/issues/10)) |

When an item is accepted: add Milestone `v2` (or later), open Issues, and update specs/ADRs as needed.
