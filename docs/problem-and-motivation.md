# Problem and motivation

## The user-visible failure

After Windows leaves sleep (classic S3 or similar), USB audio and long-lived apps often look healthy in Settings or Device Manager while audio is actually dead:

- Playback apps spin or stay silent even though a default render endpoint is still listed as active.
- Capture / dictation apps accept a hotkey or start a session but record nothing.
- Short sleep can leave the USB endpoint **OK / Started** while only the Windows audio engine (or app sessions) are zombie — so Device Manager alone is a poor health signal.
- Cycling power on the interface, restarting Windows Audio services, or restarting the app restores sound — until the next resume.

That “green but dead” state is the core pain: operators and apps trust UI status that does not match a working WASAPI stream.

## Root shape (multi-vendor boundary)

The break sits between layers that each claim success:

| Layer | Typical symptom when stuck |
|-------|----------------------------|
| Windows USB power / S3 resume | Selective suspend and hub power policies; delayed or partial re-enumeration |
| Vendor USB audio driver | Endpoint present without a live stream; power-cycle recovers |
| Windows Audio services | Restarting `Audiosrv` / `AudioEndpointBuilder` restores system playback |
| Long-lived apps | Process survives sleep and keeps an invalidated client (`AUDCLNT_E_DEVICE_INVALIDATED` / `0x88890004`) |

Vendors document workarounds (disable sleep, disable selective suspend, unplug/replug). Related tools cover **one** slice (restart audio services, or restart mixer apps). Few ship an **ordered pipeline** across engine + device + apps.

## Motivation for AudioRebind

1. Automate the ritual humans already perform after resume.
2. Stay **generic**: configurable USB devices and app lists — not a single SKU or personal app stack.
3. Prefer a small open orchestrator over waiting for a cross-vendor “real” fix that may never land.
4. Keep host-specific investigation notes and personal stack details out of public git history (`local/`, `notes/private/` — see [guides/local-notes.md](guides/local-notes.md)).
