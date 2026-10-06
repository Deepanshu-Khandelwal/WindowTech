# TechnicianUI.ps1 - Ultimate PC Technician Toolkit Main Control Center GUI
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Xaml -ErrorAction SilentlyContinue

. "$PSScriptRoot\..\Scripts\Logger.ps1"
. "$PSScriptRoot\..\Scripts\SystemDetection.ps1"
. "$PSScriptRoot\..\Scripts\HealthCheck.ps1"
. "$PSScriptRoot\..\Scripts\WindowsRepair.ps1"
. "$PSScriptRoot\..\Scripts\DiskManager.ps1"
. "$PSScriptRoot\..\Scripts\WimManager.ps1"
. "$PSScriptRoot\..\Scripts\WindowsInstaller.ps1"
. "$PSScriptRoot\..\Scripts\BootRepair.ps1"
. "$PSScriptRoot\..\Scripts\OfflineServicing.ps1"
. "$PSScriptRoot\..\Scripts\PluginManager.ps1"
. "$PSScriptRoot\..\Scripts\BackupClone.ps1"
. "$PSScriptRoot\..\Scripts\DataRecovery.ps1"
. "$PSScriptRoot\..\Scripts\DriverCenter.ps1"
. "$PSScriptRoot\..\Scripts\HardwareDiagnostics.ps1"
. "$PSScriptRoot\..\Scripts\NetworkRepair.ps1"
. "$PSScriptRoot\..\Scripts\SecurityCenter.ps1"
. "$PSScriptRoot\..\Scripts\Maintenance.ps1"
. "$PSScriptRoot\..\Scripts\PortableAppManager.ps1"
. "$PSScriptRoot\..\Scripts\MultiBootManager.ps1"
. "$PSScriptRoot\..\Scripts\BrandingManager.ps1"

Write-TechLog -Message "Initializing Ultimate Technician Control Center GUI (All Phases Enabled)..." -Level "INFO" -Category "GUI"

