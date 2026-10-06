# SafetyEngine.ps1 - Boot Media Protection & Safeguards Engine
. "$PSScriptRoot\Logger.ps1"

function Get-TechBootMediaDiskNumber {
    try {
        # Identify current running script/toolkit drive
        $toolkitPath = Resolve-Path "$PSScriptRoot\.."
        $toolkitDriveLetter = $toolkitPath.Path.Substring(0, 1)

        $part = Get-Partition -DriveLetter $toolkitDriveLetter -ErrorAction SilentlyContinue
        if ($part) {
            return $part.DiskNumber
        }

        # Check system drive if WinPE (e.g., X:) or host OS drive
        $sysDriveLetter = $env:SystemDrive.TrimEnd(":")
        $sysPart = Get-Partition -DriveLetter $sysDriveLetter -ErrorAction SilentlyContinue
        if ($sysPart) {
            return $sysPart.DiskNumber
        }
    } catch {
        Write-TechLog -Message "Could not resolve boot media disk number: $_" -Level "WARN" -Category "Safety"
    }
    return -1
}

function Confirm-TechAction {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ActionName,

        [Parameter(Mandatory=$true)]
        [string]$TargetResource,

        [ValidateSet("LOW", "MEDIUM", "HIGH", "DESTRUCTIVE")]
        [string]$RiskLevel = "MEDIUM",

        [string]$WarningDetails = "",

        [int]$TargetDiskNumber = -1,

        [string]$RequiredKeyword = "CONFIRM",

        [switch]$DryRun,

        [switch]$ForceNoPrompt
    )

    Write-TechLog -Message "Safety Check initiated for [$ActionName] on [$TargetResource] (Risk: $RiskLevel)" -Level "INFO" -Category "Safety"

    # BOOT MEDIA PROTECTION CHECK
    if ($RiskLevel -in @("HIGH", "DESTRUCTIVE") -and $TargetDiskNumber -ge 0) {
        $bootDiskNum = Get-TechBootMediaDiskNumber
        if ($bootDiskNum -ge 0 -and $TargetDiskNumber -eq $bootDiskNum) {
            $msg = "CRITICAL SAFETY BLOCK: Target Disk $TargetDiskNumber is the ACTIVE BOOT MEDIA / TECHNICIAN DRIVE! Destructive operations on active boot media are strictly forbidden."
            Write-TechLog -Message $msg -Level "CRITICAL" -Category "Safety" -Metadata @{ TargetDisk = $TargetDiskNumber; BootDisk = $bootDiskNum }
            Write-Host ""
            Write-Host "============================================================" -ForegroundColor Magenta
            Write-Host " CRITICAL SAFETY BLOCK: BOOT MEDIA PROTECTION " -ForegroundColor Magenta
            Write-Host "============================================================" -ForegroundColor Magenta
            Write-Host " Operation: $ActionName" -ForegroundColor Yellow
            Write-Host " Target:    Disk $TargetDiskNumber (ACTIVE TECHNICIAN DRIVE)" -ForegroundColor Red
            Write-Host " REASON:    Cannot format or modify active WinPE / Toolkit drive." -ForegroundColor White
            Write-Host "============================================================" -ForegroundColor Magenta
            return $false
        }
    }

    if ($DryRun) {
        Write-TechLog -Message "[DRY-RUN MODE]: Would execute '$ActionName' on '$TargetResource'. Skipping actual execution." -Level "WARN" -Category "Safety"
        return $true
    }

    if ($RiskLevel -eq "LOW") {
        return $true
    }

    if ($ForceNoPrompt -and $RiskLevel -ne "DESTRUCTIVE") {
        return $true
    }

    # High or Destructive require explicit confirmation
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host " SECURITY & DATA SAFETY WARNING [$RiskLevel RISK]" -ForegroundColor Red
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host " Action:         $ActionName" -ForegroundColor Yellow
    Write-Host " Target:         $TargetResource" -ForegroundColor Yellow
    if ($WarningDetails) {
        Write-Host " Details:        $WarningDetails" -ForegroundColor White
    }
    Write-Host "============================================================" -ForegroundColor Red

    if ($RiskLevel -eq "DESTRUCTIVE") {
        Write-Host " CRITICAL: THIS OPERATION CAN CAUSE IRREVERSIBLE DATA LOSS." -ForegroundColor Red
        Write-Host " To proceed, type '$RequiredKeyword' exactly as shown below." -ForegroundColor Yellow
        $response = Read-Host -Prompt " Confirmation Input"

        if ($response -eq $RequiredKeyword) {
            Write-TechLog -Message "User explicitly CONFIRMED destructive action: $ActionName on $TargetResource" -Level "AUDIT" -Category "Safety" -Metadata @{ Action = $ActionName; Target = $TargetResource }
            return $true
        } else {
            Write-TechLog -Message "User CANCELLED destructive action: $ActionName on $TargetResource (Input mismatch)" -Level "INFO" -Category "Safety"
            Write-Host " Operation cancelled by technician." -ForegroundColor Green
            return $false
        }
    } else {
        $response = Read-Host -Prompt " Do you wish to proceed? (Y/N)"
        if ($response -match "^[Yy]$") {
            Write-TechLog -Message "User confirmed action: $ActionName on $TargetResource" -Level "INFO" -Category "Safety"
            return $true
        } else {
            Write-TechLog -Message "User cancelled action: $ActionName on $TargetResource" -Level "INFO" -Category "Safety"
            Write-Host " Operation cancelled by technician." -ForegroundColor Green
            return $false
        }
    }
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function Confirm-TechAction, Get-TechBootMediaDiskNumber
}
