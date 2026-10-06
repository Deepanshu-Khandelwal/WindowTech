# Test-DiskTargetValidation.ps1 - Safety Test for Invalid & Ambiguous Disk Target Validation
$root = Resolve-Path "$PSScriptRoot\..\.."
. "$root\Scripts\Logger.ps1"
. "$PSScriptRoot\..\..\Scripts\SafetyEngine.ps1"
. "$root\Scripts\DiskManager.ps1"

function Test-DiskTargetValidation {
    try {
        # Test 1: Invalid Disk Number (-99)
        $partsRes = Get-TechPartitions -DiskNumber -99
        if ($partsRes.Success -ne $false) {
            return @{ Success = $false; Message = "DiskManager allowed querying invalid negative disk number!" }
        }

        # Test 2: Formatting invalid drive letter (Z9:)
        $fmtRes = Format-TechPartition -DriveLetter "Z9" -DryRun:$true
        if ($fmtRes.Success -ne $false) {
            return @{ Success = $false; Message = "DiskManager allowed formatting non-existent drive letter Z9:" }
        }

        return @{ Success = $true; Message = "Disk Target Validation successfully rejected invalid disk numbers and drive letters!" }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-DiskTargetValidation
