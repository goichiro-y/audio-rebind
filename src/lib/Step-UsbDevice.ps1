# Step UsbDevice: disable/enable MEDIA (or USB) nodes matching HardwareId patterns.

function Invoke-AudioRebindUsbDevice {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $StepConfig,

        [switch] $WhatIf
    )

    $patterns = @(ConvertTo-StringArray $StepConfig.hardwareIdPatterns)
    Write-AudioRebindLog ("UsbDevice: patterns=[{0}]" -f ($patterns -join ', '))

    if ($WhatIf) {
        Write-AudioRebindLog "UsbDevice: WhatIf — skipping PnP toggle"
        return $true
    }

    $candidates = @()
    $devices = Get-PnpDevice -ErrorAction SilentlyContinue | Where-Object {
        $_.Status -eq 'OK' -and ($_.Class -eq 'MEDIA' -or $_.Class -eq 'USB' -or $_.Class -eq 'AudioEndpoint')
    }

    foreach ($dev in $devices) {
        # Skip pure AudioEndpoint children; prefer function/composite MEDIA/USB nodes
        if ($dev.Class -eq 'AudioEndpoint') { continue }

        $hw = $null
        try {
            $hw = Get-PnpDeviceProperty -InstanceId $dev.InstanceId -KeyName 'DEVPKEY_Device_HardwareIds' -ErrorAction Stop
        }
        catch {
            continue
        }
        $ids = @($hw.Data)
        $matchedPattern = $null
        foreach ($pat in $patterns) {
            foreach ($id in $ids) {
                if ($null -ne $id -and ([string]$id).IndexOf($pat, [StringComparison]::OrdinalIgnoreCase) -ge 0) {
                    $matchedPattern = $pat
                    break
                }
            }
            if ($matchedPattern) { break }
        }
        if ($matchedPattern) {
            $candidates += [pscustomobject]@{
                FriendlyName    = $dev.FriendlyName
                Class           = $dev.Class
                InstanceId      = $dev.InstanceId
                MatchedPattern  = $matchedPattern
            }
        }
    }

    if ($candidates.Count -eq 0) {
        Write-AudioRebindLog "UsbDevice: no OK MEDIA/USB device matched patterns (soft-fail optional step)" -Level WARN
        return $true
    }

    $ok = $true
    foreach ($c in $candidates) {
        Write-AudioRebindLog ("UsbDevice: target name='{0}' class={1} pattern='{2}'" -f $c.FriendlyName, $c.Class, $c.MatchedPattern)
        try {
            Disable-PnpDevice -InstanceId $c.InstanceId -Confirm:$false -ErrorAction Stop
            Write-AudioRebindLog "UsbDevice: disable OK"
        }
        catch {
            $errText = $_.Exception.Message
            Write-AudioRebindLog ("UsbDevice: disable failed: {0}" -f $errText) -Level ERROR
            Write-AudioRebindLog "UsbDevice: pnputil fallback not implemented in v1" -Level WARN
            # Still try enable in case device was already disabled / partial state
            try {
                Enable-PnpDevice -InstanceId $c.InstanceId -Confirm:$false -ErrorAction Stop
                Write-AudioRebindLog "UsbDevice: enable after disable-failure OK"
            }
            catch {
                Write-AudioRebindLog ("UsbDevice: enable after disable-failure failed: {0}" -f $_.Exception.Message) -Level ERROR
                $ok = $false
            }
            continue
        }

        Start-Sleep -Seconds 2

        try {
            Enable-PnpDevice -InstanceId $c.InstanceId -Confirm:$false -ErrorAction Stop
            Write-AudioRebindLog "UsbDevice: enable OK"
        }
        catch {
            Write-AudioRebindLog ("UsbDevice: enable failed: {0}" -f $_.Exception.Message) -Level ERROR
            $ok = $false
            continue
        }

        Start-Sleep -Seconds 2
        $after = Get-PnpDevice -InstanceId $c.InstanceId -ErrorAction SilentlyContinue
        if ($null -eq $after) {
            Write-AudioRebindLog "UsbDevice: device missing after enable" -Level WARN
        }
        else {
            Write-AudioRebindLog ("UsbDevice: after status={0}" -f $after.Status)
            if ($after.Status -ne 'OK') {
                Write-AudioRebindLog "UsbDevice: device not OK after toggle (possible reboot pending)" -Level WARN
            }
        }
    }

    return $ok
}
