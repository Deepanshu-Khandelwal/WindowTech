# PortableAppManager.ps1 - Portable Applications Repository & Launcher Engine
. "$PSScriptRoot\Logger.ps1"
. "$PSScriptRoot\SafetyEngine.ps1"

function Get-TechPortableApps {
    param(
        [string]$PortableAppsRootDir = "$PSScriptRoot\..\PortableApps"
    )

    Write-TechLog -Message "Scanning portable application repository at '$PortableAppsRootDir'..." -Level "INFO" -Category "PortableApps"

    if (-not (Test-Path $PortableAppsRootDir)) {
        return @()
    }

    $apps = @()
    $exes = Get-ChildItem -Path $PortableAppsRootDir -Recurse -Filter "*.exe" -ErrorAction SilentlyContinue

    foreach ($exe in $exes) {
        $category = $exe.Directory.Name
        $versionInfo = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($exe.FullName)
        
        $apps += [ordered]@{
            FileName     = $exe.Name
            Category     = $category
            FullPath     = $exe.FullName
            SizeMB       = [math]::Round($exe.Length / 1MB, 2)
            ProductVersion = $versionInfo.FileVersion
            Description  = if ($versionInfo.FileDescription) { $versionInfo.FileDescription } else { $exe.BaseName }
        }
    }

    Write-TechLog -Message "Discovered $($apps.Count) portable application(s)." -Level "SUCCESS" -Category "PortableApps"
    return $apps
}

function Invoke-TechPortableApp {
    param(
        [Parameter(Mandatory=$true)]
        [string]$AppExecutablePath,
        [string]$Arguments = "",
        [switch]$DryRun
    )

    if (-not (Test-Path $AppExecutablePath)) {
        Write-TechLog -Message "Portable application missing at '$AppExecutablePath'." -Level "ERROR" -Category "PortableApps"
        return $false
    }

    $appName = Split-Path -Leaf $AppExecutablePath
    if (-not (Confirm-TechAction -ActionName "Launch Portable Application" -TargetResource "$appName ($AppExecutablePath)" -RiskLevel "LOW" -DryRun:$DryRun)) {
        return $false
    }

    if ($DryRun) { return $true }

    Write-TechLog -Message "Launching portable app: $AppExecutablePath $Arguments" -Level "INFO" -Category "PortableApps"
    try {
        Start-Process -FilePath $AppExecutablePath -ArgumentList $Arguments -NoNewWindow
        Write-TechLog -Message "Launched '$appName' successfully." -Level "SUCCESS" -Category "PortableApps"
        return $true
    } catch {
        Write-TechLog -Message "Failed to launch '$appName': $_" -Level "ERROR" -Category "PortableApps"
        return $false
    }
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function Get-TechPortableApps, Invoke-TechPortableApp
}
