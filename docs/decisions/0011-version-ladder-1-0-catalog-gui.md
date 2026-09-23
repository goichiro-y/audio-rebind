# 11. Version ladder: 1.0.0 is catalog / GUI

- Status: Accepted
- Date: 2026-09-22
- Supersedes: version-ladder paragraph in [ADR 0007](0007-v1-mvp-boundaries.md) (0.1.x MVP boundaries themselves stay)

## Context

After **0.3.0** (thin Install), the old ladder left **1.0.0** as README-led tryouts on the same YAML product, and named catalog / settings GUI **V2** / semver **2.0.0**. That 1.0.0 line felt empty, while visitors read **1.0** as a real product jump and **2.0** as a long-lived project.

The YAML MVP (explicit profiles, no catalog, Task Scheduler, elevation) is already the public **0.x** product. The next difference worth a major is defaults + a settings GUI — still with local-admin elevation ([scope](../scope.md) Operator / privilege model).

## Decision

| Line | Meaning |
|------|---------|
| **0.1.x – 0.3.0** | Unchanged shipped history (MVP, public-prep, thin Install). |
| **0.3.x** | Current product polish on the YAML line: README-led tryouts, Install-path dogfood, clearer first-run failures. Not a new major. |
| **1.0.0** | First semver major: built-in catalog / heuristics + opt-out, and a settings GUI so typical stacks need not hand-edit YAML. **Elevation remains required.** Do not ship **1.0.0** before that GUI/catalog line exists. A long **0.x** is accepted. |
| **2.0.0 / “V2”** | Not the public destination. Do not headline a second major as the “real” product. A future 2.0.0 is only if a later contract break actually needs it. |

Always-on agents stay a conditional Later idea (only if Event ID 1 + Kernel-Power 107 are insufficient), not a version name.

The settings window is open as [#33](https://github.com/goichiro-y/audio-rebind/issues/33). That Issue does not carry a version milestone and does not decide the release name. Whether a release is called **1.0.0** is a later check outside Issues. Do not block [#33](https://github.com/goichiro-y/audio-rebind/issues/33) on that check. Do not add a catalog or settings GUI inside a **0.x** change that has no Issue.

## Consequences

- Stranger-facing YAML friction is **0.3.x**, not an unnamed gap and not **1.0.0**.
- README must not imply that **1.0.0** drops admin or is for locked-down standard users.
- [ADR 0007](0007-v1-mvp-boundaries.md) still forbids catalog/GUI **inside 0.x** as silent scope creep.
- Index and ROADMAP drop **V2** as a product-phase name.
