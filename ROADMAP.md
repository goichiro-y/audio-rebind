# Roadmap

Track high-level work here. Durable specifications live in [`docs/`](docs/README.md). Adopted design decisions live in [`docs/decisions/`](docs/decisions/README.md).

| Status | Item | Notes |
|--------|------|--------|
| Done | Docs bootstrap | Problem, scope, architecture, pipeline spec, ADRs, local-notes guide |
| Planned | Resume orchestrator (v1) | Ordered AudioEngine → UsbDevice → Apps; see [pipeline-spec](docs/specs/pipeline-spec.md) |
| Planned | Profile format | Config for device match, app list, delays, enabled steps |
| Planned | Resume trigger packaging | Task Scheduler / service wrapper for automatic runs |
| Idea | Least-privilege installer | Elevation only for steps that need it |
| Idea | Optional WASAPI proxy | Only if the orchestrator is not enough for stubborn apps |

Prefer GitHub Issues for detailed discussion; keep this file as a thin overview.
