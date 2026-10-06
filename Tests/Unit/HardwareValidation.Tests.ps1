# HardwareValidation.Tests.ps1 - Unit Test for Bare-Metal Hardware Validation Engine
$root = Resolve-Path "$PSScriptRoot\..\.."
. "$root\Scripts\HardwareValidation.ps1"

function Test-HardwareValidationFramework {
    # 1. Test hardware validation report generation
    $repResult = New-TechHardwareValidationReport -SafetyClass "ClassA_Disposable" -TesterName "Automated QA" -TestResult "VERIFIED" -Notes "Unit test execution."
    if (-not $repResult.Success) {
        return @{ Success = $false; Message = "Hardware validation report generation failed: $($repResult.Message)" }
    }

    # 2. Test safety policy enforcement: Class C machine blocking destructive action
    $blockResult = Invoke-TechHardwareValidationCheck -SafetyClass "ClassC_ProductionUser" -OperationName "Wipe Disk" -IsDestructive

    if ($blockResult.Success -or $blockResult.Status -ne "Blocked") {
        return @{ Success = $false; Message = "Hardware validation policy FAILED to block destructive operation on Class C Production machine!" }
    }

    # 3. Test safety policy enforcement: Class A machine allowing destructive action
    $allowResult = Invoke-TechHardwareValidationCheck -SafetyClass "ClassA_Disposable" -OperationName "Wipe Disk" -IsDestructive

    if (-not $allowResult.Success -or $allowResult.Status -ne "Allowed") {
        return @{ Success = $false; Message = "Hardware validation policy incorrectly blocked destructive operation on Class A Disposable machine!" }
    }

    return @{ Success = $true; Message = "Hardware Validation Framework & Safety Policy Enforcement tests PASSED 100%!" }
}

Test-HardwareValidationFramework
