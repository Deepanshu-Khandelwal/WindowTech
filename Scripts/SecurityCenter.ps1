# SecurityCenter.ps1 - Security, Malware Diagnostics, & Autoruns Inspection Module
. "$PSScriptRoot\Logger.ps1"
. "$PSScriptRoot\SafetyEngine.ps1"

function Get-TechDefenderStatus {
    Write-TechLog -Message "Checking Windows Defender status..." -Level "INFO" -Category "Security"
    try {
        if (Get-Command Get-MpComputerStatus -ErrorAction SilentlyContinue) {
            $mp = Get-MpComputerStatus -ErrorAction SilentlyContinue
            return [ordered]@{
                RealTimeProtectionEnabled = $mp.RealTimeProtectionEnabled
                AntivirusEnabled          = $mp.AntivirusEnabled
                AntispywareEnabled        = $mp.AntispywareEnabled
                AVSignatureVersion        = $mp.AVSignatureVersion
                QuickScanAgeDays          = $mp.QuickScanAge
            }
        } else {
            return "Windows Defender Module Not Loaded"
        }
    } catch {
        return "Defender Check Unavailable"
    }
}

function Get-TechStartupPrograms {
    Write-TechLog -Message "Inspecting startup programs (Autoruns)..." -Level "INFO" -Category "Security"
    $startups = @()

    $regPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
    )

    foreach ($path in $regPaths) {
        if (Test-Path $path) {
            $props = Get-ItemProperty -Path $path
            $props.PSObject.Properties | Where-Object Name -notlike "PS*" | ForEach-Object {
                $startups += [ordered]@{
                    Location = $path
                    Name     = $_.Name
                    Command  = $_.Value
                }
            }
        }
    }

    return $startups
}

function Inspect-TechHostsFile {
    $hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
    Write-TechLog -Message "Inspecting Windows Hosts file at '$hostsPath'..." -Level "INFO" -Category "Security"

    if (Test-Path $hostsPath) {
        $lines = Get-Content -Path $hostsPath | Where-Object { $_ -notmatch "^\s*#" -and $_ -match "\S" }
        if ($lines) {
            Write-TechLog -Message "Found $($lines.Count) custom entries in Hosts file." -Level "WARN" -Category "Security"
            return $lines
        } else {
            Write-TechLog -Message "Hosts file is clean (default comments only)." -Level "SUCCESS" -Category "Security"
            return @()
        }
    } else {
        return "Hosts file missing"
    }
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function Get-TechDefenderStatus, Get-TechStartupPrograms, Inspect-TechHostsFile
}
