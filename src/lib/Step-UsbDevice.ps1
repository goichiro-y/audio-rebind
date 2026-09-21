# Step UsbDevice: disable/enable MEDIA (or USB) nodes matching HardwareId patterns.

function Get-AudioRebindErrorDetail {
    param($ErrorRecord)
    if ($null -eq $ErrorRecord) { return 'unknown error' }
    $parts = @()
    if ($ErrorRecord.Exception) {
        $parts += $ErrorRecord.Exception.Message
        if ($ErrorRecord.Exception.HResult) {
            $parts += ('HResult=0x{0:X8}' -f ($ErrorRecord.Exception.HResult -band 0xFFFFFFFF))
        }
    }
    if ($ErrorRecord.FullyQualifiedErrorId) {
        $parts += ('FQId={0}' -f $ErrorRecord.FullyQualifiedErrorId)
    }
    return ($parts -join ' | ')
}

function Invoke-PnpToggleWithRetry {
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock] $Action,

        [Parameter(Mandatory = $true)]
        [string] $OperationName,

        [int] $MaxAttempts = 3,

        [int] $DelaySeconds = 2
    )

    $lastErr = $null
    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        if ($attempt -gt 1) {
            Write-AudioRebindLog ("UsbDevice: {0} retry {1}/{2} after {3}s" -f $OperationName, $attempt, $MaxAttempts, $DelaySeconds)
            Start-Sleep -Seconds $DelaySeconds
        }
        else {
            Start-Sleep -Milliseconds 500
        }
        try {
            & $Action
            Write-AudioRebindLog ("UsbDevice: {0} OK (attempt {1})" -f $OperationName, $attempt)
            return $true
        }
        catch {
            $lastErr = $_
            Write-AudioRebindLog ("UsbDevice: {0} failed attempt {1}: {2}" -f $OperationName, $attempt, (Get-AudioRebindErrorDetail $_)) -Level WARN
        }
    }
    if ($lastErr) {
        Write-AudioRebindLog ("UsbDevice: {0} failed after {1} attempts: {2}" -f $OperationName, $MaxAttempts, (Get-AudioRebindErrorDetail $lastErr)) -Level ERROR
    }
    return $false
}

function Invoke-PnPutilDevice {
    param(
        [ValidateSet('disable', 'enable')]
        [string] $Mode,

        [Parameter(Mandatory = $true)]
        [string] $InstanceId
    )

    $arg = if ($Mode -eq 'disable') { '/disable-device' } else { '/enable-device' }
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = Join-Path $env:SystemRoot 'System32\pnputil.exe'
    $psi.Arguments = "$arg `"$InstanceId`""
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $p = [Diagnostics.Process]::Start($psi)
    $stdout = $p.StandardOutput.ReadToEnd()
    $stderr = $p.StandardError.ReadToEnd()
    $p.WaitForExit()
    return [pscustomobject]@{
        ExitCode = $p.ExitCode
        StdOut   = $stdout
        StdErr   = $stderr
    }
}

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
                FriendlyName   = $dev.FriendlyName
                Class          = $dev.Class
                InstanceId     = $dev.InstanceId
                MatchedPattern = $matchedPattern
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
        $instanceId = $c.InstanceId

        $disabled = Invoke-PnpToggleWithRetry -OperationName 'disable' -MaxAttempts 3 -DelaySeconds 2 -Action {
            Disable-PnpDevice -InstanceId $instanceId -Confirm:$false -ErrorAction Stop
        }

        if (-not $disabled) {
            Write-AudioRebindLog "UsbDevice: trying pnputil /disable-device fallback"
            $r = Invoke-PnPutilDevice -Mode disable -InstanceId $instanceId
            Write-AudioRebindLog ("UsbDevice: pnputil disable exit={0}" -f $r.ExitCode)
            if ($r.ExitCode -ne 0) {
                Write-AudioRebindLog "UsbDevice: pnputil disable failed" -Level ERROR
                $enabledAnyway = Invoke-PnpToggleWithRetry -OperationName 'enable-after-disable-failure' -MaxAttempts 2 -DelaySeconds 2 -Action {
                    Enable-PnpDevice -InstanceId $instanceId -Confirm:$false -ErrorAction Stop
                }
                if (-not $enabledAnyway) {
                    $r2 = Invoke-PnPutilDevice -Mode enable -InstanceId $instanceId
                    Write-AudioRebindLog ("UsbDevice: pnputil enable-after-failure exit={0}" -f $r2.ExitCode)
                    if ($r2.ExitCode -ne 0) { $ok = $false }
                }
                continue
            }
            $disabled = $true
        }

        Start-Sleep -Seconds 2

        $enabled = Invoke-PnpToggleWithRetry -OperationName 'enable' -MaxAttempts 3 -DelaySeconds 2 -Action {
            Enable-PnpDevice -InstanceId $instanceId -Confirm:$false -ErrorAction Stop
        }
        if (-not $enabled) {
            Write-AudioRebindLog "UsbDevice: trying pnputil /enable-device fallback"
            $r = Invoke-PnPutilDevice -Mode enable -InstanceId $instanceId
            Write-AudioRebindLog ("UsbDevice: pnputil enable exit={0}" -f $r.ExitCode)
            if ($r.ExitCode -ne 0) {
                $ok = $false
                continue
            }
        }

        Start-Sleep -Seconds 2
        $after = Get-PnpDevice -InstanceId $instanceId -ErrorAction SilentlyContinue
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
