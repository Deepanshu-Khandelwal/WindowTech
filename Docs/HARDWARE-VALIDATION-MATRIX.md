# Hardware Validation Matrix & Physical Boot Certification

This matrix tracks physical hardware compatibility testing and automated validation results for **Ultimate PC Technician Toolkit v1.0.0**.

---

## 📊 Level 1 Software & Level 2 Lab/VM Test Matrix

| Validation Test | Environment / Target | Software Result | Lab / VM Result | Physical Bare-Metal Result | Evidence / Log File |
|---|---|---|---|---|---|
| **UEFI Boot** | Hyper-V x64 Gen2 VM | **PASS** | **LAB VERIFIED** | **NOT VERIFIED** | `Logs/Technician_Audit.log` |
| **Legacy BIOS Boot** | Ventoy MBR / CSM Legacy VM | **PASS** | **LAB VERIFIED** | **NOT VERIFIED** | `Logs/Technician_Audit.log` |
| **Secure Boot** | UEFI Secure Boot Enabled VM | **PASS** | **LAB VERIFIED** | **NOT VERIFIED** | `Logs/Technician_Audit.log` |
| **NVMe SSD Storage** | Virtual NVMe Target / Query | **PASS** | **LAB VERIFIED** | **NOT VERIFIED** | `Diagnostics/PC_Health_Report.json` |
| **SATA SSD Storage** | Virtual SATA SSD Target | **PASS** | **LAB VERIFIED** | **NOT VERIFIED** | `Diagnostics/PC_Health_Report.json` |
| **SATA HDD Storage** | Virtual HDD Target | **PASS** | **LAB VERIFIED** | **NOT VERIFIED** | `Diagnostics/PC_Health_Report.json` |
| **USB 3.0 Flash Drive** | Virtual USB Drive Fixture | **PASS** | **LAB VERIFIED** | **NOT VERIFIED** | `Tests/BootMediaProtection.Tests.ps1` |
| **External NVMe SSD** | External USB Storage Fixture | **PASS** | **LAB VERIFIED** | **NOT VERIFIED** | `Tests/BootMediaProtection.Tests.ps1` |
| **Multi-Disk System** | Dual Virtual Target Disks | **PASS** | **LAB VERIFIED** | **NOT VERIFIED** | `Scripts/SystemDetection.ps1` |
| **Boot Media Protection** | Active WinPE Drive Disk 1 | **PASS** | **LAB VERIFIED** | **NOT VERIFIED** | `Tests/BootMediaProtection.Tests.ps1` |
| **Windows Installation** | Disposable Hyper-V Target Disk | **PASS** | **SIMULATION VERIFIED** | **NOT VERIFIED** | `Scripts/WindowsInstaller.ps1` |
| **Windows Repair** | SFC / DISM / Winsock Reset | **PASS** | **LAB VERIFIED** | **NOT VERIFIED** | `Scripts/WindowsRepair.ps1` |
| **Data Backup** | Robocopy /COPY:DAT Fixture | **PASS** | **LAB VERIFIED** | **NOT VERIFIED** | `Tests/BackupIntegration.Tests.ps1` |
| **Disk Cloning** | Source != Destination Fixture | **PASS** | **LAB VERIFIED** | **NOT VERIFIED** | `Tests/CloningSafety.Tests.ps1` |
| **User Data Recovery** | Profile Backup Wizard | **PASS** | **LAB VERIFIED** | **NOT VERIFIED** | `Scripts/DataRecovery.ps1` |
| **Driver Center** | DISM Export & Injection | **PASS** | **LAB VERIFIED** | **NOT VERIFIED** | `Scripts/DriverCenter.ps1` |
| **Network Repair** | IP / Ping / DNS Flush | **PASS** | **LAB VERIFIED** | **NOT VERIFIED** | `Scripts/NetworkRepair.ps1` |
| **Hardware Diagnostics** | CPU / RAM / SMART / GPU | **PASS** | **LAB VERIFIED** | **NOT VERIFIED** | `Diagnostics/Hardware_Report.json` |
| **Technician Control Center**| WPF Dark Theme UI | **PASS** | **LAB VERIFIED** | **NOT VERIFIED** | `GUI/TechnicianUI.ps1` |
| **Toolkit Self-Check** | `Get-TechSelfCheck` | **PASS** | **LAB VERIFIED** | **NOT VERIFIED** | `Tests/SelfCheck.Tests.ps1` |

---

## 🔒 Safety Classification Definitions

- **Class A (Disposable Test Machine)**: Dedicated lab hardware with no user data. Approved for destructive operations (disk wiping, WIM OS deployment, boot repair).
- **Class B (Controlled Lab Machine)**: Controlled bench PC. Approved for non-destructive diagnostics, driver exports, and offline servicing.
- **Class C (Production / User Machine)**: Client PC undergoing repair. DESTRUCTIVE OPERATIONS STRICTLY FORBIDDEN WITHOUT DATA PRESERVATION.
