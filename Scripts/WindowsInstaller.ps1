# WindowsInstaller.ps1 - Windows Automated Installation & Deployment Engine
. "$PSScriptRoot\Logger.ps1"
. "$PSScriptRoot\SafetyEngine.ps1"
. "$PSScriptRoot\DiskManager.ps1"
. "$PSScriptRoot\WimManager.ps1"

function Install-TechWindowsOS {
    param(
        [Parameter(Mandatory=$true)]
        [string]$WimPath,

        [int]$ImageIndex = 1,

        [Parameter(Mandatory=$true)]
        [int]$TargetDiskNumber,

        [ValidateSet("UEFI", "Legacy")]
        [string]$BootMode = "UEFI",

        [string]$UnattendXmlPath = "",

        [string]$DriverRepositoryPath = "",

        [switch]$DryRun
    )

    Write-TechLog -Message "============================================================" -Level "INFO" -Category "WindowsInstaller"
    Write-TechLog -Message "   WINDOWS DEPLOYMENT ENGINE - AUTOMATED INSTALLATION       " -Level "INFO" -Category "WindowsInstaller"
    Write-TechLog -Message "============================================================" -Level "INFO" -Category "WindowsInstaller"

    # 1. Validate Target Disk
    $disks = Get-TechDisks
    $targetDisk = $disks | Where-Object DiskNumber -eq $TargetDiskNumber | Select-Object -First 1

    if (-not $targetDisk) {
        Write-TechLog -Message "Target Disk Number $TargetDiskNumber was not found!" -Level "ERROR" -Category "WindowsInstaller"
        return $false
    }

    # Show Target Disk Details
    $existingPartitions = Get-TechPartitions -DiskNumber $TargetDiskNumber
    $partSummary = ($existingPartitions | ForEach-Object { "Part $($_.PartitionNumber): Drive $($_.DriveLetter): ($($_.SizeGB) GB, $($_.FileSystem))" }) -join " | "

    $warningText = @"
CRITICAL DESTRUCTIVE ACTION:
Target Disk:      Disk $TargetDiskNumber ($($targetDisk.Model), $($targetDisk.SizeGB) GB, Bus: $($targetDisk.BusType))
Partition Scheme: $BootMode Installation
Existing Data:    $partSummary

ALL PARTITIONS AND DATA ON DISK $TargetDiskNumber WILL BE PERMANENTLY ERASED!
"@

    if (-not (Confirm-TechAction -ActionName "Install Windows OS (Clean Install)" -TargetResource "Disk $TargetDiskNumber ($($targetDisk.Model))" -RiskLevel "DESTRUCTIVE" -WarningDetails $warningText -DryRun:$DryRun)) {
        return $false
    }

    if ($DryRun) {
        Write-TechLog -Message "[DRY-RUN]: Simulated clean Windows installation on Disk $TargetDiskNumber." -Level "INFO" -Category "WindowsInstaller"
        return $true
    }

    # 2. Disk Partitioning
    Write-TechLog -Message "Initializing Disk $TargetDiskNumber for $BootMode installation..." -Level "INFO" -Category "WindowsInstaller"

    Clear-Disk -DiskNumber $TargetDiskNumber -RemoveData -RemoveOEM -Confirm:$false -ErrorAction Stop

    $windowsDriveLetter = "W"
    $systemDriveLetter  = "S"

    if ($BootMode -eq "UEFI") {
        # GPT Partition Scheme
        Initialize-Disk -DiskNumber $TargetDiskNumber -PartitionStyle GPT -ErrorAction Stop
        
        # 1. EFI System Partition (100 MB, FAT32)
        Write-TechLog -Message "Creating EFI System Partition (100 MB FAT32)..." -Level "INFO" -Category "WindowsInstaller"
        $efiPart = New-Partition -DiskNumber $TargetDiskNumber -Size 100MB -AssignDriveLetter -GptType "{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}" -ErrorAction Stop
        Format-Volume -Partition $efiPart -FileSystem FAT32 -NewFileSystemLabel "System" -Confirm:$false | Out-Null
        Set-Partition -DiskNumber $TargetDiskNumber -PartitionNumber $efiPart.PartitionNumber -NewDriveLetter $systemDriveLetter

        # 2. MSR Partition (16 MB)
        Write-TechLog -Message "Creating MSR Partition (16 MB)..." -Level "INFO" -Category "WindowsInstaller"
        New-Partition -DiskNumber $TargetDiskNumber -Size 16MB -GptType "{e3c9e316-0b5c-4db8-817d-f92df00215ae}" -ErrorAction Stop | Out-Null

        # 3. Primary Windows Partition (Remaining minus 614 MB for Recovery)
        Write-TechLog -Message "Creating Windows Primary Partition (NTFS)..." -Level "INFO" -Category "WindowsInstaller"
        $winPart = New-Partition -DiskNumber $TargetDiskNumber -UseMaximumSize -AssignDriveLetter -ErrorAction Stop
        Format-Volume -Partition $winPart -FileSystem NTFS -NewFileSystemLabel "Windows" -Confirm:$false | Out-Null
        Set-Partition -DiskNumber $TargetDiskNumber -PartitionNumber $winPart.PartitionNumber -NewDriveLetter $windowsDriveLetter

    } else {
        # MBR / Legacy BIOS Partition Scheme
        Initialize-Disk -DiskNumber $TargetDiskNumber -PartitionStyle MBR -ErrorAction Stop
        
        # 1. System Reserved Active Partition (500 MB)
        Write-TechLog -Message "Creating System Reserved Active Partition (500 MB)..." -Level "INFO" -Category "WindowsInstaller"
        $sysPart = New-Partition -DiskNumber $TargetDiskNumber -Size 500MB -AssignDriveLetter -IsActive -ErrorAction Stop
        Format-Volume -Partition $sysPart -FileSystem NTFS -NewFileSystemLabel "System Reserved" -Confirm:$false | Out-Null
        Set-Partition -DiskNumber $TargetDiskNumber -PartitionNumber $sysPart.PartitionNumber -NewDriveLetter $systemDriveLetter

        # 2. Primary Windows Partition
        Write-TechLog -Message "Creating Windows Primary Partition (NTFS)..." -Level "INFO" -Category "WindowsInstaller"
        $winPart = New-Partition -DiskNumber $TargetDiskNumber -UseMaximumSize -AssignDriveLetter -ErrorAction Stop
        Format-Volume -Partition $winPart -FileSystem NTFS -NewFileSystemLabel "Windows" -Confirm:$false | Out-Null
        Set-Partition -DiskNumber $TargetDiskNumber -PartitionNumber $winPart.PartitionNumber -NewDriveLetter $windowsDriveLetter
    }

    # 3. Apply WIM/ESD Image
    $targetPath = "$($windowsDriveLetter):\"
    Write-TechLog -Message "Applying Windows Image Index $ImageIndex from '$WimPath' to '$targetPath'..." -Level "INFO" -Category "WindowsInstaller"
    dism /Apply-Image /ImageFile:"$WimPath" /Index:$ImageIndex /ApplyDir:"$targetPath"
    
    if ($LASTEXITCODE -ne 0) {
        Write-TechLog -Message "FAILED to apply Windows image. DISM Exit Code: $LASTEXITCODE" -Level "ERROR" -Category "WindowsInstaller"
        return $false
    }
    Write-TechLog -Message "Windows Image applied successfully." -Level "SUCCESS" -Category "WindowsInstaller"

    # 4. Configure BCD & Boot Files
    $winDir = "$($windowsDriveLetter):\Windows"
    $sysDir = "$($systemDriveLetter):\"
    $fFlag  = if ($BootMode -eq "UEFI") { "UEFI" } else { "BIOS" }
    
    Write-TechLog -Message "Configuring BCD boot files: bcdboot $winDir /s $sysDir /f $fFlag..." -Level "INFO" -Category "WindowsInstaller"
    bcdboot "$winDir" /s "$sysDir" /f $fFlag
    if ($LASTEXITCODE -ne 0) {
        Write-TechLog -Message "BCDBoot returned warning/error code $LASTEXITCODE. Retrying with /f ALL..." -Level "WARN" -Category "WindowsInstaller"
        bcdboot "$winDir" /s "$sysDir" /f ALL
    }

    # 5. Inject Drivers (If provided)
    if ($DriverRepositoryPath -and (Test-Path $DriverRepositoryPath)) {
        Write-TechLog -Message "Injecting offline drivers from '$DriverRepositoryPath' into installed Windows OS..." -Level "INFO" -Category "WindowsInstaller"
        dism /Image:"$targetPath" /Add-Driver /Driver:"$DriverRepositoryPath" /Recurse | Out-Null
    }

    # 6. Apply Unattend Answer File (If provided)
    if ($UnattendXmlPath -and (Test-Path $UnattendXmlPath)) {
        $pantherDir = "$($windowsDriveLetter):\Windows\Panther"
        if (-not (Test-Path $pantherDir)) { New-Item -ItemType Directory -Path $pantherDir -Force | Out-Null }
        Write-TechLog -Message "Copying unattended answer file to '$pantherDir\unattend.xml'..." -Level "INFO" -Category "WindowsInstaller"
        Copy-Item -Path $UnattendXmlPath -Destination "$pantherDir\unattend.xml" -Force
    }

    Write-TechLog -Message "SUCCESS: Windows OS Deployment completed on Disk $TargetDiskNumber!" -Level "SUCCESS" -Category "WindowsInstaller"
    return $true
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function Install-TechWindowsOS
}
