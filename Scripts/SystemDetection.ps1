# SystemDetection.ps1 - Hardware & Operating Environment Detection Engine
. "$PSScriptRoot\Logger.ps1"

function Get-TechSystemSummary {
    Write-TechLog -Message "Gathering system hardware, firmware, and OS metrics..." -Level "INFO" -Category "Detection"

    $summary = [ordered]@{}

    # 1. Environment Mode (WinPE vs Full Windows)
    $isWinPE = Test-Path "HKLM:\System\CurrentControlSet\Control\MiniNT"
    $summary.EnvironmentMode = if ($isWinPE) { "WinPE Technician Mode" } else { "Full Windows Host Mode" }

    # 2. Operating System
    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $summary.OSName = $os.Caption
        $summary.OSVersion = $os.Version
        $summary.OSBuild = $os.BuildNumber
        $summary.Architecture = $os.OSArchitecture
        $summary.InstallDate = $os.InstallDate
    } catch {
        $summary.OSName = "Windows (Detection Limited)"
        $summary.OSVersion = "Unknown"
    }

    # 3. Boot Mode (UEFI vs Legacy BIOS) & Firmware
    try {
        $firmwareType = Get-ItemPropertyValue -Path "HKLM:\System\CurrentControlSet\Control" -Name "PEFirmwareType" -ErrorAction SilentlyContinue
        if ($firmwareType -eq 2) {
            $summary.BootMode = "UEFI"
        } elseif ($firmwareType -eq 1) {
            $summary.BootMode = "Legacy BIOS"
        } else {
            $summary.BootMode = if (Test-Path "HKLM:\System\CurrentControlSet\Control\SecureBoot\State") { "UEFI" } else { "Legacy BIOS / Unknown" }
        }
    } catch {
        $summary.BootMode = "Unknown"
    }

    # 4. Secure Boot Status
    try {
        $sbState = Get-ItemPropertyValue -Path "HKLM:\System\CurrentControlSet\Control\SecureBoot\State" -Name "UEFISecureBootEnabled" -ErrorAction SilentlyContinue
        $summary.SecureBoot = if ($sbState -eq 1) { "Enabled" } else { "Disabled / Unsupported" }
    } catch {
        $summary.SecureBoot = "Unknown"
    }

    # 5. Processor (CPU)
    try {
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        $summary.CPUModel = $cpu.Name.Trim()
        $summary.CPUCores = $cpu.NumberOfCores
        $summary.CPUThreads = $cpu.NumberOfLogicalProcessors
        $summary.CPUMaxSpeedMHz = $cpu.MaxClockSpeed
    } catch {
        $summary.CPUModel = "Unknown CPU"
    }

    # 6. Memory (RAM)
    try {
        $cs = Get-CimInstance Win32_ComputerSystem
        $totalRamGB = [math]::Round($cs.TotalPhysicalMemory / 1GB, 2)
        $osMemory = Get-CimInstance Win32_OperatingSystem
        $freeRamGB = [math]::Round($osMemory.FreePhysicalMemory / 1MB, 2)
        $summary.TotalRAMGB = $totalRamGB
        $summary.FreeRAMGB = $freeRamGB
    } catch {
        $summary.TotalRAMGB = 0
    }

    # 7. Motherboard / System Manufacturer
    try {
        $bb = Get-CimInstance Win32_BaseBoard -ErrorAction SilentlyContinue
        $sys = Get-CimInstance Win32_ComputerSystemProduct -ErrorAction SilentlyContinue
        $summary.MotherboardVendor = $bb.Manufacturer
        $summary.MotherboardModel = $bb.Product
        $summary.SystemModel = $sys.Name
    } catch {
        $summary.MotherboardVendor = "Unknown"
    }

    # 8. GPU / Graphics
    try {
        $gpus = Get-CimInstance Win32_VideoController | ForEach-Object { $_.Name }
        $summary.GPU = ($gpus -join " | ")
    } catch {
        $summary.GPU = "Standard Graphics Adapter"
    }

    # 9. Storage Disks & Partition Style (GPT/MBR)
    try {
        $disks = Get-Disk -ErrorAction SilentlyContinue | ForEach-Object {
            [ordered]@{
                Number         = $_.Number
                Model          = $_.Model
                SizeGB         = [math]::Round($_.Size / 1GB, 2)
                PartitionStyle = $_.PartitionStyle
                BusType        = $_.BusType
                HealthStatus   = $_.HealthStatus
                Operational    = $_.OperationalStatus
            }
        }
        $summary.Disks = $disks
    } catch {
        $summary.Disks = @()
    }

    # 10. BitLocker Encryption Status
    try {
        if (Get-Command Get-BitLockerVolume -ErrorAction SilentlyContinue) {
            $bl = Get-BitLockerVolume -ErrorAction SilentlyContinue | ForEach-Object {
                [ordered]@{
                    MountPoint          = $_.MountPoint
                    ProtectionStatus    = $_.ProtectionStatus
                    VolumeStatus        = $_.VolumeStatus
                    EncryptionPercentage = $_.EncryptionPercentage
                }
            }
            $summary.BitLocker = $bl
        } else {
            $summary.BitLocker = "BitLocker Module Not Loaded"
        }
    } catch {
        $summary.BitLocker = "BitLocker Check Unavailable"
    }

    # 11. Network Adapters
    try {
        $net = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object Status -eq "Up" | Select-Object Name, InterfaceDescription, MacAddress, LinkSpeed
        $summary.NetworkAdapters = $net
    } catch {
        $summary.NetworkAdapters = @()
    }

    # 12. Battery Status
    try {
        $battery = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
        if ($battery) {
            $summary.BatteryPercent = $battery.EstimatedChargeRemaining
            $summary.BatteryStatus  = $battery.BatteryStatus
        } else {
            $summary.BatteryPercent = "Desktop / No Battery"
        }
    } catch {
        $summary.BatteryPercent = "N/A"
    }

    Write-TechLog -Message "System detection completed successfully." -Level "SUCCESS" -Category "Detection"
    return $summary
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function Get-TechSystemSummary
}