$sysInfo = Get-TechSystemSummary

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Ultimate PC Technician Toolkit v1.0.0" Height="840" Width="1240"
        WindowStartupLocation="CenterScreen" Background="#1E1E1E" Foreground="#FFFFFF">
    <Window.Resources>
        <Style TargetType="Button">
            <Setter Property="Background" Value="#2D2D30"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Margin" Value="3"/>
            <Setter Property="Padding" Value="8,5,8,5"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="BorderBrush" Value="#3F3F46"/>
        </Style>
    </Window.Resources>

    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- HEADER BANNER -->
        <Border Grid.Row="0" Background="#0078D4" Padding="15,8,15,8">
            <DockPanel>
                <TextBlock Text="ULTIMATE PC TECHNICIAN TOOLKIT" FontSize="18" FontWeight="Bold" Foreground="#FFFFFF" VerticalAlignment="Center"/>
                <TextBlock Text="Windows Repair • Recovery • Deployment • Diagnostics" FontSize="11" Foreground="#D0E7FF" VerticalAlignment="Center" Margin="15,2,0,0"/>
                <CheckBox Name="chkDryRun" Content="Enable Dry-Run (Safe Preview Mode)" Foreground="#FFFFFF" FontWeight="SemiBold" HorizontalAlignment="Right" VerticalAlignment="Center"/>
            </DockPanel>
        </Border>

        <!-- SYSTEM METRICS SUMMARY BAR -->
        <Border Grid.Row="1" Background="#252526" BorderBrush="#3F3F46" BorderThickness="0,0,0,1" Padding="10">
            <Grid Name="gridMetrics">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>
                <StackPanel Grid.Column="0">
                    <TextBlock Text="OS / MODE:" Foreground="#AAAAAA" FontSize="10" FontWeight="Bold"/>
                    <TextBlock Name="txtOSMode" Text="Loading..." Foreground="#00FFC8" FontSize="12" FontWeight="SemiBold"/>
                </StackPanel>
                <StackPanel Grid.Column="1">
                    <TextBlock Text="PROCESSOR / RAM:" Foreground="#AAAAAA" FontSize="10" FontWeight="Bold"/>
                    <TextBlock Name="txtCpuRam" Text="Loading..." Foreground="#FFFFFF" FontSize="12"/>
                </StackPanel>
                <StackPanel Grid.Column="2">
                    <TextBlock Text="BOOT / SECURE BOOT:" Foreground="#AAAAAA" FontSize="10" FontWeight="Bold"/>
                    <TextBlock Name="txtBootMode" Text="Loading..." Foreground="#FFFFFF" FontSize="12"/>
                </StackPanel>
                <StackPanel Grid.Column="3">
                    <TextBlock Text="STORAGE DISKS:" Foreground="#AAAAAA" FontSize="10" FontWeight="Bold"/>
                    <TextBlock Name="txtStorage" Text="Loading..." Foreground="#FFFFFF" FontSize="12"/>
                </StackPanel>
            </Grid>
        </Border>

        <!-- MAIN CONTENT AREA -->
        <Grid Grid.Row="2" Margin="10">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="220"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>

            <!-- LEFT CATEGORY NAVIGATION -->
            <ScrollViewer Grid.Column="0" VerticalScrollBarVisibility="Auto">
                <StackPanel Margin="0,0,10,0">
                    <Button Name="btnFullHealthCheck" Content="⚡ FULL PC HEALTH CHECK" Background="#008A00" FontWeight="Bold" Height="36" Margin="0,0,0,8"/>
                    <TextBlock Text="MODULE CATEGORIES" Foreground="#888888" FontSize="10" FontWeight="Bold" Margin="4,4,0,4"/>
                    <Button Name="btnNavInstall" Content="Windows Install"/>
                    <Button Name="btnNavRepair" Content="Windows Repair"/>
                    <Button Name="btnNavDisk" Content="Disk &amp; Partition"/>
                    <Button Name="btnNavBackup" Content="Backup &amp; Clone"/>
                    <Button Name="btnNavRecovery" Content="Data Recovery"/>
                    <Button Name="btnNavHardware" Content="Hardware Diagnostics"/>
                    <Button Name="btnNavDrivers" Content="Drivers"/>
                    <Button Name="btnNavNetwork" Content="Network Repair"/>
                    <Button Name="btnNavSecurity" Content="Security &amp; Malware"/>
                    <Button Name="btnNavMaintenance" Content="Windows Maintenance"/>
                    <Button Name="btnNavPortable" Content="Portable Tools"/>
                    <Button Name="btnNavTerminal" Content="Terminal / Scripts"/>
                    <Button Name="btnNavReports" Content="Reports &amp; Logs"/>
                    <Button Name="btnNavSettings" Content="Settings"/>
                </StackPanel>
            </ScrollViewer>

            <!-- RIGHT TOOL EXECUTION & LOG VIEW -->
            <Grid Grid.Column="1">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="180"/>
                </Grid.RowDefinitions>

                <!-- TOOL TITLE & DESCRIPTION -->
                <Border Grid.Row="0" Background="#2D2D30" Padding="10" Margin="0,0,0,8">
                    <StackPanel>
                        <DockPanel>
                            <TextBlock Name="txtToolTitle" Text="Technician Dashboard" FontSize="15" FontWeight="Bold" Foreground="#0078D4"/>
                            <Border Name="brdRiskBadge" Background="#008A00" CornerRadius="3" Padding="6,2,6,2" HorizontalAlignment="Right">
                                <TextBlock Name="txtRiskBadge" Text="RISK: LOW" FontSize="10" FontWeight="Bold" Foreground="#FFFFFF"/>
                            </Border>
                        </DockPanel>
                        <TextBlock Name="txtToolDesc" Text="Select a module category from the left panel to execute diagnostic, repair, and deployment workflows." FontSize="11" Foreground="#CCCCCC" TextWrapping="Wrap" Margin="0,4,0,0"/>
                    </StackPanel>
                </Border>

                <!-- ACTIVE TOOL CONTROLS PANEL -->
                <Border Grid.Row="1" Background="#252526" Padding="10" Margin="0,0,0,8">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel Name="panelToolActions">
                            <!-- Category Dynamic Action Toolbar -->
                            <WrapPanel Name="wrapActionButtons" Margin="0,0,0,10">
                                <Button Name="btnRunSFC" Content="Run SFC System Scan" Width="180" Height="30"/>
                                <Button Name="btnRunDISM" Content="DISM RestoreHealth" Width="180" Height="30"/>
                                <Button Name="btnResetWU" Content="Reset WinUpdate Cache" Width="180" Height="30"/>
                                <Button Name="btnResetNet" Content="Reset Network Stack" Width="180" Height="30"/>
                                <Button Name="btnScanOffline" Content="Scan Offline Windows" Width="180" Height="30"/>
                                <Button Name="btnRebuildBCD" Content="Rebuild BCD Bootloader" Width="180" Height="30"/>
                            </WrapPanel>
                            <Separator Background="#3F3F46" Margin="0,4,0,8"/>
                            <TextBlock Name="lblDetailsHeader" Text="System &amp; Action Output Details:" FontWeight="Bold" Foreground="#0078D4"/>
                            <TextBox Name="txtSysDetails" Height="170" Background="#1E1E1E" Foreground="#00FFC8" IsReadOnly="True" VerticalScrollBarVisibility="Auto" FontFamily="Consolas" FontSize="11"/>
                        </StackPanel>
                    </ScrollViewer>
                </Border>

                <!-- CONSOLE LOG OUTPUT -->
                <Border Grid.Row="2" Background="#1E1E1E" BorderBrush="#3F3F46" BorderThickness="1">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="*"/>
                        </Grid.RowDefinitions>
                        <DockPanel Grid.Row="0" Background="#2D2D30" Padding="6,3,6,3">
                            <TextBlock Text="REAL-TIME EXECUTION AUDIT LOG" FontSize="10" FontWeight="Bold" Foreground="#AAAAAA"/>
                            <Button Name="btnClearLog" Content="Clear Log" HorizontalAlignment="Right" FontSize="9" Padding="4,1,4,1"/>
                        </DockPanel>
                        <TextBox Name="txtLogConsole" Grid.Row="1" Background="#000000" Foreground="#00FF00" IsReadOnly="True" VerticalScrollBarVisibility="Auto" FontFamily="Consolas" FontSize="10" TextWrapping="Wrap"/>
                    </Grid>
                </Border>
            </Grid>
        </Grid>

        <!-- FOOTER STATUS BAR -->
        <Border Grid.Row="3" Background="#0078D4" Padding="10,3,10,3">
            <DockPanel>
                <TextBlock Name="txtFooterStatus" Text="Ready." FontSize="10" Foreground="#FFFFFF"/>
                <TextBlock Text="Apex PC Tech Solutions • License: Open Source (MIT)" FontSize="10" Foreground="#FFFFFF" HorizontalAlignment="Right"/>
            </DockPanel>
        </Border>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Element References
