# Ultimate PC Technician Toolkit

> **Version 1.0.0 (Stable Release)**  
> **Professional, Open-Source Windows Repair, Recovery, Deployment, & Hardware Diagnostics Environment**

---

## 📌 Project Overview

The **Ultimate PC Technician Toolkit** is an open-source, legally compliant, professional Windows technician operating environment. Designed for system engineers, IT administrators, and PC repair technicians, it consolidates diagnosis, repair, data recovery, offline OS servicing, disk management, and Windows deployment into a unified bootable environment for USB flash drives and external SSDs.

---

## 🛠️ Key Features & Phase 8 Enhancements

- **Automated 10-Point PC Health Check**: One-button full diagnostic scanning CPU, RAM, storage SMART health, bootloader BCD, SFC/DISM component store, event log errors, and network status with GREEN/YELLOW/RED health rating and recommended actions.
- **Active Boot Media Safeguard**: Safety Engine automatically identifies the active technician boot drive and prevents accidental self-formatting, partition deletion, or drive wiping.
- **Strict Disk Cloning Validation**: Prevents identical source/destination selection and protects active boot media from being overwritten during disk cloning.
- **Offline Windows Servicing**: Automatically detects offline Windows installations (`C:\Windows`, `D:\Windows`, etc.) and performs offline SFC, offline DISM, driver injection, and offline registry repair.
- **Data Preservation First Workflow**: Safeguards user data before performing destructive operations. Safe user profile data backup wizards (`Desktop`, `Documents`, `Downloads`, `Pictures`, `Videos`, Browser profiles).
- **100% Legally Compliant & Open Source**: Zero pirated software, cracked utilities, or warez. Incorporates open-source utilities (Ventoy, smartctl, TestDisk) while respecting all third-party software licenses. Includes inventory catalog under `ThirdPartyLicenses/manifest.json`.
- **Ventoy Multi-Boot Architecture**: Direct UEFI & Legacy BIOS boot support for Windows 10/11 ISOs, WinPE WIMs, MemTest86+, and Linux rescue environments from a single external drive.

---

## 📂 Core Architecture Layout

```
/UltimateTechnician
├── Boot/                    <- Ventoy configuration & bootloader assets
├── WinPE/                   <- WinPE ADK build system & custom workspace
│   └── build.ps1            <- Automated WinPE ISO build script
├── WindowsInstall/          <- Unattended setup answer files & ISO tools
├── Drivers/                 <- Offline/Online driver injection repository
├── Tools/                   <- Open-source portable tools (smartctl, testdisk)
├── PortableApps/            <- Categorized portable application store
├── Scripts/                 <- Modular PowerShell backend engines (22 Modules)
│   ├── Logger.ps1           <- Structured JSON & console logger
│   ├── SafetyEngine.ps1     <- Safeguards, Dry-Run, & Boot Media Protection
│   ├── SystemDetection.ps1  <- Hardware, firmware & OS detection
│   ├── HealthCheck.ps1      <- Automated 10-Point Health Check engine
│   ├── WindowsRepair.ps1    <- SFC, DISM, BCD, & Network repair
│   ├── DiskManager.ps1      <- Safe DiskPart & partition manager
│   ├── OfflineServicing.ps1 <- Offline Windows scanner & servicing
│   ├── PluginManager.ps1    <- Extensible plugin discovery & launcher
│   ├── WimManager.ps1       <- WIM/ESD/ISO image manager
│   ├── BootRepair.ps1       <- EFI System Partition & MBR boot repair
│   ├── WindowsInstaller.ps1 <- Automated GPT/UEFI & MBR deployment
│   ├── BackupClone.ps1      <- File backup, system image capture & cloning
│   ├── DataRecovery.ps1     <- User profile data backup wizard
│   ├── DriverCenter.ps1     <- Driver export & offline injection
│   ├── HardwareDiagnostics.ps1 <- Hardware report generator
│   ├── NetworkRepair.ps1    <- IP inspector & network stack reset
│   ├── SecurityCenter.ps1   <- Defender status & autoruns analyzer
│   ├── Maintenance.ps1      <- Temp cleanup & services manager
│   ├── PortableAppManager.ps1 <- Portable app scanner & launcher
│   ├── MultiBootManager.ps1 <- Ventoy ISO repository manager
│   ├── BrandingManager.ps1  <- Technician branding config engine
│   └── Create-TechnicianUSB.ps1 <- USB / External SSD deployment wizard
├── Tests/                   <- Automated Unit, Safety, & Integration Test Suite
│   ├── Unit/
│   ├── Safety/
│   ├── Integration/
│   ├── WinPE/
│   └── TestRunner.ps1       <- Automated test suite runner
├── ThirdPartyLicenses/      <- Inventory catalog & open-source license files
│   ├── manifest.json
│   ├── MIT-LICENSE.txt
│   ├── Ventoy-GPL3.txt
│   ├── smartmontools-GPL2.txt
│   ├── TestDisk-GPL2.txt
│   └── MemTest86plus-GPL2.txt
├── Backup/                  <- User backup storage directory
├── Diagnostics/             <- Diagnostics report outputs
├── Logs/                    <- Dated log logs (YYYY-MM-DD)
├── Config/                  <- System configuration & plugin registry
├── GUI/                     <- Modern Technician Control Center Application
└── Docs/                    <- Complete project documentation
```

---

## 🚀 Quick Start & Verification

1. **Run Test Suite**: Open PowerShell as Administrator and execute:
   ```powershell
   .\Tests\TestRunner.ps1
   ```
2. **Build WinPE ISO**: Run `WinPE\build.ps1` (Requires Microsoft ADK & WinPE Add-on).
3. **Deploy to USB/SSD**: Run `Scripts\Create-TechnicianUSB.ps1` to partition and install the toolkit to your USB drive or external SSD.
4. **Boot Target System**: Insert USB into target PC, select UEFI/BIOS boot menu, and select **Ultimate PC Technician Toolkit**.

---

## 📜 License

Licensed under the [MIT License](../ThirdPartyLicenses/MIT-LICENSE.txt). Third-party open-source components are subject to their respective licenses (GPL-2.0, GPL-3.0) as cataloged in [`ThirdPartyLicenses/manifest.json`](../ThirdPartyLicenses/manifest.json).
