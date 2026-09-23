# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project aims to adhere to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- [ADR 0011](docs/decisions/0011-version-ladder-1-0-catalog-gui.md): version ladder — **1.0.0** is catalog + settings GUI (admin still required); YAML tryout polish is **0.3.x**; no public **V2** / 2.0.0 destination
- README Japanese landing at the top (USP, audience, Quick start skeleton); [`README.ja.md`](README.ja.md) is a pointer ([docs/i18n.md](docs/i18n.md))

### Changed

- Document which power states start the task automatically vs a manual run (S0 display-off, Modern Standby, S3, S4, S5) in [docs/scope.md](docs/scope.md) and the README
- README Japanese landing and English intro: user-facing sleep-resume dropout first; DAW as a caution, not product out-of-scope
- README English landing matches Japanese density; Event IDs, debounce, and WASAPI diagnosis stay in [docs/scope.md](docs/scope.md) ([docs/i18n.md](docs/i18n.md))
- [docs/scope.md](docs/scope.md): exclusive-mode / DAW as a caution; not a crashed-app watchdog
- Japanese README landing points at [docs/README.md](docs/README.md) and [CONTRIBUTING.md](CONTRIBUTING.md)
- [src/README.md](src/README.md): host ExecutionPolicy can block local `.ps1` files (Install does not bypass it)

### Fixed

### Removed

## [0.3.0] - 2026-09-22

Thin elevated Install to Program Files, profiles under LocalAppData, so the scheduled task no longer depends on a durable clone path ([#29](https://github.com/goichiro-y/audio-rebind/issues/29), [#30](https://github.com/goichiro-y/audio-rebind/issues/30), [#31](https://github.com/goichiro-y/audio-rebind/issues/31)). Same MVP shape (explicit YAML, Task Scheduler, admin). No catalog/GUI on this line.

> Note: This line was briefly published as GitHub Release `v1.0.0` / Milestone `1.0.0`, then renumbered to **0.3.0** to match the version ladder then in force (1.0.0 = README polish). That meaning of **1.0.0** later moved to **0.3.x**; **1.0.0** is now catalog + settings GUI ([ADR 0011](docs/decisions/0011-version-ladder-1-0-catalog-gui.md)).

### Added

- [ADR 0010](docs/decisions/0010-installed-layout-programfiles-localappdata.md): `%ProgramFiles%\AudioRebind\` runtime + `%LOCALAPPDATA%\AudioRebind\` profiles/logs
- `Install-AudioRebind.ps1` — copy runtime, seed `profiles\default.yaml`, ensure `powershell-yaml`
- `Uninstall-AudioRebind.ps1` — remove task + Program Files; keep LocalAppData by default (`-RemoveUserData` optional)
- `Register-AudioRebindTask.ps1`: omit `-ProfilePath` to use LocalAppData `default.yaml`

### Changed

- README / README.ja Quick start prefer Install → edit profile → Register from Program Files; clone Register remains for development ([src/README.md](src/README.md))

## [0.2.0] - 2026-09-22

Maintainer-usable **0.x** dogfood release: reliable resume trigger, practical wall-clock, and quieter app recycle. Catalog/GUI were then named **V2**; that destination is now **1.0.0** ([ADR 0011](docs/decisions/0011-version-ladder-1-0-catalog-gui.md)).

### Added

- Task Scheduler co-trigger: `Microsoft-Windows-Kernel-Power` Event ID **107** alongside Power-Troubleshooter Event ID 1; ~120s orchestrator debounce + existing `IgnoreNew` ([#22](https://github.com/goichiro-y/audio-rebind/issues/22))
- Apps `windowAfterStart: minimize` (per process / apps-level) ([#16](https://github.com/goichiro-y/audio-rebind/issues/16))
- Minimize poll early-exit / no-HWND give-up / `minimizeTimeoutMs` default 1200 ([#18](https://github.com/goichiro-y/audio-rebind/issues/18))
- Apps minimize launch via `CreateProcess` + `SW_SHOWMINNOACTIVE` (fallback poll kept; Electron may still flash) ([#21](https://github.com/goichiro-y/audio-rebind/issues/21))
- Faster Apps stop: `stopMode: force`, poll-after-force, `postStopDelayMs` ([#19](https://github.com/goichiro-y/audio-rebind/issues/19))
- `Register-AudioRebindTask.ps1` installs `powershell-yaml` for CurrentUser when missing ([#14](https://github.com/goichiro-y/audio-rebind/issues/14))

### Changed

- AudioEngine: Running poll instead of fixed 1s sleeps; StrictMode-safe Count checks ([#23](https://github.com/goichiro-y/audio-rebind/issues/23))
- Apps: batched stop across all process entries ([#23](https://github.com/goichiro-y/audio-rebind/issues/23))
- Documented shorter `afterAudioEngineMs` trials (500–1000; example default stays 2000) ([#20](https://github.com/goichiro-y/audio-rebind/issues/20))
- Version ladder, hibernate auto claims, i18n, scope/ADR updates for public-prep ([ROADMAP](ROADMAP.md), [docs/scope.md](docs/scope.md), [docs/i18n.md](docs/i18n.md), [#3](https://github.com/goichiro-y/audio-rebind/issues/3))

### Notes

- Maintainer dogfood: dual trigger recovers when Event ID 1 is missing; pipeline wall-clock on the order of ~10s class after timing work; Engine-only is not enough when long-lived capture apps are in scope

## [0.1.0] - 2026-09-21

First **0.1.x** maintainer / personal dogfood MVP ([ADR 0007](docs/decisions/0007-v1-mvp-boundaries.md)). (Also closed GitHub Milestone `0.1.0`, formerly titled `v1`.)

### Added

- Product docs: problem, scope, architecture, pipeline and profile specs, local-notes and HardwareId guides
- ADRs 0001–0009 (orchestrator shape, naming, PowerShell stack, YAML on Windows PowerShell 5.1, Task Scheduler trigger, Engine/Usb defaults, MVP boundaries, repo layout)
- Manual resume orchestrator: [`src/Invoke-AudioRebind.ps1`](src/Invoke-AudioRebind.ps1) (AudioEngine → UsbDevice → Apps)
- Task Scheduler packaging: [`src/Register-AudioRebindTask.ps1`](src/Register-AudioRebindTask.ps1) / [`Unregister-AudioRebindTask.ps1`](src/Unregister-AudioRebindTask.ps1) (Power-Troubleshooter Event ID 1, HighestAvailable)
- Example profile placeholders under `profiles/examples/`
- Work-placement rules (Issues = committed work; ROADMAP Later = uncommitted)

### Notes

- Maintainer sleep dogfood: scheduled task recovered playback quickly; long-lived capture apps recover after process recycle
- Known follow-ups: UsbDevice disable refusal on some hosts ([#12](https://github.com/goichiro-y/audio-rebind/issues/12)); resume latency tuning ([#13](https://github.com/goichiro-y/audio-rebind/issues/13))
