# AudioRebind

Rebinds Windows audio after sleep/resume: rebuilds the Windows audio engine, optionally resets a USB audio device, and restarts configured apps so WASAPI sessions are not left invalidated.

AudioRebind is **not** tied to a single mixer brand. USB audio interfaces and long-lived capture apps motivated the design, but profiles stay generic (device IDs and process names are configuration).

Japanese summary: [README.ja.md](README.ja.md). Language policy: [docs/i18n.md](docs/i18n.md).

## Layout

| Path | Purpose |
|------|---------|
| [docs/problem-and-motivation.md](docs/problem-and-motivation.md) | Why this project exists |
| [docs/scope.md](docs/scope.md) | In / out of scope |
| [docs/architecture-overview.md](docs/architecture-overview.md) | High-level design |
| [docs/specs/pipeline-spec.md](docs/specs/pipeline-spec.md) | Resume pipeline steps |
| [docs/decisions/](docs/decisions/README.md) | Adopted ADRs |
| [docs/guides/local-notes.md](docs/guides/local-notes.md) | Where to put machine-private notes |
| [ROADMAP.md](ROADMAP.md) | Status and planned work |
| [AGENTS.md](AGENTS.md) | Conventions for humans and coding agents |

## Status

Documentation bootstrap is done. The resume orchestrator is not implemented yet — see [ROADMAP.md](ROADMAP.md).

## Development

```bash
# No runtime package yet. Start with docs/ and ROADMAP.md.
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Security

See [SECURITY.md](SECURITY.md).

## License

[MIT](LICENSE)
