# Config.Tests.ps1 - Unit Tests for Toolkit Configuration System
$root = Resolve-Path "$PSScriptRoot\..\.."
$configPath = "$root\Config\config.json"

function Test-ConfigLoading {
    if (-not (Test-Path $configPath)) {
        return @{ Success = $false; Message = "config.json missing" }
    }

    try {
        $json = Get-Content -Path $configPath -Raw | ConvertFrom-Json
        
        if ($json.ToolkitName -ne "Ultimate PC Technician Toolkit") {
            return @{ Success = $false; Message = "ToolkitName mismatch" }
        }

        if (-not $json.Security.EnforceBitLockerProtection) {
            return @{ Success = $false; Message = "BitLocker protection flag not true" }
        }

        return @{ Success = $true; Message = "Config validated successfully" }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-ConfigLoading
