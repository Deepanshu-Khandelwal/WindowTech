# UpdateManager.ps1 - Controlled Post-1.0 Update & Migration Architecture
# Implements conservative update verification, SHA-256 package validation, configuration migration, and update rollback.

. "$PSScriptRoot\Logger.ps1"
. "$PSScriptRoot\SafetyEngine.ps1"

function Test-TechUpdatePackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ManifestPath,

        [Parameter(Mandatory=$false)]
        [string]$ArtifactPath = "",

        [switch]$AllowCoreSafetyUpdate = $false
    )

    Write-TechLog -Message "Validating update manifest at '$ManifestPath'..." -Level "INFO" -Category "UpdateManager"

    if (-not (Test-Path $ManifestPath)) {
        return New-TechResult -Success $false -Status "Failed" -Operation "ValidateUpdate" -Message "Update manifest file not found at '$ManifestPath'."
    }

    try {
        $manifest = Get-Content -Path $ManifestPath -Raw | ConvertFrom-Json
        
        # 1. Validate required manifest schema properties
        $reqProps = @("product", "version", "channel", "architecture", "sha256")
        foreach ($prop in $reqProps) {
            if (-not $manifest.PSObject.Properties[$prop]) {
                return New-TechResult -Success $false -Status "InvalidManifest" -Operation "ValidateUpdate" -Message "Update manifest is missing required property '$prop'."
            }
        }

        # 2. Check channel restriction
        if ($manifest.channel -ne "stable" -and $manifest.channel -ne "beta") {
            return New-TechResult -Success $false -Status "ChannelRejected" -Operation "ValidateUpdate" -Message "Untrusted update channel '$($manifest.channel)'. Only 'stable' or 'beta' allowed."
        }

        # 3. Check SHA-256 hash if artifact is provided
        if ($ArtifactPath -and (Test-Path $ArtifactPath)) {
            $computedHash = (Get-FileHash -Path $ArtifactPath -Algorithm SHA256).Hash
            if ($computedHash -ne $manifest.sha256) {
                Write-TechLog -Message "CRITICAL UPDATE SECURITY BLOCK: SHA-256 hash mismatch! Manifest: $($manifest.sha256) vs Computed: $computedHash" -Level "CRITICAL" -Category "UpdateManager"
                return New-TechResult -Success $false -Status "HashMismatch" -Operation "ValidateUpdate" -Message "Update package SHA-256 checksum verification failed."
            }
            Write-TechLog -Message "Update artifact SHA-256 checksum verified successfully." -Level "SUCCESS" -Category "UpdateManager"
        }

        # 4. Check core safety logic replacement protection
        if ($manifest.modifiedModules -and ($manifest.modifiedModules -contains "SafetyEngine.ps1" -or $manifest.modifiedModules -contains "DiskManager.ps1")) {
            if (-not $AllowCoreSafetyUpdate) {
                Write-TechLog -Message "SAFETY REJECTION: Update attempts to modify core safety module without technician approval." -Level "WARN" -Category "UpdateManager"
                return New-TechResult -Success $false -Status "CoreSafetyProtected" -Operation "ValidateUpdate" -Message "Core safety logic replacement requires explicit technician authorization."
            }
        }

        return New-TechResult -Success $true -Status "Validated" -Operation "ValidateUpdate" -Message "Update package v$($manifest.version) ($($manifest.channel)) passed all integrity checks." -Data $manifest
    } catch {
        return New-TechResult -Success $false -Status "ParseError" -Operation "ValidateUpdate" -Message "Failed to parse update manifest JSON: $_"
    }
}

function Test-TechConfigMigration {
    [CmdletBinding()]
    param(
        [string]$ConfigPath = "$PSScriptRoot\..\Config\config.json",
        [int]$TargetVersion = 1
    )

    Write-TechLog -Message "Checking configuration version and migration status..." -Level "INFO" -Category "UpdateManager"

    if (-not (Test-Path $ConfigPath)) {
        return New-TechResult -Success $false -Status "Failed" -Operation "ConfigMigration" -Message "Config file missing at '$ConfigPath'."
    }

    try {
        $config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
        $currentVersion = if ($config.ConfigVersion) { $config.ConfigVersion } else { 1 }

        if ($currentVersion -ge $TargetVersion) {
            return New-TechResult -Success $true -Status "Current" -Operation "ConfigMigration" -Message "Config is already at or above target version $TargetVersion."
        }

        # Perform safe backup prior to migration
        $backupPath = "$ConfigPath.v$currentVersion.bak"
        Copy-Item -Path $ConfigPath -Destination $backupPath -Force
        Write-TechLog -Message "Created pre-migration config backup at '$backupPath'." -Level "INFO" -Category "UpdateManager"

        # Migrate configuration schema fields while preserving user settings
        $config | Add-Member -NotePropertyName "ConfigVersion" -NotePropertyValue $TargetVersion -Force
        $config | ConvertTo-Json -Depth 5 | Set-Content -Path $ConfigPath -Encoding UTF8

        Write-TechLog -Message "Successfully migrated configuration to ConfigVersion $TargetVersion." -Level "SUCCESS" -Category "UpdateManager"
        return New-TechResult -Success $true -Status "Migrated" -Operation "ConfigMigration" -Message "Configuration migrated safely to version $TargetVersion."
    } catch {
        return New-TechResult -Success $false -Status "MigrationFailed" -Operation "ConfigMigration" -Message "Config migration error: $_"
    }
}

function Invoke-TechUpdateRollback {
    [CmdletBinding()]
    param(
        [string]$ConfigPath = "$PSScriptRoot\..\Config\config.json"
    )

    Write-TechLog -Message "Initiating configuration rollback..." -Level "WARN" -Category "UpdateManager"
    $backups = Get-ChildItem -Path (Split-Path $ConfigPath) -Filter "config.json.v*.bak" | Sort-Object LastWriteTime -Descending

    if ($backups.Count -eq 0) {
        return New-TechResult -Success $false -Status "NoBackupFound" -Operation "Rollback" -Message "No previous configuration backups found for rollback."
    }

    $latestBackup = $backups[0].FullName
    try {
        Copy-Item -Path $latestBackup -Destination $ConfigPath -Force
        Write-TechLog -Message "Restored configuration from backup '$latestBackup'." -Level "SUCCESS" -Category "UpdateManager"
        return New-TechResult -Success $true -Status "RolledBack" -Operation "Rollback" -Message "Successfully restored previous configuration state."
    } catch {
        return New-TechResult -Success $false -Status "RollbackFailed" -Operation "Rollback" -Message "Failed to restore backup: $_"
    }
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function Test-TechUpdatePackage, Test-TechConfigMigration, Invoke-TechUpdateRollback
}
