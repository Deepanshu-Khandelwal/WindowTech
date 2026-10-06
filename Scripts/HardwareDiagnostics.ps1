# HardwareDiagnostics.ps1 - Hardware Information & Memory Diagnostic Engine
. "$PSScriptRoot\Logger.ps1"
. "$PSScriptRoot\SystemDetection.ps1"

function Export-TechHardwareReport {
    param(
        [string]$OutputPath = "$PSScriptRoot\..\Diagnostics\Hardware_Report.json"
    )

    Write-TechLog -Message "Generating complete hardware diagnostic report..." -Level "INFO" -Category "Hardware"

    $sys = Get-TechSystemSummary

    $report = [ordered]@{
        Timestamp       = Get-LogTimestamp
        SystemModel     = $sys.SystemModel
        Motherboard     = [ordered]@{ Vendor = $sys.MotherboardVendor; Model = $sys.MotherboardModel }
        Processor       = [ordered]@{ Model = $sys.CPUModel; Cores = $sys.CPUCores; Threads = $sys.CPUThreads; SpeedMHz = $sys.CPUMaxSpeedMHz }
        Memory          = [ordered]@{ TotalRAMGB = $sys.TotalRAMGB; FreeRAMGB = $sys.FreeRAMGB }
        Graphics        = $sys.GPU
        StorageDisks    = $sys.Disks
        NetworkAdapters = $sys.NetworkAdapters
        Battery         = [ordered]@{ Percent = $sys.BatteryPercent; Status = $sys.BatteryStatus }
        BootMode        = $sys.BootMode
        SecureBoot      = $sys.SecureBoot
    }

    try {
        $outDir = Split-Path -Parent $OutputPath
        if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
        $report | ConvertTo-Json -Depth 4 | Set-Content -Path $OutputPath -Encoding UTF8
        Write-TechLog -Message "Hardware report exported to '$OutputPath'." -Level "SUCCESS" -Category "Hardware"
    } catch {
        Write-TechLog -Message "Failed to export hardware report: $_" -Level "ERROR" -Category "Hardware"
    }

    return $report
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function Export-TechHardwareReport
}
