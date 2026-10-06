# MultiBootManager.ps1 - Ventoy Multi-Boot Menu & ISO Repository Manager
. "$PSScriptRoot\Logger.ps1"

function Get-TechBootIsos {
    param(
        [string]$ToolkitRootDir = "$PSScriptRoot\.."
    )

    Write-TechLog -Message "Scanning multi-boot ISO repository..." -Level "INFO" -Category "MultiBoot"

    $isoDirs = @(
        "$ToolkitRootDir\Boot",
        "$ToolkitRootDir\WindowsInstall",
        "$ToolkitRootDir\Downloads"
    )

    $isos = @()

    foreach ($dir in $isoDirs) {
        if (Test-Path $dir) {
            Get-ChildItem -Path $dir -Filter "*.iso" -ErrorAction SilentlyContinue | ForEach-Object {
                $isos += [ordered]@{
                    Name     = $_.Name
                    SizeGB   = [math]::Round($_.Length / 1GB, 2)
                    Path     = $_.FullName
                    Folder   = $_.Directory.Name
                }
            }
        }
    }

    Write-TechLog -Message "Discovered $($isos.Count) bootable ISO image(s)." -Level "SUCCESS" -Category "MultiBoot"
    return $isos
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function Get-TechBootIsos
}
