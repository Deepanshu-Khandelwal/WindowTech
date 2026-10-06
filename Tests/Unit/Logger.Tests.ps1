# Logger.Tests.ps1 - Unit Tests for Logging Engine & Result Contract
$root = Resolve-Path "$PSScriptRoot\..\.."
. "$root\Scripts\Logger.ps1"

function Test-LoggerEngine {
    try {
        Write-TechLog -Message "Unit Test Log Message" -Level "DEBUG" -Category "Testing"
        $res = New-TechResult -Success $true -Status "Testing" -Operation "UnitTest" -Message "Success message"
        
        if ($res.Success -ne $true -or $res.Operation -ne "UnitTest") {
            return @{ Success = $false; Message = "New-TechResult contract invalid" }
        }

        return @{ Success = $true; Message = "Logger & Result Contract validated" }
    } catch {
        return @{ Success = $false; Message = $_.Exception.Message }
    }
}

Test-LoggerEngine
