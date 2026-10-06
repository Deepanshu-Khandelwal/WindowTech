# DriverCenter.ps1 - Driver Management & Offline Injection Engine
. "$PSScriptRoot\Logger.ps1"
. "$PSScriptRoot\SafetyEngine.ps1"

function Get-TechInstalledDrivers {
    Write-TechLog -Message "Enumerating installed system drivers..." -Level "INFO" -Category "Drivers"
    try {
        $drivers = Get-CimInstance Win32_PnPSignedDriver -ErrorAction SilentlyContinue | Select-Object DeviceName, DriverVersion, DriverProviderName, HardWareID, InfName
        return $drivers
    } catch {
        return @()
    }
}

function Get-TechProblematicDrivers {
    Write-TechLog -Message "Scanning for missing or problematic hardware devices..." -Level "INFO" -Category "Drivers"
    try {
        $badDevs = Get-CimInstance Win32_PNPEntity | Where-Object ConfigManagerErrorCode -ne 0 | Select-Object Name, DeviceID, ConfigManagerErrorCode, Status
        if ($badDevs) {
            Write-TechLog -Message "Detected $($badDevs.Count) device(s) with driver errors." -Level "WARN" -Category "Drivers"
        } else {
            Write-TechLog -Message "All hardware devices report healthy driver status." -Level "SUCCESS" -Category "Drivers"
        }
        return $badDevs
    } catch {
        return @()
    }
}

function Export-TechSystemDrivers {
    param(
        [Parameter(Mandatory=$true)]
        [string]$DestinationDir,
        [switch]$DryRun
    )

    $targetText = "Target Directory [$DestinationDir]"
    if (-not (Confirm-TechAction -ActionName "Export Third-Party System Drivers" -TargetResource $targetText -RiskLevel "MEDIUM" -DryRun:$DryRun)) {
        return $false
    }

    if ($DryRun) { return $true }

    if (-not (Test-Path $DestinationDir)) { New-Item -ItemType Directory -Path $DestinationDir -Force | Out-Null }

    Write-TechLog -Message "Exporting drivers via DISM to '$DestinationDir'..." -Level "INFO" -Category "Drivers"
    dism /Online /Export-Driver /Destination:"$DestinationDir"
    
    if ($LASTEXITCODE -eq 0) {
        Write-TechLog -Message "Drivers exported successfully to '$DestinationDir'." -Level "SUCCESS" -Category "Drivers"
        return $true
    } else {
        Write-TechLog -Message "DISM Driver Export failed." -Level "ERROR" -Category "Drivers"
        return $false
    }
}

function Add-TechOfflineDrivers {
    param(
        [Parameter(Mandatory=$true)]
        [string]$OfflineTargetDir,
        [Parameter(Mandatory=$true)]
        [string]$DriverFolderPath,
        [switch]$DryRun
    )

    $targetText = "Offline Windows [$OfflineTargetDir] <- Drivers [$DriverFolderPath]"
    if (-not (Confirm-TechAction -ActionName "Inject Offline Drivers" -TargetResource $targetText -RiskLevel "MEDIUM" -DryRun:$DryRun)) {
        return $false
    }

    if ($DryRun) { return $true }

    Write-TechLog -Message "Injecting offline drivers from '$DriverFolderPath' into '$OfflineTargetDir'..." -Level "INFO" -Category "Drivers"
    dism /Image:"$OfflineTargetDir" /Add-Driver /Driver:"$DriverFolderPath" /Recurse
    
    if ($LASTEXITCODE -eq 0) {
        Write-TechLog -Message "Offline drivers injected successfully." -Level "SUCCESS" -Category "Drivers"
        return $true
    } else {
        Write-TechLog -Message "Failed to inject offline drivers." -Level "ERROR" -Category "Drivers"
        return $false
    }
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function Get-TechInstalledDrivers, Get-TechProblematicDrivers, Export-TechSystemDrivers, Add-TechOfflineDrivers
}
