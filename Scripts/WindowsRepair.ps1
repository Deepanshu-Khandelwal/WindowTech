# WindowsRepair.ps1 - Windows System & Component Store Repair Module
. "$PSScriptRoot\Logger.ps1"
. "$PSScriptRoot\SafetyEngine.ps1"

function Invoke-TechSFC {
    param(
        [string]$TargetVolume = "",
        [string]$WinDir = "",
        [switch]$DryRun
    )

    $targetText = if ($TargetVolume -and $WinDir) { "Offline OS [$WinDir] on volume [$TargetVolume]" } else { "Current Online OS" }
    
    if (-not (Confirm-TechAction -ActionName "System File Checker (SFC)" -TargetResource $targetText -RiskLevel "MEDIUM" -DryRun:$DryRun)) {
        return $false
    }

    if ($DryRun) { return $true }

    if ($TargetVolume -and $WinDir) {
        $cmd = "sfc /scannow /offbootdir=$TargetVolume\ /offwindir=$WinDir"
        Write-TechLog -Message "Executing Offline SFC: $cmd" -Level "INFO" -Category "Repair"
        Invoke-Expression $cmd
    } else {
        Write-TechLog -Message "Executing Online SFC: sfc /scannow" -Level "INFO" -Category "Repair"
        sfc /scannow
    }

    Write-TechLog -Message "SFC execution finished with exit code $LASTEXITCODE." -Level "SUCCESS" -Category "Repair"
}

function Invoke-TechDISMRepair {
    param(
        [ValidateSet("CheckHealth", "ScanHealth", "RestoreHealth", "ComponentCleanup")]
        [string]$Action = "RestoreHealth",
        [string]$OfflineTargetDir = "",
        [switch]$DryRun
    )

    $targetText = if ($OfflineTargetDir) { "Offline OS at [$OfflineTargetDir]" } else { "Current Online OS" }

    if (-not (Confirm-TechAction -ActionName "DISM Servicing [$Action]" -TargetResource $targetText -RiskLevel "MEDIUM" -DryRun:$DryRun)) {
        return $false
    }

    if ($DryRun) { return $true }

    if ($OfflineTargetDir) {
        $cmd = switch ($Action) {
            "CheckHealth"      { "dism /Image:$OfflineTargetDir /Cleanup-Image /CheckHealth" }
            "ScanHealth"       { "dism /Image:$OfflineTargetDir /Cleanup-Image /ScanHealth" }
            "RestoreHealth"    { "dism /Image:$OfflineTargetDir /Cleanup-Image /RestoreHealth" }
            "ComponentCleanup" { "dism /Image:$OfflineTargetDir /Cleanup-Image /StartComponentCleanup /ResetBase" }
        }
    } else {
        $cmd = switch ($Action) {
            "CheckHealth"      { "dism /Online /Cleanup-Image /CheckHealth" }
            "ScanHealth"       { "dism /Online /Cleanup-Image /ScanHealth" }
            "RestoreHealth"    { "dism /Online /Cleanup-Image /RestoreHealth" }
            "ComponentCleanup" { "dism /Online /Cleanup-Image /StartComponentCleanup /ResetBase" }
        }
    }

    Write-TechLog -Message "Executing DISM: $cmd" -Level "INFO" -Category "Repair"
    Invoke-Expression $cmd
    Write-TechLog -Message "DISM [$Action] completed with exit code $LASTEXITCODE." -Level "SUCCESS" -Category "Repair"
}

function Reset-TechWindowsUpdateCache {
    param([switch]$DryRun)

    if (-not (Confirm-TechAction -ActionName "Reset Windows Update Cache & Services" -TargetResource "wuauserv / BITS / SoftwareDistribution" -RiskLevel "MEDIUM" -DryRun:$DryRun)) {
        return $false
    }

    if ($DryRun) { return $true }

    Write-TechLog -Message "Stopping Windows Update & BITS services..." -Level "INFO" -Category "Repair"
    Stop-Service -Name wuauserv, bits, cryptsvc -Force -ErrorAction SilentlyContinue

    $sdPath = "$env:SystemRoot\SoftwareDistribution"
    if (Test-Path $sdPath) {
        Write-TechLog -Message "Clearing SoftwareDistribution cache folder..." -Level "INFO" -Category "Repair"
        Remove-Item -Path "$sdPath\*" -Recurse -Force -ErrorAction SilentlyContinue
    }

    Write-TechLog -Message "Restarting Windows Update & BITS services..." -Level "INFO" -Category "Repair"
    Start-Service -Name wuauserv, bits, cryptsvc -ErrorAction SilentlyContinue

    Write-TechLog -Message "Windows Update cache reset successfully." -Level "SUCCESS" -Category "Repair"
}

function Invoke-TechNetworkReset {
    param([switch]$DryRun)

    if (-not (Confirm-TechAction -ActionName "Network Stack Reset" -TargetResource "Winsock / TCP-IP / DNS" -RiskLevel "MEDIUM" -DryRun:$DryRun)) {
        return $false
    }

    if ($DryRun) { return $true }

    Write-TechLog -Message "Resetting Winsock catalog..." -Level "INFO" -Category "Network"
    netsh winsock reset | Out-Null

    Write-TechLog -Message "Resetting TCP/IP stack..." -Level "INFO" -Category "Network"
    netsh int ip reset | Out-Null

    Write-TechLog -Message "Flushing DNS cache..." -Level "INFO" -Category "Network"
    ipconfig /flushdns | Out-Null

    Write-TechLog -Message "Network stack reset successfully completed." -Level "SUCCESS" -Category "Network"
}

function Get-TechBsodMinidumps {
    param([string]$MinidumpDir = "$env:SystemRoot\Minidump")

    Write-TechLog -Message "Scanning for BSOD Minidump crash logs..." -Level "INFO" -Category "Repair"
    if (Test-Path $MinidumpDir) {
        $dumps = Get-ChildItem -Path $MinidumpDir -Filter "*.dmp" | Select-Object Name, Length, LastWriteTime, FullName
        return $dumps
    } else {
        return @()
    }
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function Invoke-TechSFC, Invoke-TechDISMRepair, Reset-TechWindowsUpdateCache, Invoke-TechNetworkReset, Get-TechBsodMinidumps
}
