# DataRecovery.ps1 - Data Recovery & User Profile Preservation Module
. "$PSScriptRoot\Logger.ps1"
. "$PSScriptRoot\SafetyEngine.ps1"
. "$PSScriptRoot\BackupClone.ps1"

function Backup-TechUserDataWizard {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SourceWindowsDriveLetter,
        [Parameter(Mandatory=$true)]
        [string]$TargetDestinationDir,
        [switch]$IncludeBrowserProfiles,
        [switch]$DryRun
    )

    $usersPath = "${SourceWindowsDriveLetter}:\Users"
    if (-not (Test-Path $usersPath)) {
        Write-TechLog -Message "Users profile folder not found at '$usersPath'." -Level "ERROR" -Category "DataRecovery"
        return $false
    }

    $profiles = Get-ChildItem -Path $usersPath -Directory | Where-Object Name -not-in @("Public", "Default", "All Users", "Default User")

    Write-TechLog -Message "Discovered $($profiles.Count) user profile(s) on ${SourceWindowsDriveLetter}:" -Level "INFO" -Category "DataRecovery"

    $foldersToCopy = @("Desktop", "Documents", "Downloads", "Pictures", "Videos", "Music")

    foreach ($profile in $profiles) {
        $username = $profile.Name
        Write-TechLog -Message "Processing user profile: $username..." -Level "INFO" -Category "DataRecovery"

        foreach ($folder in $foldersToCopy) {
            $srcFolder = Join-Path $profile.FullName $folder
            if (Test-Path $srcFolder) {
                $dstFolder = Join-Path $TargetDestinationDir "$username\$folder"
                Write-TechLog -Message "  Backing up '$folder' -> '$dstFolder'..." -Level "INFO" -Category "DataRecovery"
                Backup-TechFiles -SourcePath $srcFolder -DestinationPath $dstFolder -DryRun:$DryRun | Out-Null
            }
        }

        if ($IncludeBrowserProfiles) {
            $chromeData = Join-Path $profile.FullName "AppData\Local\Google\Chrome\User Data"
            if (Test-Path $chromeData) {
                $dstChrome = Join-Path $TargetDestinationDir "$username\BrowserProfiles\Chrome"
                Write-TechLog -Message "  Backing up Chrome browser profile..." -Level "INFO" -Category "DataRecovery"
                Backup-TechFiles -SourcePath $chromeData -DestinationPath $dstChrome -DryRun:$DryRun | Out-Null
            }

            $edgeData = Join-Path $profile.FullName "AppData\Local\Microsoft\Edge\User Data"
            if (Test-Path $edgeData) {
                $dstEdge = Join-Path $TargetDestinationDir "$username\BrowserProfiles\Edge"
                Write-TechLog -Message "  Backing up Edge browser profile..." -Level "INFO" -Category "DataRecovery"
                Backup-TechFiles -SourcePath $edgeData -DestinationPath $dstEdge -DryRun:$DryRun | Out-Null
            }
        }
    }

    Write-TechLog -Message "SUCCESS: User profile data wizard backup complete!" -Level "SUCCESS" -Category "DataRecovery"
    return $true
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function Backup-TechUserDataWizard
}
