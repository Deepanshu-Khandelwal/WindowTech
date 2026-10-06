# WimManager.ps1 - WIM / ESD / ISO Inspection & Image Management Engine
. "$PSScriptRoot\Logger.ps1"
. "$PSScriptRoot\SafetyEngine.ps1"

function Get-TechWimEditions {
    param(
        [Parameter(Mandatory=$true)]
        [string]$WimPath
    )

    if (-not (Test-Path $WimPath)) {
        Write-TechLog -Message "WIM/ESD file not found at '$WimPath'." -Level "ERROR" -Category "WimManager"
        return @()
    }

    Write-TechLog -Message "Inspecting image editions inside '$WimPath'..." -Level "INFO" -Category "WimManager"
    try {
        if (Get-Command Get-WindowsImage -ErrorAction SilentlyContinue) {
            $images = Get-WindowsImage -ImagePath $WimPath -ErrorAction Stop | ForEach-Object {
                [ordered]@{
                    Index           = $_.ImageIndex
                    Name            = $_.ImageName
                    Description     = $_.ImageDescription
                    SizeGB          = [math]::Round($_.ImageSize / 1GB, 2)
                    Architecture    = $_.Architecture
                    Hal             = $_.Hal
                    Version         = $_.Version
                }
            }
            return $images
        } else {
            # Fallback to DISM CLI parsing
            $raw = dism /Get-WimInfo /WimFile:"$WimPath"
            Write-TechLog -Message "Parsed DISM raw info for '$WimPath'." -Level "INFO" -Category "WimManager"
            return $raw
        }
    } catch {
        Write-TechLog -Message "Failed to inspect WIM editions: $_" -Level "ERROR" -Category "WimManager"
        return @()
    }
}

function Mount-TechWimImage {
    param(
        [Parameter(Mandatory=$true)]
        [string]$WimPath,
        [int]$ImageIndex = 1,
        [Parameter(Mandatory=$true)]
        [string]$MountDir,
        [switch]$DryRun
    )

    $targetText = "WIM [$WimPath] Index [$ImageIndex] to MountDir [$MountDir]"
    if (-not (Confirm-TechAction -ActionName "Mount WIM Image" -TargetResource $targetText -RiskLevel "MEDIUM" -DryRun:$DryRun)) {
        return $false
    }

    if ($DryRun) { return $true }

    if (-not (Test-Path $MountDir)) {
        New-Item -ItemType Directory -Path $MountDir -Force | Out-Null
    }

    Write-TechLog -Message "Mounting WIM Index $ImageIndex to '$MountDir'..." -Level "INFO" -Category "WimManager"
    dism /Mount-Wim /WimFile:"$WimPath" /Index:$ImageIndex /MountDir:"$MountDir"
    if ($LASTEXITCODE -eq 0) {
        Write-TechLog -Message "WIM mounted successfully to '$MountDir'." -Level "SUCCESS" -Category "WimManager"
        return $true
    } else {
        Write-TechLog -Message "Failed to mount WIM." -Level "ERROR" -Category "WimManager"
        return $false
    }
}

function Unmount-TechWimImage {
    param(
        [Parameter(Mandatory=$true)]
        [string]$MountDir,
        [switch]$Commit,
        [switch]$DryRun
    )

    $actionText = if ($Commit) { "Unmount WIM (COMMIT CHANGES)" } else { "Unmount WIM (DISCARD CHANGES)" }
    if (-not (Confirm-TechAction -ActionName $actionText -TargetResource $MountDir -RiskLevel "MEDIUM" -DryRun:$DryRun)) {
        return $false
    }

    if ($DryRun) { return $true }

    $flag = if ($Commit) { "/Commit" } else { "/Discard" }
    Write-TechLog -Message "Unmounting WIM at '$MountDir' ($flag)..." -Level "INFO" -Category "WimManager"
    [gc]::Collect()
    dism /Unmount-Wim /MountDir:"$MountDir" $flag
    if ($LASTEXITCODE -eq 0) {
        Write-TechLog -Message "WIM unmounted successfully." -Level "SUCCESS" -Category "WimManager"
        return $true
    } else {
        Write-TechLog -Message "Failed to unmount WIM." -Level "ERROR" -Category "WimManager"
        return $false
    }
}

function Export-TechWimImage {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SourceWimPath,
        [int]$SourceIndex = 1,
        [Parameter(Mandatory=$true)]
        [string]$DestinationWimPath,
        [switch]$CompressMax,
        [switch]$DryRun
    )

    $targetText = "Export Index $SourceIndex from [$SourceWimPath] -> [$DestinationWimPath]"
    if (-not (Confirm-TechAction -ActionName "Export / Compress WIM" -TargetResource $targetText -RiskLevel "MEDIUM" -DryRun:$DryRun)) {
        return $false
    }

    if ($DryRun) { return $true }

    $compFlag = if ($CompressMax) { "/Compress:max" } else { "/Compress:fast" }
    Write-TechLog -Message "Exporting WIM Index $SourceIndex ($compFlag)..." -Level "INFO" -Category "WimManager"
    dism /Export-Image /SourceImageFile:"$SourceWimPath" /SourceIndex:$SourceIndex /DestinationImageFile:"$DestinationWimPath" $compFlag
    if ($LASTEXITCODE -eq 0) {
        Write-TechLog -Message "WIM exported successfully to '$DestinationWimPath'." -Level "SUCCESS" -Category "WimManager"
        return $true
    } else {
        Write-TechLog -Message "Failed to export WIM." -Level "ERROR" -Category "WimManager"
        return $false
    }
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function Get-TechWimEditions, Mount-TechWimImage, Unmount-TechWimImage, Export-TechWimImage
}
