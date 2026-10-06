# CloningSafety.Tests.ps1 - Unit Test for Disk Cloning Safety Validation
$root = Resolve-Path "$PSScriptRoot\..\.."
. "$root\Scripts\Logger.ps1"
. "$root\Scripts\SafetyEngine.ps1"
. "$root\Scripts\DiskManager.ps1"
. "$root\Scripts\WimManager.ps1"
. "$root\Scripts\BackupClone.ps1"

function Test-CloningSafety {
    try {
        # Test 1: Identical Source and Destination
        $res1 = Invoke-TechDiskCloningValidation -SourceDiskNumber 0 -DestinationDiskNumber 0
        if ($res1.Success -ne $false) {
            return @{ Success = $false; Message = "Cloning safety allowed identical source and destination disks!" }
        }

        # Test 2: Destination is Boot Media Disk
        $bootDiskNum = Get-TechBootMediaDiskNumber
        if ($bootDiskNum -ge 0) {
            $otherDisk = if ($bootDiskNum -eq 0) { 1 } else { 0 }
            $res2 = Invoke-TechDiskCloningValidation -SourceDiskNumber $otherDisk -DestinationDiskNumber $bootDiskNum
            if ($res2.Success -ne $false) {
                return @{ Success = $false; Message = "Cloning safety allowed destination to be active boot media!" }
            }
        }

        return @{ Success = $true; Message = "Cloning Safety Validation successfully rejected unsafe pairs!" }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-CloningSafety
