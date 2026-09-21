# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project aims to adhere to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

### Changed

### Fixed

### Removed

## [0.1.0] - 2026-09-21

First **V1 MVP** suitable for maintainer dogfood (ADR 0007).

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
