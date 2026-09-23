# 12. Withdraw USB disable/enable from the current pipeline

- Status: Accepted
- Date: 2026-09-24
- Withdraws the USB step from the current product. The bodies of [ADR 0001](0001-single-orchestrator-three-steps.md), [ADR 0006](0006-v1-step-defaults-engine-usb.md), and [ADR 0007](0007-v1-mvp-boundaries.md) stay as adopted at the time.

## Context

Public reports of sleep/resume audio failure include people who recovered by disabling and enabling a USB audio device, or by unplugging it. That is enough to treat disable/enable as something that might help. It is not enough to treat it as required. Those reports do not show that restarting Windows Audio and the affected apps would have failed on the same host.

On maintainer dogfood, restarting Windows Audio services and the configured apps recovered the session. A case that stays dead after both of those steps, and recovers only from disable/enable, has not been separated. No device reproduces that case every time.

While that judgment is still “not shown to be necessary,” keeping the step in the running pipeline was not worth it.

## Decision

Remove USB disable/enable from the current product. The running pipeline is Windows Audio restart, then the configured apps.

The hypothesis stays. Bring the step back only after user insight, including further maintainer use, shows a pattern the two current steps do not cover. Do not file an Issue until that case is separated. Until then it stays on [ROADMAP Later](../../ROADMAP.md).

## Consequences

- Living specs describe two steps. `Step-UsbDevice.ps1` is not part of the orchestrator. A profile that still contains `usbDevice` or `afterUsbDeviceMs` does not run a device toggle.
- [ADR 0001](0001-single-orchestrator-three-steps.md), [ADR 0006](0006-v1-step-defaults-engine-usb.md), and [ADR 0007](0007-v1-mvp-boundaries.md) keep their original text. They are not rewritten to pretend the USB step was never adopted.
- The settings window ([#33](https://github.com/goichiro-y/audio-rebind/issues/33)) chooses apps only.
