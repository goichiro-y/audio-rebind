# Architecture overview

## Goal

On resume, rebuild enough of the Windows audio path that shared-mode WASAPI clients can open working streams again — without requiring a reboot or a physical power cycle when software recovery is enough.

## Pipeline

```text
Resume event
    -> Step AudioEngine   (services)
    -> Step Apps          (optional process recycle)
    -> Logs / exit status
```

Order matters: restarting apps while the audio engine is still down often reproduces `AUDCLNT_E_DEVICE_INVALIDATED`. Engine first, then apps.

## Triggers

**0.1.x auto:** Task Scheduler with highest privileges on **Power-Troubleshooter Event ID 1** and **Kernel-Power Event ID 107** (same task; dedupe via IgnoreNew + ~120s debounce) — [ADR 0005](decisions/0005-resume-trigger-task-scheduler.md), [#22](https://github.com/goichiro-y/audio-rebind/issues/22). Manual invocation of the same entrypoint is supported. Which power transitions are claimed for auto vs manual — including hibernate as best-effort/unverified, not a near-term maintainer commitment — is defined in [scope.md](scope.md) (Pipeline vs automatic trigger). Unlock or other triggers may be added later if both events still miss on some hosts.

## Profiles

Profiles are **YAML** ([ADR 0004](decisions/0004-profile-format-yaml.md); schema: [profile-spec](specs/profile-spec.md)):

- Whether each step is enabled
- Delays between steps
- App executable paths or process names to recycle

Shipping examples include a placeholder app path; users edit profiles for their stack. USB disable/enable is not in the current pipeline ([Later](../ROADMAP.md)).

## Relation to existing tools

Public utilities already cover slices of the same problem. AudioRebind is meant to be the **ordered combination**, not a rename of any one of them.

| Tool / approach | What it covers | Gap vs AudioRebind |
|-----------------|----------------|--------------------|
| [AudioWakeFix](https://jdslabs.com/support/troubleshooting/) (JDS Labs; wake task restarts `Audiosrv` / `AudioEndpointBuilder`) | Audio **engine** only | No app recycle — long-lived capture clients often stay broken |
| [SAMISH](https://github.com/thomwithah/samish) (close/restart mixer apps around sleep; sleep-blocker diagnostics) | **Apps** (and related sleep helpers) | No Windows Audio service restart |
| Manual interface power cycle | **Device** | Not in the current pipeline ([Later](../ROADMAP.md)) |

Order still matters: engine, then apps. Using only AudioWakeFix or only SAMISH leaves the other layer unrecovered.

### Maintainer comparison (generalized, [#3](https://github.com/goichiro-y/audio-rebind/issues/3))

On one maintainer dogfood host after classic sleep→resume (endpoints/services looked healthy while audio was dead):

- **Engine-only** (AudioWakeFix-style service restart): shared-mode **playback** recovered; **long-lived capture clients** stayed broken until process recycle.
- **USB rebind alone** (after engine): did not recover those capture clients on that run.
- **Apps recycle after engine** (ordered pipeline): capture clients recovered.
- **Apps-only as the sole first recovery** from a cold post-sleep failure was not separately A/B tested; the ordered path remains the supported claim.

So the architecture table above is not only theoretical: Engine-only is not enough when capture apps are in scope; the ordered pipeline is justified for that failure shape.

## Implementation notes

- **v1 stack:** PowerShell under `src/` + Task Scheduler registration ([ADR 0003](decisions/0003-v1-powershell-orchestrator.md), [ADR 0005](decisions/0005-resume-trigger-task-scheduler.md), [ADR 0008](decisions/0008-v1-repository-layout.md)).
- v1 uses an elevated scheduled task; the supported operator can elevate. Standard-user-only / least-privilege installer packaging is out of scope ([scope.md](scope.md)).
- Fail soft: log and continue when an optional step is disabled or a process is not running.
- Keep the core free of brand-specific hardcoding.
- Shared examples: `profiles/examples/`; personal profiles: `local/profiles/`.
