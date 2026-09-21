# 3. v1 orchestrator stack: PowerShell

- Status: Accepted
- Date: 2026-09-21

## Context

The resume pipeline needs service control, optional PnP toggles, and process recycle under elevation, typically invoked from Task Scheduler after resume. No runtime package existed yet; language and packaging were left open in the pipeline spec.

## Decision

Implement **v1** as a **PowerShell** orchestrator (script or small module) plus a profile file and a Task Scheduler registration helper. Do not require a compiled service binary for v1. A later rewrite (for example .NET) remains allowed if packaging or reliability demands it; behavior stays bound by `docs/specs/pipeline-spec.md`.

## Consequences

- Fast iteration and natural fit for elevated scheduled tasks on Windows.
- Contributors need PowerShell 5.1+ (or PowerShell 7+ if explicitly documented later); pin the minimum in install docs when written.
- Distribution is files + task registration rather than an MSI/service for v1 (installer work stays an Idea).
