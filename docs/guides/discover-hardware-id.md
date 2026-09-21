# Discovering HardwareId patterns (public-safe)

Use this when filling `hardwareIdPatterns` in a profile. Keep full InstanceIds and serial-like strings in `local/` only.

## Steps (Windows)

1. Open an elevated PowerShell.
2. List candidate audio / USB media devices, for example:

```powershell
Get-PnpDevice -Class MEDIA,USB | Where-Object Status -eq 'OK' |
  Select-Object FriendlyName, InstanceId |
  Format-Table -AutoSize
```

3. For a chosen `InstanceId`, read HardwareIds (do **not** paste the full InstanceId into shared docs):

```powershell
Get-PnpDeviceProperty -InstanceId '<paste InstanceId locally>' -KeyName 'DEVPKEY_Device_HardwareIds' |
  Select-Object -ExpandProperty Data
```

4. Prefer a stable pattern such as `USB\VID_xxxx&PID_yyyy` (optionally with `&REV_....`).
5. Prefer **OK / Started** instances. Ignore ghost nodes with the same name but Unknown status.
6. Do **not** target an upstream generic USB hub parent unless investigation proves that is what recovers the device.

Personal notes and raw dumps: [local-notes.md](local-notes.md).
