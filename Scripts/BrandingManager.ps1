# BrandingManager.ps1 - Custom Branding & Technician Configuration Engine
. "$PSScriptRoot\Logger.ps1"

function Set-TechBranding {
    param(
        [string]$TechnicianName,
        [string]$CompanyName,
        [string]$ContactInfo,
        [string]$Theme = "Dark",
        [string]$ConfigPath = "$PSScriptRoot\..\Config\config.json"
    )

    if (-not (Test-Path $ConfigPath)) {
        Write-TechLog -Message "Config file not found at '$ConfigPath'." -Level "ERROR" -Category "Branding"
        return $false
    }

    try {
        $json = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
        
        if ($TechnicianName) { $json.Branding.TechnicianName = $TechnicianName }
        if ($CompanyName)    { $json.Branding.CompanyName    = $CompanyName }
        if ($ContactInfo)    { $json.Branding.ContactInfo    = $ContactInfo }
        if ($Theme)          { $json.Branding.Theme          = $Theme }

        $json | ConvertTo-Json -Depth 5 | Set-Content -Path $ConfigPath -Encoding UTF8
        Write-TechLog -Message "Custom branding updated successfully in '$ConfigPath'." -Level "SUCCESS" -Category "Branding"
        return $true
    } catch {
        Write-TechLog -Message "Failed to update branding: $_" -Level "ERROR" -Category "Branding"
        return $false
    }
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function Set-TechBranding
}
