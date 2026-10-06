# Create-TechnicianUSB.ps1 - Bootable USB & External SSD Creation Wizard
. "$PSScriptRoot\Logger.ps1"
. "$PSScriptRoot\SafetyEngine.ps1"
. "$PSScriptRoot\DiskManager.ps1"

function Invoke-TechUsbWizard {
    param(
        [int]$TargetDiskNumber = -1,
        [switch]$DryRun
    )

    Write-TechLog -Message "============================================================" -Level "INFO" -Category "USBBuilder"
    Write-TechLog -Message "  BOOTABLE USB & EXTERNAL SSD PREPARATION WIZARD            " -Level "INFO" -Category "USBBuilder"
    Write-TechLog -Message "============================================================" -Level "INFO" -Category "USBBuilder"

    # Discover Boot Media Disk to prevent self-formatting
    $bootDiskNum = Get-TechBootMediaDiskNumber

    # 1. Discover Target Disks
    $disksResult = Get-TechDisks
    $disks = $disksResult.Data | Where-Object { 
        $_.BusType -in @("USB", "NVMe", "SATA", "SCSI", "RAID") -and 
        $_.IsSystem -eq $false -and 
        $_.IsBoot -eq $false -and 
        $_.DiskNumber -ne $bootDiskNum 
    }

    if (-not $disks) {
        $msg = "No suitable external USB or non-system storage drives found."
        Write-TechLog -Message $msg -Level "WARN" -Category "USBBuilder"
        Write-Host "Please attach a USB Flash Drive or External HDD/SSD and run this script again." -ForegroundColor Yellow
        return New-TechResult -Success $false -Status "NoDrives" -Operation "CreateUSB" -Message $msg
    }

    Write-Host "Available Target Disks for Technician Toolkit Installation:" -ForegroundColor Cyan
    Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Gray
    foreach ($d in $disks) {
        Write-Host " [Disk $($d.DiskNumber)] Model: $($d.Model) | Size: $($d.SizeGB) GB | Bus: $($d.BusType) | PartitionStyle: $($d.PartitionStyle)" -ForegroundColor White
    }
    Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Gray

    if ($TargetDiskNumber -lt 0) {
        $inputNum = Read-Host -Prompt "Enter the Disk Number to install Technician Toolkit onto (e.g. 1)"
        if ($inputNum -match "^\d+$") {
            $TargetDiskNumber = [int]$inputNum
        } else {
            $msg = "Invalid disk number specified."
            Write-TechLog -Message $msg -Level "ERROR" -Category "USBBuilder"
            return New-TechResult -Success $false -Status "InvalidInput" -Operation "CreateUSB" -Message $msg
        }
    }

    $selectedDisk = $disks | Where-Object DiskNumber -eq $TargetDiskNumber | Select-Object -First 1

    if (-not $selectedDisk) {
        $msg = "Specified Disk Number $TargetDiskNumber is not a valid target drive."
        Write-TechLog -Message $msg -Level "ERROR" -Category "USBBuilder"
        return New-TechResult -Success $false -Status "InvalidTarget" -Operation "CreateUSB" -Message $msg
    }

    # 2. Safety Safeguard Confirmation
    $targetDesc = "Disk $TargetDiskNumber ($($selectedDisk.Model), $($selectedDisk.SizeGB) GB, Bus: $($selectedDisk.BusType))"
    $warning = "ALL EXISTING DATA ON DISK $TargetDiskNumber WILL BE DELETED AND RE-PARTITIONED!"

    if (-not (Confirm-TechAction -ActionName "Format & Create Technician USB/SSD" -TargetResource $targetDesc -RiskLevel "DESTRUCTIVE" -WarningDetails $warning -TargetDiskNumber $TargetDiskNumber -DryRun:$DryRun)) {
        return New-TechResult -Success $false -Status "Cancelled" -Operation "CreateUSB" -Message "Operation cancelled by safety check."
    }

    if ($DryRun) {
        Write-TechLog -Message "[DRY-RUN]: Would format and deploy Technician Toolkit to Disk $TargetDiskNumber ($($selectedDisk.Model))." -Level "INFO" -Category "USBBuilder"
        return New-TechResult -Success $true -Status "DryRun" -Operation "CreateUSB" -Message "[DRY-RUN]: Verified target disk $TargetDiskNumber."
    }

    # 3. Format and Create Partitions
    Write-TechLog -Message "Preparing Disk $TargetDiskNumber for Technician Toolkit installation..." -Level "INFO" -Category "USBBuilder"

    try {
        Clear-Disk -DiskNumber $TargetDiskNumber -RemoveData -RemoveOEM -Confirm:$false -ErrorAction Stop
        Initialize-Disk -DiskNumber $TargetDiskNumber -PartitionStyle GPT -ErrorAction Stop

        $bootPart = New-Partition -DiskNumber $TargetDiskNumber -Size 2GB -AssignDriveLetter -GptType "{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}" -ErrorAction Stop
        $bootVol = Format-Volume -Partition $bootPart -FileSystem FAT32 -NewFileSystemLabel "TECH_BOOT" -Confirm:$false -ErrorAction Stop

        $dataPart = New-Partition -DiskNumber $TargetDiskNumber -UseMaximumSize -AssignDriveLetter -ErrorAction Stop
        $dataVol = Format-Volume -Partition $dataPart -FileSystem NTFS -NewFileSystemLabel "TECH_DATA" -Confirm:$false -ErrorAction Stop

        $sourceDir = (Resolve-Path "$PSScriptRoot\..").Path
        $targetPath = "$($dataPart.DriveLetter):\UltimateTechnician"
        Write-TechLog -Message "Deploying Ultimate Technician Toolkit from '$sourceDir' to '$targetPath'..." -Level "INFO" -Category "USBBuilder"

        Copy-Item -Path $sourceDir -Destination $targetPath -Recurse -Force -ErrorAction Stop

        Write-TechLog -Message "SUCCESS: Ultimate PC Technician Toolkit installed to Disk $TargetDiskNumber ($($dataPart.DriveLetter):)." -Level "SUCCESS" -Category "USBBuilder"
        return New-TechResult -Success $true -Status "Completed" -Operation "CreateUSB" -Message "USB/SSD created successfully." -Data @{ TargetDisk = $TargetDiskNumber; DataDrive = $dataPart.DriveLetter; BootDrive = $bootPart.DriveLetter }

    } catch {
        Write-TechLog -Message "Failed to prepare Technician USB/SSD: $_" -Level "ERROR" -Category "USBBuilder"
        return New-TechResult -Success $false -Status "Failed" -Operation "CreateUSB" -Message "Failed to prepare Technician USB/SSD." -Error $_
    }
}

if ($MyInvocation.InvocationName -ne '.' -and -not $MyInvocation.MyCommand.ScriptBlock.Module) {
    Invoke-TechUsbWizard
} else {
    if ($MyInvocation.MyCommand.ScriptBlock.Module) {
        Export-ModuleMember -Function Invoke-TechUsbWizard
    }
}
