# Install powershell-yaml for CurrentUser when it is missing (setup only).

function Install-AudioRebindYamlModuleIfMissing {
    if (Get-Module -ListAvailable -Name powershell-yaml) {
        Write-Host "powershell-yaml: already available for CurrentUser"
        return
    }

    Write-Host "powershell-yaml: not found; installing with Install-Module -Scope CurrentUser ..."
    try {
        # PS 5.1 + PSGallery often needs TLS 1.2
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        Install-Module -Name powershell-yaml -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
    }
    catch {
        Exit-AudioRebindSetupFailure -Kind Module -Detail $_.Exception.Message
    }

    if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
        Exit-AudioRebindSetupFailure -Kind Module -Detail "Install-Module finished but 'powershell-yaml' is still not listed for this user."
    }
    Write-Host "powershell-yaml: installed for CurrentUser"
}
