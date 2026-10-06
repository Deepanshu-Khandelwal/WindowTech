# HealthCheck.ps1 - Automated 10-Point PC Health Check Engine
. "$PSScriptRoot\Logger.ps1"
. "$PSScriptRoot\SystemDetection.ps1"

function Start-TechAutomatedHealthCheck {
    param(
        [string]$ReportOutputPath = "$PSScriptRoot\..\Diagnostics\PC_Health_Report.json"
    )

    Write-TechLog -Message "Starting Automated 10-Point PC Health Check..." -Level "INFO" -Category "HealthCheck"

    $problems = @()
    $warnings = @()
    $recommendations = @()
    $score = 100

    # Step 1: System Hardware Metrics
    $sys = Get-TechSystemSummary
    Write-TechLog -Message "Evaluated system hardware profile for $($sys.OSName)." -Level "INFO" -Category "HealthCheck"

    if ($sys.TotalRAMGB -lt 4.0) {
        $warnings += "Low System Memory: $($sys.TotalRAMGB) GB RAM installed (Minimum 4 GB recommended)."
        $recommendations += "Upgrade RAM to at least 8 GB for optimal Windows performance."
        $score -= 10
    }

    # Step 2: Storage & Disk SMART Health
    $unhealthyDisks = $sys.Disks | Where-Object { $_.HealthStatus -ne "Healthy" -and $_.HealthStatus -ne $null }
    if ($unhealthyDisks) {
        foreach ($disk in $unhealthyDisks) {
            $problems += "Disk Critical: Disk $($disk.Number) ($($disk.Model)) reports HealthStatus = '$($disk.HealthStatus)'."
            $recommendations += "IMMEDIATE BACKUP REQUIRED: Replace disk $($disk.Number) ($($disk.Model)) before complete failure."
            $score -= 35
        }
    }

    # Step 3: Low System Drive Free Space
    try {
        $sysDrive = Get-Volume -DriveLetter C -ErrorAction SilentlyContinue
        if ($sysDrive) {
            $freeGB = [math]::Round($sysDrive.SizeRemaining / 1GB, 2)
            $totalGB = [math]::Round($sysDrive.Size / 1GB, 2)
            $percentFree = [math]::Round(($sysDrive.SizeRemaining / $sysDrive.Size) * 100, 1)

            if ($percentFree -lt 10.0) {
                $problems += "Critical Disk Space: Drive C: has only $freeGB GB free ($percentFree% free)."
                $recommendations += "Perform Windows Component Store & Temp Cleanup to free space on C:."
                $score -= 20
            } elseif ($percentFree -lt 20.0) {
                $warnings += "Low Disk Space: Drive C: has $freeGB GB free ($percentFree% free)."
                $recommendations += "Clean temporary files and cache using Windows Maintenance Center."
                $score -= 10
            }
        }
    } catch {}

    # Step 4: BitLocker Recovery Warning
    if ($sys.BitLocker -is [array] -or $sys.BitLocker -is [PSCustomObject]) {
        foreach ($bl in $sys.BitLocker) {
            if ($bl.ProtectionStatus -eq "On" -and $bl.VolumeStatus -ne "FullyEncrypted") {
                $warnings += "BitLocker Volume $($bl.MountPoint) encryption is in progress or paused."
            }
        }
    }

    # Step 5: Bootloader / BCD Integrity Check
    try {
        $bcdResult = bcdedit /enum {current} 2>&1
        if ($LASTEXITCODE -ne 0) {
            $warnings += "BCD Integrity Warning: Unable to inspect current BCD boot entries."
            $recommendations += "Run BCD Repair tool to rebuild Windows bootloader configuration."
            $score -= 15
        }
    } catch {
        $warnings += "BCD tool unavailable in current environment."
    }

    # Step 6: Windows Services Health (wuauserv, BITS, WinDefend)
    $criticalServices = @("wuauserv", "BITS", "WinDefend")
    foreach ($svcName in $criticalServices) {
        try {
            $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
            if ($svc -and $svc.Status -eq "Stopped" -and $svc.StartType -ne "Disabled") {
                $warnings += "Service Warning: Essential service '$svcName' ($($svc.DisplayName)) is currently stopped."
                $recommendations += "Check Windows Services Manager and restart '$svcName'."
                $score -= 5
            }
        } catch {}
    }

    # Step 7: System Event Log Critical Errors (Last 24 Hours)
    try {
        $yesterday = (Get-Date).AddDays(-1)
        $critEvents = Get-WinEvent -FilterHashtable @{LogName='System'; Level=1; StartTime=$yesterday} -ErrorAction SilentlyContinue
        if ($critEvents) {
            $critCount = ($critEvents | Measure-Object).Count
            $problems += "System Stability Warning: Detected $critCount Critical Event Log errors in the last 24 hours."
            $recommendations += "Inspect Event Log in Windows Maintenance Center for hardware/driver crash logs."
            $score -= 15
        }
    } catch {}

    # Step 8: Network Adapter Check
    if (-not $sys.NetworkAdapters) {
        $warnings += "Network Disconnected: No active online network adapters detected."
        $recommendations += "Run Network Repair wizard to inspect drivers and reset Winsock/IP stack."
        $score -= 5
    }

    # Final Overall Health Calculation
    $statusColor = if ($score -ge 85 -and $problems.Count -eq 0) { "GREEN" } elseif ($score -ge 60) { "YELLOW" } else { "RED" }

    $report = [ordered]@{
        Timestamp       = Get-LogTimestamp
        OverallStatus   = $statusColor
        HealthScore     = [math]::Max(0, $score)
        SystemSummary   = $sys
        CriticalProblems = $problems
        Warnings        = $warnings
        Recommendations = $recommendations
    }

    # Save JSON Report
    try {
        $outDir = Split-Path -Parent $ReportOutputPath
        if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
        $report | ConvertTo-Json -Depth 5 | Set-Content -Path $ReportOutputPath -Encoding UTF8
        Write-TechLog -Message "PC Health Report saved to '$ReportOutputPath' (Status: $statusColor, Score: $score/100)." -Level "SUCCESS" -Category "HealthCheck"
    } catch {
        Write-TechLog -Message "Failed to save PC Health Report: $_" -Level "ERROR" -Category "HealthCheck"
    }

    return $report
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function Start-TechAutomatedHealthCheck
}
