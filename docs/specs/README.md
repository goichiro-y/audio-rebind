# Specs

Area-specific specifications (**what / why** for a subsystem).

## Conventions

- One focused topic per file, for example `cli-spec.md` or `api-spec.md`.
- English is canonical; Japanese siblings use `*.ja.md` ([i18n.md](../i18n.md)).
- Adopted cross-cutting decisions belong in [`../decisions/`](../decisions/README.md), not here.

## Index

| Spec | Description |
|------|-------------|
| [pipeline-spec.md](pipeline-spec.md) | Ordered resume rebind steps (engine, then app start; app stop may overlap the engine) |
| [profile-spec.md](profile-spec.md) | YAML profile schema (steps, delays, app list) |
