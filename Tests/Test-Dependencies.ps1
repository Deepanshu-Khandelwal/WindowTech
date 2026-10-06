# Test-Dependencies.ps1 - Automated Dependency & API Availability Auditor
$root = Resolve-Path "$PSScriptRoot\.."

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " ULTIMATE PC TECHNICIAN TOOLKIT - DEPENDENCY AUDITOR        " -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

$dependencies = @(
    @{ Name = "dism.exe"; Type = "Executable"; RequiredBy = "WimManager, WindowsInstaller, DriverCenter"; Path = "$env:SystemRoot\System32\dism.exe" },
    @{ Name = "sfc.exe"; Type = "Executable"; RequiredBy = "WindowsRepair"; Path = "$env:SystemRoot\System32\sfc.exe" },
    @{ Name = "bcdboot.exe"; Type = "Executable"; RequiredBy = "BootRepair, WindowsInstaller"; Path = "$env:SystemRoot\System32\bcdboot.exe" },
    @{ Name = "bootsect.exe"; Type = "Executable"; RequiredBy = "BootRepair"; Path = "$env:SystemRoot\System32\bootsect.exe" },
    @{ Name = "robocopy.exe"; Type = "Executable"; RequiredBy = "BackupClone, DataRecovery"; Path = "$env:SystemRoot\System32\robocopy.exe" },
    @{ Name = "netsh.exe"; Type = "Executable"; RequiredBy = "NetworkRepair"; Path = "$env:SystemRoot\System32\netsh.exe" },
    @{ Name = "ipconfig.exe"; Type = "Executable"; RequiredBy = "NetworkRepair"; Path = "$env:SystemRoot\System32\ipconfig.exe" },
    @{ Name = "reg.exe"; Type = "Executable"; RequiredBy = "OfflineServicing"; Path = "$env:SystemRoot\System32\reg.exe" },
    @{ Name = "reagentc.exe"; Type = "Executable"; RequiredBy = "BootRepair"; Path = "$env:SystemRoot\System32\reagentc.exe" },
    @{ Name = "config.json"; Type = "Manifest"; RequiredBy = "Core Engine"; Path = "$root\Config\config.json" },
    @{ Name = "plugins.json"; Type = "Manifest"; RequiredBy = "PluginManager"; Path = "$root\Config\plugins.json" },
    @{ Name = "licenses manifest.json"; Type = "Manifest"; RequiredBy = "Licensing"; Path = "$root\ThirdPartyLicenses\manifest.json" }
)

$passed = 0
$failed = 0
$results = @()

foreach ($dep in $dependencies) {
    $exists = Test-Path $dep.Path
    $status = if ($exists) { "AVAILABLE" } else { "MISSING" }
    
    if ($exists) {
        Write-Host " [PASS] $($dep.Name) ($($dep.Type)) - $status" -ForegroundColor Green
        $passed++
    } else {
        Write-Host " [WARN] $($dep.Name) ($($dep.Type)) - $status (Required by: $($dep.RequiredBy))" -ForegroundColor Yellow
        $failed++
    }

    $results += [ordered]@{
        Dependency = $dep.Name
        Type       = $dep.Type
        RequiredBy = $dep.RequiredBy
        Location   = $dep.Path
        Status     = $status
    }
}

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " DEPENDENCY AUDIT COMPLETE: AVAILABLE: $passed | MISSING: $failed" -ForegroundColor White
Write-Host "============================================================" -ForegroundColor Cyan

return [PSCustomObject]@{
    Available = $passed
    Missing   = $failed
    Results   = $results
}
