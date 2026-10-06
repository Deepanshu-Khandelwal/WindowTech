# SelfCheck.Tests.ps1 - Unit Test for Toolkit Self-Check Engine
$root = Resolve-Path "$PSScriptRoot\..\.."
. "$root\Scripts\SelfCheck.ps1"

function Test-SelfCheckEngine {
    $result = Get-TechSelfCheck

    if ($result.Success -and ($result.Status -eq "READY" -or $result.Status -eq "WARNING")) {
        return @{ Success = $true; Message = "Toolkit Self-Check executed successfully with status '$($result.Status)'." }
    } else {
        return @{ Success = $false; Message = "Toolkit Self-Check failed or returned status '$($result.Status)'." }
    }
}

Test-SelfCheckEngine
