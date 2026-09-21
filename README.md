# AudioRebind

After Windows sleep/resume, playback or capture can look fine in Settings while shared-mode WASAPI audio is actually dead. AudioRebind runs a fixed order — **audio engine → optional USB device → optional apps** — so sessions work again without a reboot.

It is **not** tied to a single mixer brand. Profiles use generic device IDs and process names. Not an always-on agent: **Task Scheduler** starts a PowerShell script on resume (admin required).

> **Not for you if:** no local-admin elevation, Modern Standby-only (or other non-classic sleep), or enterprise lockdown without admin — see [docs/scope.md](docs/scope.md). Classic sleep→resume + admin is the supported auto path.

> **日本語（短い要約）:** スリープ復帰後に「設定上は生きているのに音やマイクが死ぬ」とき、音声エンジン →（任意）USB →（任意）アプリの順で張り直します。常駐ではなくタスク スケジューラ起動。管理者必須。休止の自動は未検証（メンテナは近いうちに保証しない）。**対象外の目安:** 管理者なし／Modern Standby のみ／企業ロックダウン → [docs/scope.md](docs/scope.md)。くわしくは [README.ja.md](README.ja.md)。言語方針: [docs/i18n.md](docs/i18n.md)。

Japanese summary (fuller): [README.ja.md](README.ja.md). Language policy: [docs/i18n.md](docs/i18n.md).

## Compared to single-layer tools

Public utilities often cover only one layer. AudioRebind is the ordered combination:

| Approach | Covers | Typical gap |
|----------|--------|-------------|
| Restart `Audiosrv` / `AudioEndpointBuilder` only (e.g. [AudioWakeFix](https://jdslabs.com/support/troubleshooting/)-style) | Engine | No USB rebind; no app recycle — long-lived capture clients often stay broken |
| Close/restart mixer or capture apps only (e.g. [SAMISH](https://github.com/thomwithah/samish)-style) | Apps | No service restart; no USB PnP |
| Manual unplug / Device Manager toggle | Device | Not automated |
| **AudioRebind** | Engine → optional USB → optional apps | Explicit YAML profile (no built-in catalog yet) |

More detail: [docs/architecture-overview.md](docs/architecture-overview.md).

## Quick start

Elevated Windows PowerShell 5.1, from a clone of this repo:

1. Copy [`profiles/examples/example-usb-interface.yaml`](profiles/examples/example-usb-interface.yaml) → `local/profiles/my.yaml` and fill the placeholders (see the checklist at the top of that file).
2. `.\src\Register-AudioRebindTask.ps1 -ProfilePath .\local\profiles\my.yaml`  
   (installs `powershell-yaml` for CurrentUser if missing)
3. Sleep → resume, then check `%LOCALAPPDATA%\AudioRebind\logs\`

Manual one-shot: `.\src\Invoke-AudioRebind.ps1 -ProfilePath .\local\profiles\my.yaml`  
Details and timing tips: [src/README.md](src/README.md).

## How it works

Not a always-on background agent. On resume, Windows logs a power event; **Task Scheduler** starts the script; the script runs the pipeline.

```text
Sleep → resume
    → Power-Troubleshooter Event ID 1
      and/or Kernel-Power Event ID 107
    → Task Scheduler (IgnoreNew + ~120s debounce)
    → powershell.exe runs Invoke-AudioRebind.ps1
    → AudioEngine → (optional) UsbDevice → (optional) Apps
```

The same entrypoint can be run **manually** from an elevated PowerShell (any resume that left sessions dead). **Automatic** runs claim classic sleep→resume when Event ID 1 and/or Kernel-Power 107 fires ([#22](https://github.com/goichiro-y/audio-rebind/issues/22)). Hibernate auto is **best-effort / unverified**; shutdown/boot and unlock-only autos are out of scope. Claims and out-of-scope detail: [docs/scope.md](docs/scope.md). Runtime notes: [src/README.md](src/README.md), [ADR 0005](docs/decisions/0005-resume-trigger-task-scheduler.md).

## Requirements

> **Supported operator model:** you must be able to elevate (local administrator). Locked-down standard-user-only environments, Modern Standby-only hosts, and other cases outside [docs/scope.md](docs/scope.md) are not targeted.

- Windows PowerShell **5.1**, run **elevated** (service restart / PnP / task registration)
- Module **`powershell-yaml`** (one-time: `Install-Module powershell-yaml -Scope CurrentUser -Force`)
- A **YAML profile** listing your apps (and optional USB HardwareId patterns). Copy from [`profiles/examples/`](profiles/examples/README.md); keep personal paths under `local/profiles/` (gitignored)

## Status

**[0.2.0](CHANGELOG.md):** clone → write a profile → register → classic sleep → resume. No separate installer yet. Version ladder and planned work: [ROADMAP.md](ROADMAP.md).

## Layout

| Path | Purpose |
|------|---------|
| [src/](src/README.md) | Orchestrator + Task Scheduler register/unregister |
| [docs/](docs/README.md) | Scope, specs, ADRs, guides |
| [profiles/examples/](profiles/examples/README.md) | Placeholder example profiles |
| [ROADMAP.md](ROADMAP.md) | Status and planned work |

## Contributing

Bug reports and small fixes are welcome; this is not an active contributor-recruitment project. See [CONTRIBUTING.md](CONTRIBUTING.md) and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Security

See [SECURITY.md](SECURITY.md).

## License

[MIT](LICENSE)
