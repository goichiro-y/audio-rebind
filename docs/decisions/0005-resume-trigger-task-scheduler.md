# 5. Resume trigger and elevation: Task Scheduler

- Status: Accepted
- Date: 2026-09-21

## Context

Automatic runs need a reliable Windows resume signal and enough privilege to restart audio services and toggle PnP devices. Architecture listed Task Scheduler (Power-Troubleshooter) or an equivalent service; least-privilege installer remained an Idea.

## Decision

For **v1**:

1. **Primary trigger:** Task Scheduler on `Microsoft-Windows-Power-Troubleshooter` **Event ID 1** (system resumed from sleep).
2. **Elevation:** Register the task with **Run with highest privileges**. Do not ship a always-on Windows Service solely for elevation in v1.
3. **Secondary:** Support **manual** invocation of the same orchestrator entrypoint. Unlock-based or other secondary triggers stay optional follow-ups if Event ID 1 proves incomplete on some hosts.

## Consequences

- Packaging centers on task XML / registration script plus the PowerShell entrypoint.
- Least-privilege “elevate only some steps” stays deferred (ROADMAP Idea).
- Hosts that miss Power-Troubleshooter events need documented manual run (and later optional secondary triggers).
