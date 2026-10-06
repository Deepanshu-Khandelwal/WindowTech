# BackupClone.ps1 - Backup, System Image Capture, & Disk Cloning Engine
. "$PSScriptRoot\Logger.ps1"
. "$PSScriptRoot\SafetyEngine.ps1"
. "$PSScriptRoot\DiskManager.ps1"
. "$PSScriptRoot\WimManager.ps1"

function Backup-TechFiles {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SourcePath,
        [Parameter(Mandatory=$true)]
        [string]$DestinationPath,
        [switch]$ForceNoPrompt,
        [switch]$DryRun
    )

    $targetText = "Source [$SourcePath] -> Destination [$DestinationPath]"
    if (-not (Confirm-TechAction -ActionName "File Backup (Robocopy)" -TargetResource $targetText -RiskLevel "MEDIUM" -ForceNoPrompt:$ForceNoPrompt -DryRun:$DryRun)) {
        return New-TechResult -Success $false -Status "Cancelled" -Operation "BackupFiles" -Message "Backup cancelled."
    }

    if ($DryRun) {
        return New-TechResult -Success $true -Status "DryRun" -Operation "BackupFiles" -Message "[DRY-RUN]: Would copy files from '$SourcePath' to '$DestinationPath'."
    }

    if (-not (Test-Path $DestinationPath)) {
        try {
            New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
        } catch {
            return New-TechResult -Success $false -Status "Failed" -Operation "BackupFiles" -Message "Failed to create destination directory." -Error $_
        }
    }

    Write-TechLog -Message "Starting file backup via Robocopy from '$SourcePath' to '$DestinationPath'..." -Level "INFO" -Category "Backup"
    robocopy "$SourcePath" "$DestinationPath" /E /DCOPY:DAT /COPY:DAT /R:1 /W:1 /XJ /NP /LOG+:"$PSScriptRoot\..\Logs\backup.log"
    
    $exitCode = $LASTEXITCODE
    if ($exitCode -le 7) {
        Write-TechLog -Message "File backup completed successfully (Robocopy Exit Code: $exitCode)." -Level "SUCCESS" -Category "Backup"
        return New-TechResult -Success $true -Status "Completed" -Operation "BackupFiles" -Message "Robocopy backup completed successfully." -Data @{ ExitCode = $exitCode }
    } else {
        Write-TechLog -Message "Robocopy backup reported errors (Exit Code: $exitCode)." -Level "ERROR" -Category "Backup"
        return New-TechResult -Success $false -Status "Failed" -Operation "BackupFiles" -Message "Robocopy reported errors during backup." -Data @{ ExitCode = $exitCode }
    }
}

function Capture-TechSystemImage {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SourceDriveLetter,
        [Parameter(Mandatory=$true)]
        [string]$DestinationWimPath,
        [string]$ImageName = "Windows Backup Image",
        [switch]$ForceNoPrompt,
        [switch]$DryRun
    )

    $targetText = "Drive [${SourceDriveLetter}:] -> WIM Image [$DestinationWimPath]"
    if (-not (Confirm-TechAction -ActionName "Capture Windows System WIM Image" -TargetResource $targetText -RiskLevel "MEDIUM" -ForceNoPrompt:$ForceNoPrompt -DryRun:$DryRun)) {
        return New-TechResult -Success $false -Status "Cancelled" -Operation "CaptureSystemImage" -Message "Capture cancelled."
    }

    if ($DryRun) {
        return New-TechResult -Success $true -Status "DryRun" -Operation "CaptureSystemImage" -Message "[DRY-RUN]: Would capture image of ${SourceDriveLetter}: to '$DestinationWimPath'."
    }

    $destDir = Split-Path -Parent $DestinationWimPath
    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }

    Write-TechLog -Message "Capturing system image of ${SourceDriveLetter}: to '$DestinationWimPath'..." -Level "INFO" -Category "Backup"
    dism /Capture-Image /ImageFile:"$DestinationWimPath" /CaptureDir:"${SourceDriveLetter}:\" /Name:"$ImageName" /Compress:max
    
    if ($LASTEXITCODE -eq 0) {
        Write-TechLog -Message "System image captured successfully to '$DestinationWimPath'." -Level "SUCCESS" -Category "Backup"
        return New-TechResult -Success $true -Status "Completed" -Operation "CaptureSystemImage" -Message "WIM captured successfully." -Data @{ WimPath = $DestinationWimPath }
    } else {
        Write-TechLog -Message "Failed to capture system image. DISM Exit Code: $LASTEXITCODE" -Level "ERROR" -Category "Backup"
        return New-TechResult -Success $false -Status "Failed" -Operation "CaptureSystemImage" -Message "DISM capture failed." -Error "ExitCode: $LASTEXITCODE"
    }
}

