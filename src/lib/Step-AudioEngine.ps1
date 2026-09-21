# Step AudioEngine: restart AudioEndpointBuilder then Audiosrv (ADR 0006).

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

    Start-Sleep -Seconds 1

    try {
        Restart-Service -Name 'Audiosrv' -Force -ErrorAction Stop
        Write-AudioRebindLog "AudioEngine: Audiosrv restarted"
    }
    catch {
        Write-AudioRebindLog ("AudioEngine: Audiosrv failed: {0}" -f $_.Exception.Message) -Level ERROR
        return $false
    }

    Start-Sleep -Seconds 1
    $srv = Get-Service -Name 'Audiosrv', 'AudioEndpointBuilder' -ErrorAction SilentlyContinue
    foreach ($s in $srv) {
        Write-AudioRebindLog ("AudioEngine: {0} status={1}" -f $s.Name, $s.Status)
        if ($s.Status -ne 'Running') {
            Write-AudioRebindLog ("AudioEngine: {0} not Running after restart" -f $s.Name) -Level ERROR
            return $false
        }
    }
    return $true
}
