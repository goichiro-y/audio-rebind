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
| [docs/specs/profile-spec.md](docs/specs/profile-spec.md) | YAML profile schema |
| [docs/decisions/](docs/decisions/README.md) | Adopted ADRs |
| [docs/guides/local-notes.md](docs/guides/local-notes.md) | Where to put machine-private notes |
| [docs/guides/discover-hardware-id.md](docs/guides/discover-hardware-id.md) | How to find HardwareId patterns safely |
| [profiles/examples/](profiles/examples/README.md) | Placeholder example profiles |
| [ROADMAP.md](ROADMAP.md) | Status and planned work |
| [AGENTS.md](AGENTS.md) | Conventions for humans and coding agents |

## Status

**V1 MVP (0.1.0)** is usable for maintainer dogfood: register [`src/Register-AudioRebindTask.ps1`](src/Register-AudioRebindTask.ps1), point it at a YAML profile, resume from sleep. See [src/README.md](src/README.md), [CHANGELOG.md](CHANGELOG.md), and [ROADMAP.md](ROADMAP.md).

Post-V1 polish: [#12](https://github.com/goichiro-y/audio-rebind/issues/12) (UsbDevice disable), [#13](https://github.com/goichiro-y/audio-rebind/issues/13) (resume latency).

## Development

```bash
# No runtime package yet. Layout: src/ (planned scripts), profiles/examples/, docs/, ROADMAP.md.
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Security

See [SECURITY.md](SECURITY.md).

## License

[MIT](LICENSE)