$txtOSMode       = $window.FindName("txtOSMode")
$txtCpuRam       = $window.FindName("txtCpuRam")
$txtBootMode     = $window.FindName("txtBootMode")
$txtStorage      = $window.FindName("txtStorage")
$chkDryRun       = $window.FindName("chkDryRun")
$txtToolTitle    = $window.FindName("txtToolTitle")
$txtToolDesc     = $window.FindName("txtToolDesc")
$txtRiskBadge    = $window.FindName("txtRiskBadge")
$brdRiskBadge    = $window.FindName("brdRiskBadge")
$txtSysDetails   = $window.FindName("txtSysDetails")
$txtLogConsole   = $window.FindName("txtLogConsole")
$txtFooterStatus = $window.FindName("txtFooterStatus")

# Set Initial Metrics
$txtOSMode.Text   = "$($sysInfo.OSName) ($($sysInfo.EnvironmentMode))"
$txtCpuRam.Text   = "$($sysInfo.CPUModel) | $($sysInfo.TotalRAMGB) GB RAM"
$txtBootMode.Text = "Boot: $($sysInfo.BootMode) | SecureBoot: $($sysInfo.SecureBoot)"
$diskCount = if ($sysInfo.Disks) { ($sysInfo.Disks | Measure-Object).Count } else { 0 }
$txtStorage.Text  = "$diskCount Storage Drive(s) Detected"
$txtSysDetails.Text = $sysInfo | ConvertTo-Json -Depth 3

function Append-GuiLog([string]$msg) {
    $time = Get-Date -Format "HH:mm:ss"
    $txtLogConsole.AppendText("[$time] $msg`r`n")
    $txtLogConsole.ScrollToEnd()
}

function Set-CategoryHeader([string]$title, [string]$desc, [string]$riskLevel, [string]$badgeColor) {
    $txtToolTitle.Text = $title
    $txtToolDesc.Text  = $desc
    $txtRiskBadge.Text = "RISK: $riskLevel"
    $brdRiskBadge.Background = (New-Object System.Windows.Media.BrushConverter).ConvertFromString($badgeColor)
}

# Attach Action Events
$window.FindName("btnFullHealthCheck").Add_Click({
    Append-GuiLog "Starting Automated 10-Point PC Health Check..."
    $txtFooterStatus.Text = "Running Health Check..."
    $report = Start-TechAutomatedHealthCheck
    Append-GuiLog "PC Health Check Completed! Status: $($report.OverallStatus) | Score: $($report.HealthScore)/100"
    $txtSysDetails.Text = $report | ConvertTo-Json -Depth 4
    $txtFooterStatus.Text = "Health Check Complete (Status: $($report.OverallStatus))."
})

$window.FindName("btnRunSFC").Add_Click({
    $dry = $chkDryRun.IsChecked
    Append-GuiLog "Executing SFC System Scan (DryRun: $dry)..."
    Invoke-TechSFC -DryRun:$dry
})

$window.FindName("btnRunDISM").Add_Click({
    $dry = $chkDryRun.IsChecked
    Append-GuiLog "Executing DISM RestoreHealth (DryRun: $dry)..."
    Invoke-TechDISMRepair -Action "RestoreHealth" -DryRun:$dry
})

