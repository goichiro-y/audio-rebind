# 5. Resume trigger and elevation: Task Scheduler

- Status: Accepted
- Date: 2026-09-21
- Updated: 2026-10-02 ([#47](https://github.com/goichiro-y/audio-rebind/issues/47); [#22](https://github.com/goichiro-y/audio-rebind/issues/22))

## Context

Automatic runs need a reliable Windows resume signal and enough privilege to restart audio services and toggle PnP devices. Architecture listed Task Scheduler (Power-Troubleshooter) or an equivalent service. Finer “least-privilege installer” ideas are out of product scope for the intended audience (see [scope.md](../scope.md)).

Maintainer dogfood (2026-09-22) observed a classic sleep→resume where **Kernel-Power Event ID 107** was logged but **Power-Troubleshooter Event ID 1** was not, so the single-trigger task never started.

## Decision

For **v1**:

1. **Primary trigger:** Task Scheduler on `Microsoft-Windows-Power-Troubleshooter` **Event ID 1** (system resumed from sleep).
2. **Fallback co-trigger:** Same task also subscribes to `Microsoft-Windows-Kernel-Power` **Event ID 107** (system resumed from sleep). One task, two `EventTrigger`s — not a second task name ([#22](https://github.com/goichiro-y/audio-rebind/issues/22)).
3. **Dedup:** Task `MultipleInstancesPolicy=StopExisting`. A second trigger while a run is live stops that run and starts a new one, so a stuck Running instance does not keep later resumes from starting ([#47](https://github.com/goichiro-y/audio-rebind/issues/47)). `Invoke-AudioRebind.ps1` writes `%LOCALAPPDATA%\AudioRebind\last-run.stamp` only after a non-WhatIf run finishes with exit code 0, and skips the pipeline if that success was within ~120 seconds. The stamp is not written at start: the replacement run must still execute. One resume that emits both events therefore finishes the pipeline once (the later start).
4. **Elevation:** Register the task with **Run with highest privileges**. Do not ship an always-on Windows Service solely for elevation in v1. The **supported operator** is someone who can elevate (local admin); standard-user-only completion of the same pipeline is out of scope ([scope.md](../scope.md) Operator / privilege model).
5. **Manual:** Support **manual** invocation of the same orchestrator entrypoint. Unlock-based or other secondary triggers stay optional follow-ups if both Event ID 1 and Kernel-Power 107 still miss on some hosts.

**Support claims** (pipeline vs auto) live in [scope.md](../scope.md) (Pipeline vs automatic trigger). In short: classic sleep→resume auto is the verified 0.1.x claim (via Event ID 1 and/or Kernel-Power 107); hibernate auto is best-effort if either event fires — **unverified and not a near-term maintainer commitment** (community Issue/PR to update the scope matrix welcome); S5 / unlock-only autos are out of scope; Modern Standby is deferred. Do not treat either event as a promise for every ACPI resume name.

## Consequences

- Packaging centers on task XML / registration script plus the PowerShell entrypoint.
- Least-privilege “elevate only some steps” and standard-user-only productization are **not planned** (removed from ROADMAP Later; recorded as out of scope in [scope.md](../scope.md)).
- Hosts that miss both Event ID 1 and Kernel-Power 107 still need documented manual run (and later optional unlock / other triggers).
- Do not market hibernate (or similar) auto as supported; keep claims aligned with [scope.md](../scope.md).
- Re-register the scheduled task after upgrading past the single-trigger packaging so the Kernel-Power 107 trigger is installed. Re-register again after the overlap policy changes, so an existing task leaves `IgnoreNew`.
