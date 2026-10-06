# BootMediaProtection.Tests.ps1 - Safety Engine Unit Test for Active Boot Disk Protection
$root = Resolve-Path "$PSScriptRoot\..\.."
. "$root\Scripts\Logger.ps1"
. "$root\Scripts\SafetyEngine.ps1"

function Test-BootMediaProtection {
    try {
        $bootDiskNum = Get-TechBootMediaDiskNumber
        if ($bootDiskNum -lt 0) {
            return @{ Success = $false; Message = "Could not resolve active boot disk number" }
        }

        # Attempt destructive action targeting active boot disk
        $safetyAllowed = Confirm-TechAction -ActionName "Wipe Disk" -TargetResource "Disk $bootDiskNum" -RiskLevel "DESTRUCTIVE" -TargetDiskNumber $bootDiskNum -DryRun:$false

        if ($safetyAllowed -eq $false) {
            return @{ Success = $true; Message = "Safety Engine SUCCESSFULLY BLOCKED destructive action on active boot media Disk $bootDiskNum!" }
        } else {
            return @{ Success = $false; Message = "CRITICAL FAILURE: Safety Engine allowed formatting active boot disk!" }
        }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-BootMediaProtection
