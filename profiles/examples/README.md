# Example profiles

Shared YAML examples with **placeholders only**. Copy into `local/profiles/` for personal use — never commit personal absolute paths back into this folder.

## Checklist (first-time fill)

1. Copy [example-usb-interface.yaml](example-usb-interface.yaml) → `local/profiles/<your-name>.yaml`.
2. **App path** — set `apps.processes[].path` to your executable, or set `apps.enabled: false`.
3. The example sets `windowAfterStart: minimize`. Shorter stop timeouts for Electron-style apps: [src/README](../../src/README.md) Resume timing tips.

USB disable/enable is not in the current pipeline ([Later](../../ROADMAP.md)).

| File | Purpose |
|------|---------|
| [example-usb-interface.yaml](example-usb-interface.yaml) | One app path and minimized start (replace the path before run). No USB device entry |

Schema: [docs/specs/profile-spec.md](../../docs/specs/profile-spec.md). Layout: [ADR 0008](../../docs/decisions/0008-v1-repository-layout.md).
