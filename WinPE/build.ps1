# build.ps1 - Automated WinPE Image Build System
# Generates a bootable WinPE ISO containing the Ultimate PC Technician Toolkit

param(
    [string]$AdkPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit",
    [string]$WorkingDir = "$env:SystemDrive\WinPE_Tech_Build",
    [string]$OutputIsoPath = "$PSScriptRoot\..\Build\Output\UltimateTechnician-x64.iso",
    [switch]$DryRun
)

. "$PSScriptRoot\..\Scripts\Logger.ps1"
. "$PSScriptRoot\..\Scripts\SafetyEngine.ps1"

Write-TechLog -Message "============================================================" -Level "INFO" -Category "WinPEBuild"
Write-TechLog -Message "   ULTIMATE PC TECHNICIAN TOOLKIT - WINPE BUILDER SYSTEM   " -Level "INFO" -Category "WinPEBuild"
Write-TechLog -Message "============================================================" -Level "INFO" -Category "WinPEBuild"

if (-not (Confirm-TechAction -ActionName "Build WinPE ISO" -TargetResource $OutputIsoPath -RiskLevel "MEDIUM" -DryRun:$DryRun)) {
    return New-TechResult -Success $false -Status "Cancelled" -Operation "BuildWinPE" -Message "Build cancelled by user."
}

if ($DryRun) {
    Write-TechLog -Message "[DRY-RUN]: Verified build environment. ISO build target: $OutputIsoPath" -Level "INFO" -Category "WinPEBuild"
    return New-TechResult -Success $true -Status "DryRun" -Operation "BuildWinPE" -Message "[DRY-RUN]: Verified prerequisites."
}

# 1. Verify ADK Installation
$dismEnv = Join-Path $AdkPath "Deployment Tools\DismCmds.cmd"
$winpeEnv = Join-Path $AdkPath "Windows Preinstallation Environment\copype.cmd"

if (-not (Test-Path $winpeEnv)) {
    $msg = "Microsoft Windows ADK with WinPE Add-on was not found at '$AdkPath'."
    Write-TechLog -Message $msg -Level "ERROR" -Category "WinPEBuild"
    Write-TechLog -Message "Please install Windows ADK and WinPE Add-on from official Microsoft website: https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install" -Level "INFO" -Category "WinPEBuild"
    return New-TechResult -Success $false -Status "PrerequisiteMissing" -Operation "BuildWinPE" -Message $msg
}

# 2. Prepare WinPE Workspace
if (Test-Path $WorkingDir) {
    Write-TechLog -Message "Cleaning existing workspace at '$WorkingDir'..." -Level "INFO" -Category "WinPEBuild"
    try {
        Remove-Item -Path $WorkingDir -Recurse -Force -ErrorAction Stop
    } catch {
        Write-TechLog -Message "Warning: Workspace clean emitted non-fatal error: $_" -Level "WARN" -Category "WinPEBuild"
    }
}

Write-TechLog -Message "Creating WinPE x64 workspace at '$WorkingDir'..." -Level "INFO" -Category "WinPEBuild"
$copyProc = Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$winpeEnv`" amd64 `"$WorkingDir`"" -NoNewWindow -PassThru -Wait
if ($copyProc.ExitCode -ne 0) {
    $msg = "copype.cmd failed with exit code $($copyProc.ExitCode)."
    Write-TechLog -Message $msg -Level "ERROR" -Category "WinPEBuild"
    return New-TechResult -Success $false -Status "Failed" -Operation "BuildWinPE" -Message $msg
}

$wimFile = Join-Path $WorkingDir "media\sources\boot.wim"
$mountDir = Join-Path $WorkingDir "mount"

if (-not (Test-Path $wimFile)) {
    $msg = "Failed to locate boot.wim in working directory."
    Write-TechLog -Message $msg -Level "ERROR" -Category "WinPEBuild"
    return New-TechResult -Success $false -Status "Failed" -Operation "BuildWinPE" -Message $msg
}

# 3. Mount WIM Image
Write-TechLog -Message "Mounting boot.wim to '$mountDir'..." -Level "INFO" -Category "WinPEBuild"
dism /Mount-Wim /WimFile:"$wimFile" /Index:1 /MountDir:"$mountDir"
if ($LASTEXITCODE -ne 0) {
    $msg = "DISM Mount-Wim failed with exit code $LASTEXITCODE."
    Write-TechLog -Message $msg -Level "ERROR" -Category "WinPEBuild"
    return New-TechResult -Success $false -Status "Failed" -Operation "BuildWinPE" -Message $msg
}

