# TechnicianSession.ps1 - Technician Session & Customer Notes Manager
. "$PSScriptRoot\Logger.ps1"
. "$PSScriptRoot\SystemDetection.ps1"

function New-TechSession {
    param(
        [string]$TechnicianName = "Lead Technician",
        [string]$CustomerName = "Valued Customer"
    )

    $sys = Get-TechSystemSummary

    $session = [PSCustomObject]@{
        SessionId           = "SESSION-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        StartTime           = (Get-Date).ToString("o")
        ToolkitVersion      = "0.9.0-rc.1"
        TechnicianName      = $TechnicianName
        CustomerName        = $CustomerName
        DetectedMachine     = [ordered]@{
            OSName      = $sys.OSName
            CPU         = $sys.CPUModel
            RAM         = "$($sys.TotalRAMGB) GB"
            BootMode    = $sys.BootMode
            SecureBoot  = $sys.SecureBoot
        }
        BackupStatus        = "[ ] Backup recommended"
        TechnicianNotes     = [ordered]@{
            CustomerReports  = ""
            InitialCondition = ""
            ActionsPerformed = ""
            PartsReplaced    = ""
            FinalCondition   = ""
        }
        OperationsPerformed = @()
        Warnings            = @()
        Errors              = @()
        FinalStatus         = "In Progress"
    }

    Write-TechLog -Message "Initialized Technician Session '$($session.SessionId)' for $($session.CustomerName)." -Level "INFO" -Category "Session"
    return $session
}

function Export-TechSessionReport {
    param(
        [Parameter(Mandatory=$true)]
        $Session,
        [string]$OutputPath = "$PSScriptRoot\..\Diagnostics\Technician_Session_Report.json"
    )

    Write-TechLog -Message "Exporting Technician Session Report for $($Session.SessionId)..." -Level "INFO" -Category "Session"

    try {
        $outDir = Split-Path -Parent $OutputPath
        if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

        $Session | ConvertTo-Json -Depth 5 | Set-Content -Path $OutputPath -Encoding UTF8

        # Plain Text Summary
        $txtPath = [System.IO.Path]::ChangeExtension($OutputPath, ".txt")
        $txtContent = @"
============================================================
 ULTIMATE PC TECHNICIAN TOOLKIT - SESSION REPORT
============================================================
Session ID:       $($Session.SessionId)
Toolkit Version:  $($Session.ToolkitVersion)
Start Time:       $($Session.StartTime)
Technician:       $($Session.TechnicianName)
Customer:         $($Session.CustomerName)
Backup Status:    $($Session.BackupStatus)
Final Status:     $($Session.FinalStatus)
------------------------------------------------------------
SYSTEM HARDWARE & OS PROFILE
OS Name:          $($Session.DetectedMachine.OSName)
CPU:              $($Session.DetectedMachine.CPU)
RAM:              $($Session.DetectedMachine.RAM)
Boot Mode:        $($Session.DetectedMachine.BootMode)
Secure Boot:      $($Session.DetectedMachine.SecureBoot)
------------------------------------------------------------
TECHNICIAN NOTES
Customer Reports:  $($Session.TechnicianNotes.CustomerReports)
Initial Condition: $($Session.TechnicianNotes.InitialCondition)
Actions Performed: $($Session.TechnicianNotes.ActionsPerformed)
Parts Replaced:    $($Session.TechnicianNotes.PartsReplaced)
Final Condition:   $($Session.TechnicianNotes.FinalCondition)
============================================================
"@
        Set-Content -Path $txtPath -Value $txtContent -Encoding UTF8

        Write-TechLog -Message "Session report saved to '$OutputPath' and '$txtPath'." -Level "SUCCESS" -Category "Session"
        return New-TechResult -Success $true -Status "Completed" -Operation "ExportSession" -Message "Session report generated." -Data @{ JsonPath = $OutputPath; TxtPath = $txtPath }
    } catch {
        Write-TechLog -Message "Failed to export session report: $_" -Level "ERROR" -Category "Session"
        return New-TechResult -Success $false -Status "Failed" -Operation "ExportSession" -Message "Failed to export session report." -Error $_
    }
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function New-TechSession, Export-TechSessionReport
}