$window.FindName("btnResetWU").Add_Click({
    $dry = $chkDryRun.IsChecked
    Append-GuiLog "Resetting Windows Update Cache (DryRun: $dry)..."
    Reset-TechWindowsUpdateCache -DryRun:$dry
})

$window.FindName("btnResetNet").Add_Click({
    $dry = $chkDryRun.IsChecked
    Append-GuiLog "Resetting Network Stack (DryRun: $dry)..."
    Invoke-TechNetworkReset -DryRun:$dry
})

$window.FindName("btnScanOffline").Add_Click({
    Append-GuiLog "Scanning for offline Windows OS installations..."
    $offlines = Find-TechOfflineWindowsInstallations
    $txtSysDetails.Text = $offlines | ConvertTo-Json -Depth 3
})

$window.FindName("btnRebuildBCD").Add_Click({
    Append-GuiLog "Inspecting BCD boot configuration..."
    $bcd = Get-TechBcdEntries
    $txtSysDetails.Text = $bcd
})

# Navigation Click Handlers
$window.FindName("btnNavInstall").Add_Click({
    Set-CategoryHeader "Windows Installation Center" "Automated GPT/UEFI & MBR/Legacy Windows 10/11 deployment engine from ISO/WIM/ESD." "DESTRUCTIVE" "#E74C3C"
    $txtSysDetails.Text = "Select a WIM/ESD image and target disk to deploy Windows OS.`r`nTemplates available: unattend_win10.xml, unattend_win11.xml (TPM/RAM bypass)."
})

$window.FindName("btnNavRepair").Add_Click({
    Set-CategoryHeader "Windows Repair Center" "Online and Offline Windows SFC, DISM, BCD, Winsock, and Component Store Repair." "MEDIUM" "#F39C12"
})

$window.FindName("btnNavDisk").Add_Click({
    Set-CategoryHeader "Disk & Partition Center" "Partition manager, SMART diagnostics, drive formatting, and partition table tools." "HIGH" "#E67E22"
    $disks = Get-TechDisks
    $txtSysDetails.Text = $disks | ConvertTo-Json -Depth 3
})

$window.FindName("btnNavBackup").Add_Click({
    Set-CategoryHeader "Backup & Clone Center" "File backup, WIM system image capture, and disk-to-disk cloning safety validator." "HIGH" "#E67E22"
})

$window.FindName("btnNavRecovery").Add_Click({
    Set-CategoryHeader "Data Recovery Center" "User profile data backup wizard and file carving helpers." "LOW" "#2ECC71"
})

$window.FindName("btnNavHardware").Add_Click({
    Set-CategoryHeader "Hardware Diagnostics Center" "Comprehensive hardware detection for CPU, RAM, GPU, Disks, Battery, Motherboard, and Network." "LOW" "#2ECC71"
    $txtSysDetails.Text = $sysInfo | ConvertTo-Json -Depth 4
})

$window.FindName("btnNavDrivers").Add_Click({
    Set-CategoryHeader "Driver Management Center" "Export system drivers, scan problematic devices, and inject offline drivers into Windows WIM." "MEDIUM" "#F39C12"
    $drivers = Get-TechProblematicDrivers
    $txtSysDetails.Text = $drivers | ConvertTo-Json -Depth 3
})

$window.FindName("btnNavNetwork").Add_Click({
    Set-CategoryHeader "Network Repair Center" "IP configuration inspector, Winsock catalog reset, TCP/IP stack reset, and DNS cache flush." "LOW" "#2ECC71"
    $net = Get-TechNetworkDetails
    $txtSysDetails.Text = $net | ConvertTo-Json -Depth 3
})

$window.FindName("btnNavSecurity").Add_Click({
    Set-CategoryHeader "Security & Malware Center" "Windows Defender status, autoruns startup inspection, and hosts file analyzer." "LOW" "#2ECC71"
    $def = Get-TechDefenderStatus
    $txtSysDetails.Text = $def | ConvertTo-Json -Depth 3
})

$window.FindName("btnNavMaintenance").Add_Click({
    Set-CategoryHeader "Windows Maintenance Center" "Temporary file cleanup, Windows Update cleanup, and services manager." "MEDIUM" "#F39C12"
})

$window.FindName("btnNavPortable").Add_Click({
    Set-CategoryHeader "Portable Tools Center" "Repositories of portable technician tools (smartctl, testdisk, custom utilities)." "LOW" "#2ECC71"
    $apps = Get-TechPortableApps
    $txtSysDetails.Text = $apps | ConvertTo-Json -Depth 3
})

$window.FindName("btnClearLog").Add_Click({
    $txtLogConsole.Clear()
})

Append-GuiLog "Ultimate Technician Control Center GUI ready."
$window.ShowDialog() | Out-Null