# 4. Inject Optional Components (NetFX, WMI, PowerShell, StorageWMI)
$ocPath = Join-Path $AdkPath "Windows Preinstallation Environment\amd64\WinPE_OCs"
$packages = @(
    "WinPE-WMI.cab",
    "WinPE-NetFX.cab",
    "WinPE-Scripting.cab",
    "WinPE-PowerShell.cab",
    "WinPE-StorageWMI.cab",
    "WinPE-DSH.cab",
    "WinPE-FM.cab"
)

Write-TechLog -Message "Injecting WinPE optional components..." -Level "INFO" -Category "WinPEBuild"
foreach ($pkg in $packages) {
    $pkgPath = Join-Path $ocPath $pkg
    if (Test-Path $pkgPath) {
        Write-TechLog -Message "  Adding package: $pkg" -Level "INFO" -Category "WinPEBuild"
        dism /Image:"$mountDir" /Add-Package /PackagePath:"$pkgPath" | Out-Null
    }
}

# 5. Configure Startnet.cmd & Startup Launch
$startnetPath = Join-Path $mountDir "Windows\System32\startnet.cmd"
$startupScript = @"
@echo off
wpeinit
echo Initializing Ultimate PC Technician Environment...
powershell.exe -ExecutionPolicy Bypass -NoExit -File "X:\UltimateTechnician\GUI\TechnicianUI.ps1"
"@
Set-Content -Path $startnetPath -Value $startupScript -Encoding ASCII

# 6. Copy Toolkit Files into WinPE Image
$toolkitDest = Join-Path $mountDir "UltimateTechnician"
$toolkitSource = (Resolve-Path "$PSScriptRoot\..").Path
Write-TechLog -Message "Embedding Technician Toolkit files from '$toolkitSource' into WinPE..." -Level "INFO" -Category "WinPEBuild"
Copy-Item -Path $toolkitSource -Destination $toolkitDest -Recurse -Force -Exclude "Logs","WinPE_Tech_Build","Build\Output"

# 7. Unmount & Commit WIM
Write-TechLog -Message "Unmounting and committing boot.wim..." -Level "INFO" -Category "WinPEBuild"
dism /Unmount-Wim /MountDir:"$mountDir" /Commit
if ($LASTEXITCODE -ne 0) {
    $msg = "DISM Unmount-Wim commit failed with exit code $LASTEXITCODE."
    Write-TechLog -Message $msg -Level "ERROR" -Category "WinPEBuild"
    return New-TechResult -Success $false -Status "Failed" -Operation "BuildWinPE" -Message $msg
}

# 8. Generate ISO & SHA-256 Hash Artifacts
$makeMediaCmd = Join-Path $AdkPath "Windows Preinstallation Environment\MakeWinPEMedia.cmd"
$isoDir = Split-Path -Parent $OutputIsoPath
if (-not (Test-Path $isoDir)) { New-Item -ItemType Directory -Path $isoDir -Force | Out-Null }

Write-TechLog -Message "Building bootable ISO at '$OutputIsoPath'..." -Level "INFO" -Category "WinPEBuild"
$isoProc = Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$makeMediaCmd`" /ISO `"$WorkingDir`" `"$OutputIsoPath`"" -NoNewWindow -PassThru -Wait

if (Test-Path $OutputIsoPath) {
    Write-TechLog -Message "Calculating SHA-256 checksum for release ISO..." -Level "INFO" -Category "WinPEBuild"
    $hash = Get-FileHash -Path $OutputIsoPath -Algorithm SHA256
    $hashFile = "$OutputIsoPath.sha256"
    Set-Content -Path $hashFile -Value "$($hash.Hash) *$([System.IO.Path]::GetFileName($OutputIsoPath))" -Encoding ASCII

    $verJson = Get-Content -Path (Join-Path $PSScriptRoot "..\Config\version.json") -Raw | ConvertFrom-Json
    $reportPath = Join-Path $isoDir "build-report.json"
    $reportData = [ordered]@{
        BuildDate = (Get-Date).ToString("o")
        Product   = "Ultimate PC Technician"
        Version   = $verJson.Version
        IsoPath   = $OutputIsoPath
        Sha256    = $hash.Hash
    }
    $reportData | ConvertTo-Json -Depth 3 | Set-Content -Path $reportPath -Encoding UTF8

    Write-TechLog -Message "SUCCESS: Ultimate PC Technician WinPE ISO generated at '$OutputIsoPath' (SHA256: $($hash.Hash))." -Level "SUCCESS" -Category "WinPEBuild"
    return New-TechResult -Success $true -Status "Completed" -Operation "BuildWinPE" -Message "WinPE ISO built successfully." -Data $reportData
} else {
    $msg = "MakeWinPEMedia failed to produce ISO at '$OutputIsoPath'."
    Write-TechLog -Message $msg -Level "ERROR" -Category "WinPEBuild"
    return New-TechResult -Success $false -Status "Failed" -Operation "BuildWinPE" -Message $msg
}
