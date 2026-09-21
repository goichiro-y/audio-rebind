# 2. Name: AudioRebind / audio-rebind

- Status: Accepted
- Date: 2026-09-21

## Context

The product rebuilds audio sessions after power transitions. Encoding “sleep”, “USB”, or a hardware brand into the name would either overfit or become stale if scope widens. Display names and repository names also follow different conventions.

## Decision

- **Product / display name:** AudioRebind  
- **Repository name:** `audio-rebind` (lowercase, hyphenated)  
- Do **not** put “sleep” or vendor model names in the product name; describe them in the README and docs instead.

## Consequences

- Short, memorable branding; README carries the sleep/resume explanation.
- Aligns with common GitHub naming while keeping PascalCase in prose.
