# BootRepair.ps1 - Bootloader, BCD, & Recovery Environment Repair Module
. "$PSScriptRoot\Logger.ps1"
. "$PSScriptRoot\SafetyEngine.ps1"

function Get-TechBcdEntries {
    Write-TechLog -Message "Inspecting BCD bootloader configuration..." -Level "INFO" -Category "BootRepair"
    try {
        $bcd = bcdedit /enum all 2>&1
        return ($bcd -join "`r`n")
    } catch {
        Write-TechLog -Message "Failed to read BCD entries: $_" -Level "ERROR" -Category "BootRepair"
        return "BCD Read Failed"
    }
}

function Repair-TechEfiBoot {
    param(
        [Parameter(Mandatory=$true)]
        [string]$EfiPartitionDriveLetter,
        [Parameter(Mandatory=$true)]
        [string]$WindowsDirectory,
        [switch]$DryRun
    )

    $targetText = "EFI Partition [${EfiPartitionDriveLetter}:] using OS [$WindowsDirectory]"
    if (-not (Confirm-TechAction -ActionName "Repair EFI Bootloader" -TargetResource $targetText -RiskLevel "HIGH" -DryRun:$DryRun)) {
        return $false
    }

    if ($DryRun) { return $true }

    Write-TechLog -Message "Formatting EFI partition ${EfiPartitionDriveLetter}: as FAT32..." -Level "INFO" -Category "BootRepair"
    Format-Volume -DriveLetter $EfiPartitionDriveLetter -FileSystem FAT32 -NewFileSystemLabel "System" -Confirm:$false | Out-Null

    Write-TechLog -Message "Rebuilding EFI bootloader files via BCDBoot..." -Level "INFO" -Category "BootRepair"
    bcdboot "$WindowsDirectory" /s "${EfiPartitionDriveLetter}:" /f UEFI
    if ($LASTEXITCODE -eq 0) {
        Write-TechLog -Message "EFI bootloader successfully rebuilt." -Level "SUCCESS" -Category "BootRepair"
        return $true
    } else {
        Write-TechLog -Message "BCDBoot EFI repair failed with exit code $LASTEXITCODE." -Level "ERROR" -Category "BootRepair"
        return $false
    }
}

function Repair-TechMbrBoot {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SystemPartitionDriveLetter,
        [Parameter(Mandatory=$true)]
        [string]$WindowsDirectory,
        [switch]$DryRun
    )

    $targetText = "System Partition [${SystemPartitionDriveLetter}:] using OS [$WindowsDirectory]"
    if (-not (Confirm-TechAction -ActionName "Repair MBR Boot Sector & BCD" -TargetResource $targetText -RiskLevel "HIGH" -DryRun:$DryRun)) {
        return $false
    }

    if ($DryRun) { return $true }

    Write-TechLog -Message "Executing bootsect /nt60 ALL /mbr..." -Level "INFO" -Category "BootRepair"
    bootsect /nt60 ALL /mbr | Out-Null

    Write-TechLog -Message "Rebuilding MBR boot files via BCDBoot..." -Level "INFO" -Category "BootRepair"
    bcdboot "$WindowsDirectory" /s "${SystemPartitionDriveLetter}:" /f BIOS
    if ($LASTEXITCODE -eq 0) {
        Write-TechLog -Message "MBR Boot sector and BCD successfully rebuilt." -Level "SUCCESS" -Category "BootRepair"
        return $true
    } else {
        Write-TechLog -Message "MBR boot repair failed." -Level "ERROR" -Category "BootRepair"
        return $false
    }
}

function Get-TechWinReStatus {
    param([string]$TargetWinDir = "")
    Write-TechLog -Message "Checking Windows Recovery Environment (WinRE) status..." -Level "INFO" -Category "BootRepair"
    try {
        if ($TargetWinDir) {
            $cmd = "reagentc /info /target $TargetWinDir"
        } else {
            $cmd = "reagentc /info"
        }
        $info = Invoke-Expression $cmd 2>&1
        return ($info -join "`r`n")
    } catch {
        return "WinRE check unavailable"
    }
}

function Enable-TechWinRe {
    param([string]$TargetWinDir = "", [switch]$DryRun)

    $targetText = if ($TargetWinDir) { "Target OS [$TargetWinDir]" } else { "Current OS" }
    if (-not (Confirm-TechAction -ActionName "Enable Windows Recovery Environment (WinRE)" -TargetResource $targetText -RiskLevel "MEDIUM" -DryRun:$DryRun)) {
        return $false
    }

    if ($DryRun) { return $true }

    $cmd = if ($TargetWinDir) { "reagentc /enable /target $TargetWinDir" } else { "reagentc /enable" }
    Write-TechLog -Message "Executing WinRE Enable: $cmd" -Level "INFO" -Category "BootRepair"
    Invoke-Expression $cmd
    Write-TechLog -Message "WinRE Enable operation completed." -Level "SUCCESS" -Category "BootRepair"
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function Get-TechBcdEntries, Repair-TechEfiBoot, Repair-TechMbrBoot, Get-TechWinReStatus, Enable-TechWinRe
}
