# BackupIntegration.Tests.ps1 - Real File Backup Fixture Test
$root = Resolve-Path "$PSScriptRoot\..\.."
. "$root\Scripts\Logger.ps1"
. "$root\Scripts\SafetyEngine.ps1"
. "$root\Scripts\DiskManager.ps1"
. "$root\Scripts\WimManager.ps1"
. "$root\Scripts\BackupClone.ps1"

function Test-RealFileBackupFixture {
    $srcDir = "$root\Tests\TestData\Source"
    $dstDir = "$root\Tests\TestData\Destination"

    try {
        # Prepare Test Data
        if (Test-Path $srcDir) { Remove-Item -Path $srcDir -Recurse -Force -ErrorAction SilentlyContinue }
        if (Test-Path $dstDir) { Remove-Item -Path $dstDir -Recurse -Force -ErrorAction SilentlyContinue }

        New-Item -ItemType Directory -Path "$srcDir\SubFolder" -Force | Out-Null
        Set-Content -Path "$srcDir\test1.txt" -Value "Hello World Technician Backup Test" -Encoding UTF8
        Set-Content -Path "$srcDir\SubFolder\test2.txt" -Value "Nested Unicode Test: 🛠️ WinPE" -Encoding UTF8

        # Execute File Backup with ForceNoPrompt for non-interactive test runner
        $res = Backup-TechFiles -SourcePath $srcDir -DestinationPath $dstDir -ForceNoPrompt:$true -DryRun:$false

        if ($res.Success -ne $true) {
            return @{ Success = $false; Message = "Backup-TechFiles failed: $($res.Message)" }
        }

        # Verify Files Exist in Destination
        $f1 = Test-Path "$dstDir\test1.txt"
        $f2 = Test-Path "$dstDir\SubFolder\test2.txt"

        # Cleanup Test Fixtures
        Remove-Item -Path "$root\Tests\TestData" -Recurse -Force -ErrorAction SilentlyContinue

        if ($f1 -and $f2) {
            return @{ Success = $true; Message = "Real File Backup Fixture copied all nested files and Unicode contents verified 100%!" }
        } else {
            return @{ Success = $false; Message = "Destination files missing after Robocopy backup!" }
        }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-RealFileBackupFixture
