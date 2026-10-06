# Download-WindowsISOs.ps1 - Windows 10 / Windows 11 ISO Official Acquisition Utility
# Guides technicians on acquiring official Microsoft Windows ISO images for deployment and repair.

param(
    [string]$IsoTargetDir = "$PSScriptRoot"
)

. "$PSScriptRoot\..\Scripts\Logger.ps1"

Write-TechLog -Message "============================================================" -Level "INFO" -Category "IsoDownloader"
Write-TechLog -Message "   WINDOWS 10 / 11 OFFICIAL ISO ACQUISITION GUIDANCE      " -Level "INFO" -Category "IsoDownloader"
Write-TechLog -Message "============================================================" -Level "INFO" -Category "IsoDownloader"

Write-Host "Official Microsoft Windows ISO Download Links:" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------" -ForegroundColor Gray
Write-Host "1. Windows 11 Official ISO Download:" -ForegroundColor Yellow
Write-Host "   https://www.microsoft.com/software-download/windows11" -ForegroundColor White
Write-Host ""
Write-Host "2. Windows 10 Official ISO Download:" -ForegroundColor Yellow
Write-Host "   https://www.microsoft.com/software-download/windows10" -ForegroundColor White
Write-Host "------------------------------------------------------------" -ForegroundColor Gray

Write-TechLog -Message "Scanning '$IsoTargetDir' for existing Windows ISO images..." -Level "INFO" -Category "IsoDownloader"

$isos = Get-ChildItem -Path $IsoTargetDir -Filter "*.iso" -ErrorAction SilentlyContinue

if ($isos.Count -gt 0) {
    Write-TechLog -Message "Found $($isos.Count) Windows ISO file(s) in '$IsoTargetDir':" -Level "SUCCESS" -Category "IsoDownloader"
    foreach ($iso in $isos) {
        Write-TechLog -Message "  - $($iso.Name) ($([math]::Round($iso.Length / 1GB, 2)) GB)" -Level "INFO" -Category "IsoDownloader"
    }
} else {
    Write-TechLog -Message "No ISO files found in '$IsoTargetDir'. Please download official Windows 10/11 ISOs and place them in this folder." -Level "WARN" -Category "IsoDownloader"
}

# Open official download pages if interactive
$openChoice = Read-Host "Would you like to open official Microsoft Windows download pages in browser? (Y/N)"
if ($openChoice -eq 'Y' -or $openChoice -eq 'y') {
    Start-Process "https://www.microsoft.com/software-download/windows11"
    Start-Process "https://www.microsoft.com/software-download/windows10"
}
