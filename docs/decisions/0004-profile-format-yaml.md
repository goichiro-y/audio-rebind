# 4. Profile format: YAML

- Status: Accepted
- Date: 2026-09-21

## Context

The orchestrator is configuration-driven (enabled steps, delays, device match, app list). No on-disk schema existed yet; ROADMAP listed “Profile format” as Planned.

## Decision

Use **YAML** profile files as the v1 config format. Schema details live in `docs/specs/profile-spec.md`. Shared example profiles must use HardwareId **patterns** and placeholders — never machine-specific full USB InstanceIds or personal absolute paths without placeholders.

## Consequences

- Human-editable configs without a GUI for v1.
- PowerShell can parse YAML via a small dependency or ConvertFrom-Yaml (document the chosen approach in implementation).
- JSON remains a possible alternate encoding later; YAML is the canonical authoring format for v1.
