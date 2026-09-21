# Architecture overview

## Goal

On resume, rebuild enough of the Windows audio path that shared-mode WASAPI clients can open working streams again — without requiring a reboot or a physical power cycle when software recovery is enough.

## Pipeline

```text
Resume event
    -> Step AudioEngine   (services)
    -> Step UsbDevice     (optional PnP restart)
    -> Step Apps          (optional process recycle)
    -> Logs / exit status
```

Order matters: restarting apps while the audio engine or device is still zombie often reproduces `AUDCLNT_E_DEVICE_INVALIDATED`. Engine first, then device if needed, then apps.

## Triggers

**v1 primary:** Task Scheduler on `Microsoft-Windows-Power-Troubleshooter` Event ID 1, with the task run at highest privileges ([ADR 0005](decisions/0005-resume-trigger-task-scheduler.md)). Manual invocation of the same entrypoint is supported. Unlock or other secondary triggers may be added later if some hosts miss Event ID 1.

## Profiles

Profiles are **YAML** ([ADR 0004](decisions/0004-profile-format-yaml.md); schema: [profile-spec](specs/profile-spec.md)):

- Whether each step is enabled
- Delays between steps
- USB device match rules (HardwareId patterns; prefer OK/Started instances)
- App executable paths or process names to recycle

Shipping examples may include a USB audio interface and a long-lived capture helper; users edit profiles for their stack.

## Relation to existing tools

Public utilities already cover slices of the same problem. AudioRebind is meant to be the **ordered combination**, not a rename of any one of them.

| Tool / approach | What it covers | Gap vs AudioRebind |
|-----------------|----------------|--------------------|
| [AudioWakeFix](https://jdslabs.com/support/troubleshooting/) (JDS Labs; wake task restarts `Audiosrv` / `AudioEndpointBuilder`) | Audio **engine** only | No USB device step; no app recycle |
| [SAMISH](https://github.com/thomwithah/samish) (close/restart mixer apps around sleep; sleep-blocker diagnostics) | **Apps** (and related sleep helpers) | No Windows Audio service restart; no USB PnP rebind |
| Manual interface power cycle | **Device** | Not automated |

Order still matters: engine → optional USB → apps. Using only AudioWakeFix or only SAMISH leaves the other layers unrecovered.

## Implementation notes

- **v1 stack:** PowerShell under `src/` + Task Scheduler registration ([ADR 0003](decisions/0003-v1-powershell-orchestrator.md), [ADR 0005](decisions/0005-resume-trigger-task-scheduler.md), [ADR 0008](decisions/0008-v1-repository-layout.md)).
- v1 uses an elevated scheduled task; finer least-privilege installer remains a later Idea.
- Fail soft: log and continue when an optional step is disabled or a process is not running.
- Keep the core free of brand-specific hardcoding.
- Shared examples: `profiles/examples/`; personal profiles: `local/profiles/`.