function Invoke-TechDiskCloningValidation {
    param(
        [Parameter(Mandatory=$true)]
        [int]$SourceDiskNumber,
        [Parameter(Mandatory=$true)]
        [int]$DestinationDiskNumber
    )

    if ($SourceDiskNumber -eq $DestinationDiskNumber) {
        $msg = "CRITICAL ERROR: Source Disk and Destination Disk CANNOT be identical!"
        Write-TechLog -Message $msg -Level "ERROR" -Category "Cloning"
        return New-TechResult -Success $false -Status "Rejected" -Operation "CloneValidation" -Message $msg
    }

    # Boot Media Safeguard Check
    $bootDiskNum = Get-TechBootMediaDiskNumber
    if ($bootDiskNum -ge 0 -and $DestinationDiskNumber -eq $bootDiskNum) {
        $msg = "CRITICAL SAFETY BLOCK: Destination Disk $DestinationDiskNumber is the ACTIVE TECHNICIAN BOOT DRIVE!"
        Write-TechLog -Message $msg -Level "CRITICAL" -Category "Cloning"
        return New-TechResult -Success $false -Status "Blocked" -Operation "CloneValidation" -Message $msg
    }

    $disksResult = Get-TechDisks
    $disks = $disksResult.Data

    $src = $disks | Where-Object DiskNumber -eq $SourceDiskNumber | Select-Object -First 1
    $dst = $disks | Where-Object DiskNumber -eq $DestinationDiskNumber | Select-Object -First 1

    if (-not $src -or -not $dst) {
        $msg = "Invalid source or destination disk specified."
        Write-TechLog -Message $msg -Level "ERROR" -Category "Cloning"
        return New-TechResult -Success $false -Status "Failed" -Operation "CloneValidation" -Message $msg
    }

    if ($dst.IsSystem -or $dst.IsBoot) {
        $msg = "CRITICAL SAFETY BLOCK: Destination Disk $DestinationDiskNumber is the CURRENT ACTIVE SYSTEM DISK!"
        Write-TechLog -Message $msg -Level "ERROR" -Category "Cloning"
        return New-TechResult -Success $false -Status "Blocked" -Operation "CloneValidation" -Message $msg
    }

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host " DISK CLONING & SSD MIGRATION SAFETY VALIDATION " -ForegroundColor Red
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host " SOURCE DISK (DATA READ ONLY):" -ForegroundColor Green
    Write-Host "   Disk ${SourceDiskNumber}: $($src.Model) | Size: $($src.SizeGB) GB | Bus: $($src.BusType)" -ForegroundColor White
    Write-Host ""
    Write-Host " DESTINATION DISK (WILL BE OVERWRITTEN):" -ForegroundColor Red
    Write-Host "   Disk ${DestinationDiskNumber}: $($dst.Model) | Size: $($dst.SizeGB) GB | Bus: $($dst.BusType)" -ForegroundColor White
    Write-Host "============================================================" -ForegroundColor Red

    if ($dst.SizeGB -lt $src.SizeGB) {
        Write-TechLog -Message "WARNING: Destination disk ($($dst.SizeGB) GB) is smaller than source disk ($($src.SizeGB) GB)." -Level "WARN" -Category "Cloning"
    }

    return New-TechResult -Success $true -Status "Validated" -Operation "CloneValidation" -Message "Cloning pair validated successfully." -Data @{ Source = $src; Destination = $dst }
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function Backup-TechFiles, Capture-TechSystemImage, Invoke-TechDiskCloningValidation
}
