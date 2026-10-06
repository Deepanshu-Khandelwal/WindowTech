# DiskManager.ps1 - Safe Disk & Partition Management Module
. "$PSScriptRoot\Logger.ps1"
. "$PSScriptRoot\SafetyEngine.ps1"

function Get-TechDisks {
    Write-TechLog -Message "Enumerating attached storage drives..." -Level "INFO" -Category "DiskManager"
    try {
        $physicalDisks = Get-PhysicalDisk -ErrorAction SilentlyContinue
        $disks = Get-Disk -ErrorAction Stop | ForEach-Object {
            $diskNum = $_.Number
            $phys = $physicalDisks | Where-Object DeviceId -eq $diskNum | Select-Object -First 1
            [ordered]@{
                DiskNumber     = $_.Number
                FriendlyName   = $_.FriendlyName
                Model          = $_.Model
                SizeGB         = [math]::Round($_.Size / 1GB, 2)
                PartitionStyle = $_.PartitionStyle
                BusType        = $_.BusType
                HealthStatus   = if ($phys) { $phys.HealthStatus } else { $_.HealthStatus }
                Operational    = $_.OperationalStatus
                IsBoot         = $_.IsBoot
                IsSystem       = $_.IsSystem
                IsReadOnly     = $_.IsReadOnly
                MediaType      = if ($phys) { $phys.MediaType } else { "Unknown" }
            }
        }
        return New-TechResult -Success $true -Status "Completed" -Operation "GetDisks" -Message "Enumerated $($disks.Count) disk(s)." -Data $disks
    } catch {
        Write-TechLog -Message "Disk enumeration failed: $_" -Level "ERROR" -Category "DiskManager"
        return New-TechResult -Success $false -Status "Failed" -Operation "GetDisks" -Message "Disk enumeration failed." -Error $_
    }
}

function Get-TechPartitions {
    param([int]$DiskNumber)
    try {
        $parts = Get-Partition -DiskNumber $DiskNumber -ErrorAction Stop | ForEach-Object {
            $vol = $_ | Get-Volume -ErrorAction SilentlyContinue
            [ordered]@{
                DiskNumber      = $_.DiskNumber
                PartitionNumber = $_.PartitionNumber
                DriveLetter     = if ($_.DriveLetter) { $_.DriveLetter } else { "None" }
                SizeGB          = [math]::Round($_.Size / 1GB, 2)
                Type            = $_.Type
                FileSystem      = if ($vol) { $vol.FileSystem } else { "Unknown" }
                FileSystemLabel = if ($vol) { $vol.FileSystemLabel } else { "" }
            }
        }
        return New-TechResult -Success $true -Status "Completed" -Operation "GetPartitions" -Message "Enumerated partitions on Disk $DiskNumber." -Data $parts
    } catch {
        return New-TechResult -Success $false -Status "Failed" -Operation "GetPartitions" -Message "Partition query failed for Disk $DiskNumber." -Error $_
    }
}

function Format-TechPartition {
    param(
        [Parameter(Mandatory=$true)]
        [string]$DriveLetter,

        [ValidateSet("NTFS", "FAT32", "exFAT")]
        [string]$FileSystem = "NTFS",

        [string]$Label = "TECH_VOLUME",

        [switch]$DryRun
    )

    # Resolve Disk Number of target drive letter for boot protection
    $diskNum = -1
    try {
        $part = Get-Partition -DriveLetter $DriveLetter -ErrorAction SilentlyContinue
        if ($part) { $diskNum = $part.DiskNumber }
    } catch {}

    $targetText = "Drive Letter [${DriveLetter}:] with FileSystem [$FileSystem] and Label [$Label]"
    $warning = "Formatting drive ${DriveLetter}: will permanently ERASE all files on this partition!"

    if (-not (Confirm-TechAction -ActionName "Format Partition" -TargetResource $targetText -RiskLevel "DESTRUCTIVE" -WarningDetails $warning -TargetDiskNumber $diskNum -DryRun:$DryRun)) {
        return New-TechResult -Success $false -Status "Cancelled" -Operation "FormatPartition" -Message "Formatting cancelled by user or safety block."
    }

    if ($DryRun) {
        return New-TechResult -Success $true -Status "DryRun" -Operation "FormatPartition" -Message "[DRY-RUN]: Would format ${DriveLetter}: as $FileSystem."
    }

    Write-TechLog -Message "Executing format on ${DriveLetter}: as $FileSystem ($Label)..." -Level "WARN" -Category "DiskManager"
    try {
        Format-Volume -DriveLetter $DriveLetter -FileSystem $FileSystem -NewFileSystemLabel $Label -Confirm:$false -ErrorAction Stop | Out-Null
        Write-TechLog -Message "Successfully formatted drive ${DriveLetter}: as $FileSystem." -Level "SUCCESS" -Category "DiskManager"
        return New-TechResult -Success $true -Status "Completed" -Operation "FormatPartition" -Message "Successfully formatted drive ${DriveLetter}:."
    } catch {
        Write-TechLog -Message "Failed to format drive ${DriveLetter}: $_" -Level "ERROR" -Category "DiskManager"
        return New-TechResult -Success $false -Status "Failed" -Operation "FormatPartition" -Message "Failed to format drive ${DriveLetter}:." -Error $_
    }
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function Get-TechDisks, Get-TechPartitions, Format-TechPartition
}
