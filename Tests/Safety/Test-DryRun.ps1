# Test-DryRun.ps1 - Safety Test for Dry-Run Preview Mode Enforcement
$root = Resolve-Path "$PSScriptRoot\..\.."
. "$root\Scripts\Logger.ps1"
. "$root\Scripts\SafetyEngine.ps1"
. "$root\Scripts\WindowsRepair.ps1"
. "$root\Scripts\DiskManager.ps1"

function Test-DryRunEnforcement {
    try {
        # Test 1: SFC DryRun
        $sfcRes = Invoke-TechSFC -DryRun:$true
        if ($sfcRes -ne $true) {
            return @{ Success = $false; Message = "SFC DryRun failed to return success preview!" }
        }

        # Test 2: Network Reset DryRun
        $netRes = Invoke-TechNetworkReset -DryRun:$true
        if ($netRes -ne $true) {
            return @{ Success = $false; Message = "Network Reset DryRun failed to return success preview!" }
        }

        # Test 3: Format DryRun
        $fmtRes = Format-TechPartition -DriveLetter "C" -FileSystem "NTFS" -DryRun:$true
        if ($fmtRes.Status -ne "DryRun" -or $fmtRes.Success -ne $true) {
            return @{ Success = $false; Message = "Format DryRun failed to prevent actual volume modification!" }
        }

        return @{ Success = $true; Message = "Dry-Run Preview Engine enforced safe simulation across SFC, Network Reset, and Format!" }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-DryRunEnforcement
