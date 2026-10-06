# ModuleLoading.Tests.ps1 - Integration Test for Suite Script Loading
$root = Resolve-Path "$PSScriptRoot\..\.."

function Test-AllModulesLoad {
    $scripts = Get-ChildItem -Path "$root\Scripts" -Filter "*.ps1"
    $loadedCount = 0
    $failedScripts = @()

    foreach ($script in $scripts) {
        try {
            . $script.FullName
            $loadedCount++
        } catch {
            $failedScripts += $script.Name
        }
    }

    if ($failedScripts.Count -eq 0) {
        return @{ Success = $true; Message = "Successfully dot-sourced and validated all $loadedCount backend scripts." }
    } else {
        return @{ Success = $false; Message = "Failed scripts: $($failedScripts -join ', ')" }
    }
}

Test-AllModulesLoad
