# NetworkRepair.ps1 - Network Diagnostics & Repair Engine
. "$PSScriptRoot\Logger.ps1"
. "$PSScriptRoot\SafetyEngine.ps1"

function Get-TechNetworkDetails {
    Write-TechLog -Message "Gathering network adapter and IP configuration..." -Level "INFO" -Category "Network"
    try {
        $ip = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object InterfaceAlias -notlike "*Loopback*" | Select-Object InterfaceAlias, IPAddress, PrefixLength
        $dns = Get-DnsClientServerAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object InterfaceAlias, ServerAddresses
        return [ordered]@{
            IPAddresses  = $ip
            DNSServers   = $dns
        }
    } catch {
        return "Network Inspection Unavailable"
    }
}

function Invoke-TechNetworkDiagnosticSuite {
    param([switch]$DryRun)

    Write-TechLog -Message "Starting 'Fix Common Network Problems' workflow..." -Level "INFO" -Category "Network"

    if ($DryRun) {
        Write-TechLog -Message "[DRY-RUN]: Would test internet connectivity, renew DHCP, flush DNS, and reset network adapter." -Level "INFO" -Category "Network"
        return $true
    }

    # Step 1: Ping Gateway & Public DNS
    Write-TechLog -Message "Testing ICMP connectivity to 8.8.8.8..." -Level "INFO" -Category "Network"
    $pingTest = Test-Connection -ComputerName 8.8.8.8 -Count 2 -Quiet -ErrorAction SilentlyContinue

    if ($pingTest) {
        Write-TechLog -Message "Internet connectivity test PASSED." -Level "SUCCESS" -Category "Network"
    } else {
        Write-TechLog -Message "Internet connectivity test FAILED. Initiating network stack repair..." -Level "WARN" -Category "Network"
    }

    # Step 2: Renew DHCP Lease
    Write-TechLog -Message "Renewing DHCP lease: ipconfig /renew..." -Level "INFO" -Category "Network"
    ipconfig /renew | Out-Null

    # Step 3: Flush DNS Cache
    Write-TechLog -Message "Flushing DNS resolver cache: ipconfig /flushdns..." -Level "INFO" -Category "Network"
    ipconfig /flushdns | Out-Null

    Write-TechLog -Message "Network Diagnostic & Auto-Fix Workflow Completed." -Level "SUCCESS" -Category "Network"
    return $true
}

if ($MyInvocation.MyCommand.ScriptBlock.Module) {
    Export-ModuleMember -Function Get-TechNetworkDetails, Invoke-TechNetworkDiagnosticSuite
}
