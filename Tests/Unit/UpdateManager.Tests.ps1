# UpdateManager.Tests.ps1 - Unit Test for Update & Migration Engine
$root = Resolve-Path "$PSScriptRoot\..\.."
. "$root\Scripts\UpdateManager.ps1"

function Test-UpdateManagerEngine {
    # 1. Test update manifest validation
    $manifestPath = "$root\Build\release-manifest.json"
    $valResult = Test-TechUpdatePackage -ManifestPath $manifestPath

    if (-not $valResult.Success) {
        return @{ Success = $false; Message = "Update package validation failed for release-manifest.json: $($valResult.Message)" }
    }

    # 2. Test configuration migration check
    $migResult = Test-TechConfigMigration -ConfigPath "$root\Config\config.json" -TargetVersion 1
    if (-not $migResult.Success) {
        return @{ Success = $false; Message = "Config migration test failed: $($migResult.Message)" }
    }

    return @{ Success = $true; Message = "UpdateManager manifest validation and config migration tests PASSED 100%!" }
}

Test-UpdateManagerEngine
