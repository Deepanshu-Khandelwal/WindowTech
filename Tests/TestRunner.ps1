# TestRunner.ps1 - Automated Test Suite Runner for Ultimate PC Technician Toolkit
$root = Resolve-Path "$PSScriptRoot\.."
. "$root\Scripts\Logger.ps1"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " ULTIMATE PC TECHNICIAN TOOLKIT - AUTOMATED TEST SUITE      " -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

$testFiles = Get-ChildItem -Path "$root\Tests" -Recurse -Filter "*.Tests.ps1"

$passed = 0
$failed = 0
$results = @()

foreach ($tf in $testFiles) {
    Write-Host "Running Test: $($tf.Name)... " -NoNewline -ForegroundColor White
    try {
        $res = & $tf.FullName
        if ($res.Success -eq $true) {
            Write-Host "[PASS]" -ForegroundColor Green
            Write-Host "  -> $($res.Message)" -ForegroundColor Gray
            $passed++
            $results += [ordered]@{ Test = $tf.Name; Status = "PASS"; Details = $res.Message }
        } else {
            Write-Host "[FAIL]" -ForegroundColor Red
            Write-Host "  -> Error: $($res.Message)" -ForegroundColor Yellow
            $failed++
            $results += [ordered]@{ Test = $tf.Name; Status = "FAIL"; Details = $res.Message }
        }
    } catch {
        Write-Host "[ERROR]" -ForegroundColor Red
        Write-Host "  -> Exception: $_" -ForegroundColor Red
        $failed++
        $results += [ordered]@{ Test = $tf.Name; Status = "ERROR"; Details = "$_" }
    }
}

$summaryColor = if ($failed -eq 0) { "Green" } else { "Red" }
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " TEST RESULTS SUMMARY: PASSED: $passed | FAILED: $failed" -ForegroundColor $summaryColor
Write-Host "============================================================" -ForegroundColor Cyan

return [PSCustomObject]@{
    Total   = $testFiles.Count
    Passed  = $passed
    Failed  = $failed
    Results = $results
}
