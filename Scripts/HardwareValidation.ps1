# HardwareValidation.ps1 - Bare-Metal Hardware Validation & Certification Framework
# Provides machine classification, hardware inventory recording, safety gating, and hardware certification reporting.

. "$PSScriptRoot\Logger.ps1"
. "$PSScriptRoot\SafetyEngine.ps1"
. "$PSScriptRoot\SystemDetection.ps1"
. "$PSScriptRoot\DiskManager.ps1"

function New-TechHardwareValidationReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("ClassA_Disposable", "ClassB_ControlledLab", "ClassC_ProductionUser")]
        [string]$SafetyClass,

        [string]$TesterName = "Technician QA",
        [string]$TestID = "",
        [string]$TestResult = "NOT VERIFIED",
        [string]$Notes = ""
    )

    if (-not $TestID) {
        $TestID = "UT-FIELD-" + (Get-Date -Format "yyyyMMdd-HHmmss")
    }

    Write-TechLog -Message "Generating Hardware Validation Report for Test ID '$TestID' (Class: $SafetyClass)..." -Level "INFO" -Category "HardwareValidation"

    $sys = Get-TechSystemSummary
    $disks = Get-TechDisks

    $report = [ordered]@{
        TestID           = $TestID
        ValidationID     = [Guid]::NewGuid().ToString()
        Timestamp        = (Get-Date).ToString("o")
        SafetyClass      = $SafetyClass
        Tester           = $TesterName
        OverallResult    = $TestResult
        Notes            = $Notes

        ToolkitVersion   = "1.0.0"
        FirmwareMode     = $sys.FirmwareMode
        SecureBoot       = $sys.SecureBootState

        MachineInfo      = [ordered]@{
            Manufacturer = $sys.Manufacturer
            Model        = $sys.Model
            BiosVersion  = $sys.BiosVersion
            ComputerName = $sys.ComputerName
        }

        Processor        = [ordered]@{
            Name  = $sys.CpuName
            Cores = $sys.CpuCores
        }

        Memory           = [ordered]@{
            TotalRAM_GB = $sys.TotalRamGB
        }

        StorageDevices   = $disks

        OsEnvironment    = [ordered]@{
            Caption      = $sys.OsCaption
            Build        = $sys.OsBuild
            IsWinPE      = $sys.IsWinPE
        }
    }

    $fieldDir = Join-Path $PSScriptRoot "..\Diagnostics\FieldValidation\$TestID"
    if (-not (Test-Path $fieldDir)) { New-Item -ItemType Directory -Path $fieldDir -Force | Out-Null }

    $machineJson = Join-Path $fieldDir "machine.json"
    $resultJson  = Join-Path $fieldDir "result.json"

    $report | ConvertTo-Json -Depth 5 | Set-Content -Path $resultJson -Encoding UTF8
    $report.MachineInfo | ConvertTo-Json -Depth 3 | Set-Content -Path $machineJson -Encoding UTF8

    $diagDir = Join-Path $PSScriptRoot "..\Diagnostics"
    $jsonPath = Join-Path $diagDir "Hardware_Validation_Report.json"
    $report | ConvertTo-Json -Depth 5 | Set-Content -Path $jsonPath -Encoding UTF8

    Write-TechLog -Message "Saved field validation report '$TestID' to '$fieldDir'." -Level "SUCCESS" -Category "HardwareValidation"

    return New-TechResult -Success $true -Status "Completed" -Operation "GenerateHardwareValidationReport" -Message "Hardware validation report generated successfully." -Data $report
}

function Invoke-TechHardwareValidationCheck {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("ClassA_Disposable", "ClassB_ControlledLab", "ClassC_ProductionUser")]
        [string]$SafetyClass,

        [Parameter(Mandatory=$true)]
        [string]$OperationName,

        [switch]$IsDestructive
    )

    Write-TechLog -Message "Checking hardware validation safety policy for operation '$OperationName' (Class: $SafetyClass, Destructive: $IsDestructive)..." -Level "INFO" -Category "HardwareValidation"

    if ($IsDestructive -and $SafetyClass -eq "ClassC_ProductionUser") {
        $msg = "SAFETY BLOCK: Destructive operation '$OperationName' is STRICTLY FORBIDDEN on Class C (Production/User) machines!"
        Write-TechLog -Message $msg -Level "CRITICAL" -Category "HardwareValidation"
        return New-TechResult -Success $false -Status "Blocked" -Operation "HardwareValidationCheck" -Message $msg
    }

    if ($IsDestructive -and $SafetyClass -eq "ClassB_ControlledLab") {
        Write-TechLog -Message "WARNING: Executing destructive operation '$OperationName' on Class B Lab machine. Require explicit target confirmation." -Level "WARN" -Category "HardwareValidation"
    }

    return New-TechResult -Success $true -Status "Allowed" -Operation "HardwareValidationCheck" -Message "Operation '$OperationName' allowed under Safety Class '$SafetyClass'."
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function New-TechHardwareValidationReport, Invoke-TechHardwareValidationCheck
}
