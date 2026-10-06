# Download-PortableTools.ps1 - Automated Technician Utilities Downloader
# Fetches essential open-source and official technician tools from official repositories into Tools/ and PortableApps/

. "$PSScriptRoot\Logger.ps1"

function Invoke-TechPortableToolsDownloader {
    [CmdletBinding()]
    param(
        [string]$TargetDir = "$PSScriptRoot\..\Tools",
        [string]$PortableAppsDir = "$PSScriptRoot\..\PortableApps"
    )

    Write-TechLog -Message "============================================================" -Level "INFO" -Category "ToolDownloader"
    Write-TechLog -Message "   AUTOMATED TECHNICIAN PORTABLE TOOLS DOWNLOADER          " -Level "INFO" -Category "ToolDownloader"
    Write-TechLog -Message "============================================================" -Level "INFO" -Category "ToolDownloader"

    if (-not (Test-Path $TargetDir)) { New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null }

    $toolsToDownload = @(
        @{
            Name        = "Sysinternals Suite (Process Explorer, Autoruns, ProcMon)"
            Url         = "https://download.sysinternals.com/files/SysinternalsSuite.zip"
            OutFile     = "$TargetDir\SysinternalsSuite.zip"
            ExtractDir  = "$TargetDir\Sysinternals"
            Category    = "Diagnostics"
        },
        @{
            Name        = "7-Zip Portable Command Line Tool"
            Url         = "https://www.7-zip.org/a/7zr.exe"
            OutFile     = "$TargetDir\7zr.exe"
            Category    = "Compression"
        },
        @{
            Name        = "smartmontools (smartctl.exe)"
            Url         = "https://sourceforge.net/projects/smartmontools/files/smartmontools/7.4/smartmontools-7.4-1.win32-setup.exe/download"
            OutFile     = "$TargetDir\smartctl-setup.exe"
            Category    = "Disk"
        }
    )

    # Enable TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    foreach ($tool in $toolsToDownload) {
        Write-TechLog -Message "Downloading $($tool.Name)..." -Level "INFO" -Category "ToolDownloader"
        try {
            Invoke-WebRequest -Uri $tool.Url -OutFile $tool.OutFile -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" -UseBasicParsing -ErrorAction Stop
            Write-TechLog -Message "  Successfully downloaded: $($tool.Name)" -Level "SUCCESS" -Category "ToolDownloader"

            if ($tool.ExtractDir -and (Test-Path $tool.OutFile)) {
                Write-TechLog -Message "  Extracting archive to '$($tool.ExtractDir)'..." -Level "INFO" -Category "ToolDownloader"
                Expand-Archive -Path $tool.OutFile -DestinationPath $tool.ExtractDir -Force -ErrorAction SilentlyContinue
            }
        } catch {
            Write-TechLog -Message "  Download failed for $($tool.Name): $_" -Level "WARN" -Category "ToolDownloader"
        }
    }

    Write-TechLog -Message "Scanning PortableApps repository structure..." -Level "INFO" -Category "ToolDownloader"
    . "$PSScriptRoot\PortableAppManager.ps1"
    $appResult = Get-TechPortableApps

    Write-TechLog -Message "Portable Tools Download & Inventory completed." -Level "SUCCESS" -Category "ToolDownloader"
    return New-TechResult -Success $true -Status "Completed" -Operation "DownloadPortableTools" -Message "Portable tools download completed."
}

if ($MyInvocation.InvocationName -ne '.' -and -not $MyInvocation.MyCommand.ScriptBlock.Module) {
    Invoke-TechPortableToolsDownloader
} else {
    if ($MyInvocation.MyCommand.ScriptBlock.Module) {
        Export-ModuleMember -Function Invoke-TechPortableToolsDownloader
    }
}
