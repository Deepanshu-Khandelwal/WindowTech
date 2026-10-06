# Logger.ps1 - Centralized Logging & Result Contract System for Ultimate PC Technician Toolkit
param(
    [string]$LogDir = "$PSScriptRoot\..\Logs"
)

function Get-LogTimestamp {
    return (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
}

function Get-LogDateFolder {
    return (Get-Date -Format "yyyy-MM-dd")
}

function New-TechResult {
    param(
        [Parameter(Mandatory=$true)]
        [bool]$Success,

        [string]$Status = "Completed",
        [string]$Operation = "Operation",
        [string]$Message = "",
        $Data = $null,
        $Error = $null
    )

    return [PSCustomObject]@{
        Success   = $Success
        Status    = $Status
        Operation = $Operation
        Message   = $Message
        Data      = $Data
        Error     = if ($Error) { "$Error" } else { $null }
        Timestamp = (Get-Date).ToString("o")
    }
}

function Write-TechLog {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [ValidateSet("INFO", "SUCCESS", "WARN", "ERROR", "CRITICAL", "AUDIT", "DEBUG")]
        [string]$Level = "INFO",
        
        [string]$Category = "General",
        [string]$ToolName = "CoreEngine",
        [hashtable]$Metadata = @{}
    )

    $dateFolder = Get-LogDateFolder
    $targetDir = Join-Path $LogDir $dateFolder
    if (-not (Test-Path $targetDir)) {
        try {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        } catch {
            # Fallback if log dir creation fails
        }
    }

    $logFile = Join-Path $targetDir "technician.log"
    $jsonFile = Join-Path $targetDir "technician.json"
    $timestamp = Get-LogTimestamp

    # Console Colors
    $color = switch ($Level) {
        "INFO"     { "Cyan" }
        "SUCCESS"  { "Green" }
        "WARN"     { "Yellow" }
        "ERROR"    { "Red" }
        "CRITICAL" { "Magenta" }
        "AUDIT"    { "DarkYellow" }
        "DEBUG"    { "Gray" }
        Default    { "White" }
    }

    $formattedConsole = "[$timestamp] [$Level] [$Category] $Message"
    Write-Host $formattedConsole -ForegroundColor $color

    # File Logging (Plaintext)
    try {
        Add-Content -Path $logFile -Value $formattedConsole -ErrorAction SilentlyContinue
    } catch {}

    # Structured JSON Log (Excludes sensitive keywords)
    $cleanMetadata = @{}
    foreach ($key in $Metadata.Keys) {
        if ($key -notmatch "Password|Secret|Key|Credential|Token") {
            $cleanMetadata[$key] = $Metadata[$key]
        }
    }

    $logEntry = [ordered]@{
        Timestamp = $timestamp
        Level     = $Level
        Category  = $Category
        ToolName  = $ToolName
        Message   = $Message
        Metadata  = $cleanMetadata
    }

    try {
        $jsonLine = $logEntry | ConvertTo-Json -Compress
        Add-Content -Path $jsonFile -Value $jsonLine -ErrorAction SilentlyContinue
    } catch {}
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function Write-TechLog, Get-LogTimestamp, Get-LogDateFolder, New-TechResult
}
