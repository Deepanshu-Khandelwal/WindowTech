# PluginManager.ps1 - Plugin Discovery & Dynamic Execution Engine
. "$PSScriptRoot\Logger.ps1"
. "$PSScriptRoot\SafetyEngine.ps1"

function Get-TechPlugins {
    param(
        [string]$PluginsCatalogPath = "$PSScriptRoot\..\Config\plugins.json"
    )

    if (-not (Test-Path $PluginsCatalogPath)) {
        Write-TechLog -Message "Plugin catalog file not found at '$PluginsCatalogPath'." -Level "WARN" -Category "PluginManager"
        return @()
    }

    try {
        $json = Get-Content -Path $PluginsCatalogPath -Raw | ConvertFrom-Json
        return $json.Plugins
    } catch {
        Write-TechLog -Message "Failed to parse plugins catalog: $_" -Level "ERROR" -Category "PluginManager"
        return @()
    }
}

function Invoke-TechPlugin {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PluginId,

        [string]$CustomArguments = "",
        [switch]$DryRun
    )

    $plugins = Get-TechPlugins
    $plugin = $plugins | Where-Object Id -eq $PluginId | Select-Object -First 1

    if (-not $plugin) {
        Write-TechLog -Message "Plugin with ID '$PluginId' not found." -Level "ERROR" -Category "PluginManager"
        return $false
    }

    $execPath = Join-Path "$PSScriptRoot\.." $plugin.Executable
    $targetText = "$($plugin.Name) ($execPath)"

    if (-not (Confirm-TechAction -ActionName "Execute Plugin [$($plugin.Name)]" -TargetResource $targetText -RiskLevel $plugin.SafetyLevel -DryRun:$DryRun)) {
        return $false
    }

    if ($DryRun) { return $true }

    if (-not (Test-Path $execPath)) {
        Write-TechLog -Message "Executable for plugin '$($plugin.Name)' missing at '$execPath'. Please verify file installation." -Level "WARN" -Category "PluginManager"
        return $false
    }

    $finalArgs = if ($CustomArguments) { $CustomArguments } else { $plugin.Arguments }
    Write-TechLog -Message "Launching plugin '$($plugin.Name)': $execPath $finalArgs" -Level "INFO" -Category "PluginManager"

    try {
        $proc = Start-Process -FilePath $execPath -ArgumentList $finalArgs -PassThru -NoNewWindow -Wait
        Write-TechLog -Message "Plugin '$($plugin.Name)' exited with code $($proc.ExitCode)." -Level "SUCCESS" -Category "PluginManager"
        return ($proc.ExitCode -eq 0)
    } catch {
        Write-TechLog -Message "Failed to execute plugin '$($plugin.Name)': $_" -Level "ERROR" -Category "PluginManager"
        return $false
    }
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function Get-TechPlugins, Invoke-TechPlugin
}
