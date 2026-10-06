# SelfCheck.ps1 - Toolkit Self-Check Engine
# Validates the integrity, configuration, module availability, and safety state of the technician environment itself.

. "$PSScriptRoot\Logger.ps1"
. "$PSScriptRoot\SafetyEngine.ps1"

function Get-TechSelfCheck {
    [CmdletBinding()]
    param()

    Write-TechLog -Message "Starting Toolkit Self-Check procedure..." -Level "INFO" -Category "SelfCheck"

    $results = [ordered]@{
        VersionCheck  = "NOT RUN"
        ConfigCheck   = "NOT RUN"
        ModuleCheck   = "NOT RUN"
        SafetyEngine  = "NOT RUN"
        Dependencies  = "NOT RUN"
        LicenseManifest = "NOT RUN"
        OverallStatus = "NOT READY"
    }

    $warnings = @()
    $errors = @()

    # 1. Version Check
    $verFile = Join-Path $PSScriptRoot "..\Config\version.json"
    $cfgFile = Join-Path $PSScriptRoot "..\Config\config.json"

    if ((Test-Path $verFile) -and (Test-Path $cfgFile)) {
        try {
            $verJson = Get-Content -Path $verFile -Raw | ConvertFrom-Json
            $cfgJson = Get-Content -Path $cfgFile -Raw | ConvertFrom-Json

            if ($verJson.Version -eq $cfgJson.Version) {
                $results.VersionCheck = "PASS (v$($verJson.Version))"
            } else {
                $results.VersionCheck = "MISMATCH (version.json: $($verJson.Version) vs config.json: $($cfgJson.Version))"
                $warnings += "Version mismatch detected between version.json and config.json."
            }
        } catch {
            $results.VersionCheck = "FAIL ($_)"
            $errors += "Failed to parse version JSON configuration files."
        }
    } else {
        $results.VersionCheck = "MISSING"
        $errors += "version.json or config.json missing."
    }

    # 2. Configuration & Security Rules Check
    if (Test-Path $cfgFile) {
        try {
            $cfgJson = Get-Content -Path $cfgFile -Raw | ConvertFrom-Json
            $sec = $cfgJson.Security
            if ($sec -and ($sec.AllowCredentialTheft -eq $false) -and ($sec.AllowActivationBypass -eq $false) -and ($sec.EnforceBitLockerProtection -eq $true)) {
                $results.ConfigCheck = "PASS"
            } else {
                $results.ConfigCheck = "SECURITY_VIOLATION"
                $errors += "Configuration contains unsafe security flag overrides."
            }
        } catch {
            $results.ConfigCheck = "FAIL ($_)"
            $errors += "Config schema parse failed."
        }
    }

    # 3. Core Module Integrity Check
    $scriptDir = $PSScriptRoot
    $modules = Get-ChildItem -Path $scriptDir -Filter "*.ps1"
    $failedModules = @()

    foreach ($m in $modules) {
        try {
            $tokens = $null
            $parseErrors = $null
            [System.Management.Automation.Language.Parser]::ParseFile($m.FullName, [ref]$tokens, [ref]$parseErrors)
            if ($parseErrors.Count -gt 0) {
                $failedModules += $m.Name
            }
        } catch {
            $failedModules += $m.Name
        }
    }

    if ($failedModules.Count -eq 0) {
        $results.ModuleCheck = "PASS ($($modules.Count)/$($modules.Count) modules parsed)"
    } else {
        $results.ModuleCheck = "FAIL (Failed: $($failedModules -join ', '))"
        $errors += "Module syntax errors in: $($failedModules -join ', ')"
    }

    # 4. Safety Engine Verification
    try {
        $bootMediaDisk = Get-TechBootMediaDiskNumber
        if ($bootMediaDisk -ne $null) {
            $results.SafetyEngine = "PASS (Active Boot Media Disk: $bootMediaDisk)"
        } else {
            $results.SafetyEngine = "WARNING (Active Boot Media Disk undetermined)"
            $warnings += "Boot Media Disk detection returned null; conservative block active."
        }
    } catch {
        $results.SafetyEngine = "FAIL ($_)"
        $errors += "SafetyEngine execution error: $_"
    }

    # 5. External Tools & Dependencies
    $reqBins = @("dism.exe", "sfc.exe", "bcdboot.exe", "robocopy.exe")
    $missingBins = @()
    foreach ($bin in $reqBins) {
        if (-not (Get-Command $bin -ErrorAction SilentlyContinue)) {
            $missingBins += $bin
        }
    }
    if ($missingBins.Count -eq 0) {
        $results.Dependencies = "PASS"
    } else {
        $results.Dependencies = "WARNING (Missing: $($missingBins -join ', '))"
        $warnings += "System missing native tools: $($missingBins -join ', ')"
    }

    # 6. License Catalog Manifest
    $licManifest = Join-Path $PSScriptRoot "..\ThirdPartyLicenses\manifest.json"
    if (Test-Path $licManifest) {
        $results.LicenseManifest = "PASS"
    } else {
        $results.LicenseManifest = "MISSING"
        $warnings += "ThirdPartyLicenses/manifest.json is missing."
    }

    # 7. Overall Evaluation
    if ($errors.Count -gt 0) {
        $results.OverallStatus = "NOT READY"
    } elseif ($warnings.Count -gt 0) {
        $results.OverallStatus = "WARNING"
    } else {
        $results.OverallStatus = "READY"
    }

    Write-TechLog -Message "Toolkit Self-Check finished with status '$($results.OverallStatus)'." -Level "SUCCESS" -Category "SelfCheck"

    return New-TechResult -Success ($results.OverallStatus -ne "NOT READY") -Status $results.OverallStatus -Operation "SelfCheck" -Message "Self-Check complete. Status: $($results.OverallStatus)" -Data $results
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function Get-TechSelfCheck
}
