# Step AudioEngine: restart AudioEndpointBuilder then Audiosrv (ADR 0006).

function Wait-AudioRebindServiceRunning {
    param(
        [Parameter(Mandatory = $true)]
        [string[]] $Name,

        [int] $TimeoutMs = 3000,

        [int] $PollMs = 50
    )

    $want = @($Name)
    $deadline = [datetime]::UtcNow.AddMilliseconds([Math]::Max(0, $TimeoutMs))
    do {
        $services = @(Get-Service -Name $want -ErrorAction SilentlyContinue)
        $notRunning = @($services | Where-Object { $_.Status -ne 'Running' })
        if ($services.Count -eq $want.Count -and $notRunning.Count -eq 0) {
            return $true
        }
        if ([datetime]::UtcNow -ge $deadline) { break }
        Start-Sleep -Milliseconds ([Math]::Max(10, $PollMs))
    } while ($true)

    return $false
}

function Invoke-AudioRebindAudioEngine {
    [CmdletBinding()]
    param(
        [switch] $WhatIf
    )

    Write-AudioRebindLog "AudioEngine: restart AudioEndpointBuilder then Audiosrv"
    if ($WhatIf) {
        Write-AudioRebindLog "AudioEngine: WhatIf — skipping service restart"
        return $true
    }

    try {
        Restart-Service -Name 'AudioEndpointBuilder' -Force -ErrorAction Stop
        Write-AudioRebindLog "AudioEngine: AudioEndpointBuilder restarted"
    }
    catch {
        Write-AudioRebindLog ("AudioEngine: AudioEndpointBuilder failed: {0}" -f $_.Exception.Message) -Level ERROR
        return $false
    }

    if (-not (Wait-AudioRebindServiceRunning -Name @('AudioEndpointBuilder') -TimeoutMs 3000)) {
        Write-AudioRebindLog "AudioEngine: AudioEndpointBuilder not Running after restart" -Level ERROR
        return $false
    }

    try {
        Restart-Service -Name 'Audiosrv' -Force -ErrorAction Stop
        Write-AudioRebindLog "AudioEngine: Audiosrv restarted"
    }
    catch {
        Write-AudioRebindLog ("AudioEngine: Audiosrv failed: {0}" -f $_.Exception.Message) -Level ERROR
        return $false
    }

    if (-not (Wait-AudioRebindServiceRunning -Name @('Audiosrv', 'AudioEndpointBuilder') -TimeoutMs 3000)) {
        $srv = @(Get-Service -Name 'Audiosrv', 'AudioEndpointBuilder' -ErrorAction SilentlyContinue)
        foreach ($s in $srv) {
            Write-AudioRebindLog ("AudioEngine: {0} status={1}" -f $s.Name, $s.Status)
            if ($s.Status -ne 'Running') {
                Write-AudioRebindLog ("AudioEngine: {0} not Running after restart" -f $s.Name) -Level ERROR
            }
        }
        return $false
    }

    $srv = @(Get-Service -Name 'Audiosrv', 'AudioEndpointBuilder' -ErrorAction SilentlyContinue)
    foreach ($s in $srv) {
        Write-AudioRebindLog ("AudioEngine: {0} status={1}" -f $s.Name, $s.Status)
    }
    return $true
}
