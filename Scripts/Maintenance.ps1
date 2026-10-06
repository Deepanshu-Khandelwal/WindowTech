# Maintenance.ps1 - Windows Maintenance & Disk Cleanup Module
. "$PSScriptRoot\Logger.ps1"
. "$PSScriptRoot\SafetyEngine.ps1"

function Invoke-TechTempCleanup {
    param([switch]$DryRun)

    if (-not (Confirm-TechAction -ActionName "Clear Temporary Files & Caches" -TargetResource "System & User Temp Folders" -RiskLevel "MEDIUM" -DryRun:$DryRun)) {
        return $false
    }

    if ($DryRun) { return $true }

    $tempDirs = @(
        "$env:SystemRoot\Temp",
        "$env:LOCALAPPDATA\Temp"
    )

    $freedBytes = 0

    foreach ($dir in $tempDirs) {
        if (Test-Path $dir) {
            Write-TechLog -Message "Cleaning temporary directory: $dir..." -Level "INFO" -Category "Maintenance"
            Get-ChildItem -Path $dir -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
                try {
                    $freedBytes += $_.Length
                    Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
                } catch {}
            }
        }
    }

    $freedMB = [math]::Round($freedBytes / 1MB, 2)
    Write-TechLog -Message "Temporary file cleanup complete. Freed approx $freedMB MB space." -Level "SUCCESS" -Category "Maintenance"
    return $true
}

function Get-TechRunningServices {
    Write-TechLog -Message "Gathering Windows Services status..." -Level "INFO" -Category "Maintenance"
    try {
        $svcs = Get-Service | Select-Object Name, DisplayName, Status, StartType
        return $svcs
    } catch {
        return @()
    }
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function Invoke-TechTempCleanup, Get-TechRunningServices
}
