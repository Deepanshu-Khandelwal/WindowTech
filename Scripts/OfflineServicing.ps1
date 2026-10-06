# OfflineServicing.ps1 - Offline Windows Installation Discovery & Servicing
. "$PSScriptRoot\Logger.ps1"
. "$PSScriptRoot\SafetyEngine.ps1"

function Find-TechOfflineWindowsInstallations {
    Write-TechLog -Message "Scanning all volumes for offline Windows installations..." -Level "INFO" -Category "OfflineServicing"
    $found = @()
    $index = 1

    try {
        $drives = Get-Volume | Where-Object { $_.DriveLetter } | Select-Object -ExpandProperty DriveLetter

        foreach ($drive in $drives) {
            $winDir = "${drive}:\Windows"
            $sys32Dir = "$winDir\System32"
            $ntoskrnl = "$sys32Dir\ntoskrnl.exe"

            if (Test-Path $ntoskrnl) {
                $versionInfo = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($ntoskrnl)
                
                $found += [ordered]@{
                    CandidateId   = $index
                    DriveLetter   = "$drive"
                    WindowsPath   = $winDir
                    System32Path  = $sys32Dir
                    KernelVersion = $versionInfo.FileVersion
                    BuildNumber   = $versionInfo.FileBuildPart
                    IsSystemDrive = ($drive -eq $env:SystemDrive[0])
                }
                Write-TechLog -Message "Found Candidate ${index}: '$winDir' (Kernel Build: $($versionInfo.FileBuildPart))." -Level "SUCCESS" -Category "OfflineServicing"
                $index++
            }
        }
        return New-TechResult -Success $true -Status "Completed" -Operation "FindOfflineWindows" -Message "Found $($found.Count) candidate Windows installation(s)." -Data $found
    } catch {
        Write-TechLog -Message "Failed to scan offline Windows installations: $_" -Level "ERROR" -Category "OfflineServicing"
        return New-TechResult -Success $false -Status "Failed" -Operation "FindOfflineWindows" -Message "Volume scan failed." -Error $_
    }
}

function Select-TechOfflineWindowsInstallation {
    param(
        [int]$CandidateId = -1
    )

    $res = Find-TechOfflineWindowsInstallations
    $candidates = $res.Data

    if (-not $candidates -or $candidates.Count -eq 0) {
        Write-TechLog -Message "No offline Windows installations detected on connected drives." -Level "WARN" -Category "OfflineServicing"
        return $null
    }

    if ($CandidateId -gt 0) {
        $selected = $candidates | Where-Object CandidateId -eq $CandidateId | Select-Object -First 1
        if ($selected) { return $selected }
    }

    # If only 1 candidate found, return it
    if ($candidates.Count -eq 1) {
        return $candidates[0]
    }

    # Display candidates for technician choice
    Write-Host "Multiple Offline Windows Candidates Detected:" -ForegroundColor Cyan
    foreach ($c in $candidates) {
        Write-Host " [Candidate $($c.CandidateId)] Drive $($c.DriveLetter): ($($c.WindowsPath) | Build: $($c.BuildNumber))" -ForegroundColor White
    }

    $inputNum = Read-Host -Prompt "Select Offline Windows Candidate Number (1-$($candidates.Count))"
    if ($inputNum -match "^\d+$") {
        $cid = [int]$inputNum
        return $candidates | Where-Object CandidateId -eq $cid | Select-Object -First 1
    }

    return $candidates[0]
}

function Mount-TechOfflineRegistryHive {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SoftwareHivePath,

        [string]$HiveMountName = "OFFLINE_SOFTWARE"
    )

    if (-not (Test-Path $SoftwareHivePath)) {
        Write-TechLog -Message "Registry hive not found at '$SoftwareHivePath'." -Level "ERROR" -Category "OfflineServicing"
        return New-TechResult -Success $false -Status "NotFound" -Operation "MountHive" -Message "Hive path missing."
    }

    Write-TechLog -Message "Mounting offline hive '$SoftwareHivePath' as 'HKLM\$HiveMountName'..." -Level "INFO" -Category "OfflineServicing"
    reg load "HKLM\$HiveMountName" "$SoftwareHivePath" | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-TechLog -Message "Registry hive loaded successfully." -Level "SUCCESS" -Category "OfflineServicing"
        return New-TechResult -Success $true -Status "Completed" -Operation "MountHive" -Message "Hive mounted successfully."
    } else {
        Write-TechLog -Message "Failed to load registry hive." -Level "ERROR" -Category "OfflineServicing"
        return New-TechResult -Success $false -Status "Failed" -Operation "MountHive" -Message "reg load failed."
    }
}

function Dismount-TechOfflineRegistryHive {
    param(
        [string]$HiveMountName = "OFFLINE_SOFTWARE"
    )

    Write-TechLog -Message "Dismounting offline hive 'HKLM\$HiveMountName'..." -Level "INFO" -Category "OfflineServicing"
    [gc]::Collect()
    reg unload "HKLM\$HiveMountName" | Out-Null
    return New-TechResult -Success ($LASTEXITCODE -eq 0) -Status "Completed" -Operation "DismountHive" -Message "Hive dismounted."
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function Find-TechOfflineWindowsInstallations, Select-TechOfflineWindowsInstallation, Mount-TechOfflineRegistryHive, Dismount-TechOfflineRegistryHive
}
