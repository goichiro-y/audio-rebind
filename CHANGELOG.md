# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project aims to adhere to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- Public-safe product documentation (problem, scope, architecture, pipeline spec)
- ADRs for orchestrator shape and naming
- Guide for gitignored local investigation notes
- ADRs 0003–0006 (PowerShell v1, YAML profiles, Task Scheduler trigger, Engine/Usb defaults)
- [profile-spec](docs/specs/profile-spec.md) for YAML profile schema
- ADR 0007 (V1 MVP boundaries) and work-placement rules in CONTRIBUTING / ROADMAP
- ADR 0008 (repo layout: `src/`, `profiles/examples/`, `local/profiles/`)
- Placeholder example profile and HardwareId discovery guide
- Pipeline logging path and exit-code contract
- ADR 0009 (YAML on Windows PowerShell 5.1 via `powershell-yaml`)
- Host layer-isolation findings summarized on Issues #1 / #2 (Engine for playback; Apps for capture clients)
- Manual resume orchestrator: [`src/Invoke-AudioRebind.ps1`](src/Invoke-AudioRebind.ps1) (AudioEngine / UsbDevice / Apps, YAML profiles, logs)

### Changed

- Pipeline and architecture docs aligned with ADR 0003–0006
- ROADMAP restructured into V1 sequence / Done / Later; uncommitted ideas no longer tracked as open Issues
- [scope.md](docs/scope.md) records V1 vs Later/V2 version intent
- Japanese README summary updated for V1 status

### Fixed

### Removed
