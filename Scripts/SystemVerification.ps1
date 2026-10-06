# SystemVerification.ps1 - Post-Repair & Post-Deployment System Verification Engine
. "$PSScriptRoot\Logger.ps1"
. "$PSScriptRoot\SystemDetection.ps1"
. "$PSScriptRoot\BootRepair.ps1"
. "$PSScriptRoot\DriverCenter.ps1"

function Invoke-TechSystemVerification {
    Write-TechLog -Message "Starting Post-Repair / Post-Deployment System Verification Workflow..." -Level "INFO" -Category "Verification"

    $checks = [ordered]@{}
    $warnings = @()
    $failures = @()

    # 1. System Volume Accessibility
    try {
        $cDrive = Get-Volume -DriveLetter C -ErrorAction SilentlyContinue
        if ($cDrive) {
            $freeGB = [math]::Round($cDrive.SizeRemaining / 1GB, 2)
            $checks["SystemVolume"] = "PASS ($freeGB GB free on C:)"
        } else {
            $failures += "System drive C: is inaccessible or unmounted."
            $checks["SystemVolume"] = "FAIL"
        }
    } catch {
        $checks["SystemVolume"] = "UNAVAILABLE"
    }

    # 2. BCD Bootloader Configuration
    try {
        $bcd = bcdedit /enum {current} 2>&1
        if ($LASTEXITCODE -eq 0) {
            $checks["BcdBootloader"] = "PASS"
        } else {
            $warnings += "BCD current entry returned non-zero code."
            $checks["BcdBootloader"] = "WARNING"
        }
    } catch {
        $checks["BcdBootloader"] = "UNAVAILABLE"
    }

    # 3. Device Manager Problem Drivers
    try {
        $probDevs = Get-TechProblematicDrivers
        if ($probDevs.Count -gt 0) {
            $warnings += "Detected $($probDevs.Count) device(s) with driver errors."
            $checks["Drivers"] = "WARNING ($($probDevs.Count) problem devices)"
        } else {
            $checks["Drivers"] = "PASS"
        }
    } catch {
        $checks["Drivers"] = "UNAVAILABLE"
    }

    # 4. Active Network Adapters
    try {
        $net = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object Status -eq "Up"
        if ($net) {
            $checks["NetworkAdapters"] = "PASS ($(($net | ForEach-Object Name) -join ', '))"
        } else {
            $warnings += "No active network adapters currently connected."
            $checks["NetworkAdapters"] = "WARNING (No active link)"
        }
    } catch {
        $checks["NetworkAdapters"] = "UNAVAILABLE"
    }

    # 5. Core Windows Services Status
    try {
        $wuauserv = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
        if ($wuauserv) {
            $checks["WindowsUpdateService"] = "PASS ($($wuauserv.Status))"
        } else {
            $checks["WindowsUpdateService"] = "NOT TESTED"
        }
    } catch {
        $checks["WindowsUpdateService"] = "UNAVAILABLE"
    }

    # Final Overall Verification Determination
    $finalStatus = if ($failures.Count -gt 0) { "FAIL" } elseif ($warnings.Count -gt 0) { "WARNING" } else { "PASS" }

    Write-TechLog -Message "System Verification Completed. Status: $finalStatus (Failures: $($failures.Count), Warnings: $($warnings.Count))." -Level "SUCCESS" -Category "Verification"

    return New-TechResult -Success ($failures.Count -eq 0) -Status $finalStatus -Operation "SystemVerification" -Message "Post-repair verification finished." -Data @{
        Checks   = $checks
        Warnings = $warnings
        Failures = $failures
    }
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function Invoke-TechSystemVerification
}
