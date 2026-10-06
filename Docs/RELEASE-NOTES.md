# Ultimate PC Technician — Release Notes

**Version**: `1.0.0`  
**Release Stage**: Stable Release  
**Release Date**: 2026-10-06  
**License**: MIT License ([`ThirdPartyLicenses/MIT-LICENSE.txt`](../ThirdPartyLicenses/MIT-LICENSE.txt))  

---

## 🌟 Release Overview

**Ultimate PC Technician v1.0.0** is the official Stable Release for the open-source bootable technician operating environment. This milestone release provides a fully verified, legally compliant, zero-telemetry technician workflow for diagnosis, repair, data backup, offline Windows servicing, driver injection, hardware diagnostics, and technician reporting.

---

## 🚀 Key Features & Capabilities

1. **Automated 10-Point PC Health Check**: One-button diagnostic evaluation of CPU, RAM, storage SMART status, C: drive space, BCD bootloader, DISM component store, event logs, and network adapters with green/yellow/red health indicators.
2. **Boot Media Safeguard Engine**: Advanced physical disk identification preventing accidental format, wipe, or partition deletion on the active WinPE / technician USB boot drive (`Get-TechBootMediaDiskNumber`).
3. **Target-Specific Destructive Confirmation**: High-risk operations require typing target-specific confirmation keywords (e.g. `CONFIRM <Model>`).
4. **Offline Windows OS Servicing**: Volume scanner identifying offline Windows installations (`C:\Windows`, `D:\Windows`) for offline SFC, offline DISM, driver injection, and registry maintenance.
5. **Data Preservation & Recovery**: Non-destructive user profile backup wizard preserving `Desktop`, `Documents`, `Downloads`, `Pictures`, `Videos`, and browser profiles to external target storage.
6. **WPF Technician Control Center GUI**: High-performance WPF interface featuring real-time hardware status metrics, 14 technician operation tabs, dry-run safety toggle, and real-time audit logging console.
7. **Complete Compliance & Legal Safety**: 100% open-source software, zero credential extraction, zero BitLocker bypass, zero activation cracks, and full license attributions under `ThirdPartyLicenses/`.

---

## 🛠️ System Requirements

- **Host OS**: Windows 10 or Windows 11 (x64)
- **PowerShell**: PowerShell 5.1 or 7.x (Built-in)
- **WinPE Building**: Microsoft Windows ADK & WinPE Add-on (for ISO generation)
- **Storage Target**: USB 3.0 Flash Drive (16 GB+) or External NVMe/SATA SSD

---

## ⚠️ Known Limitations

1. **Physical Machine Boot Verification**: Hardware-specific UEFI/Legacy boot testing on physical PCs must be verified in technician environment prior to production field deployment.
2. **BitLocker Drive Unlocking**: BitLocker partition access requires providing an explicit technician recovery key (password defeat/cracking features are explicitly omitted by design).
3. **RAID / Custom Storage Controllers**: Storage drives behind non-standard RAID controllers require injecting OEM storage drivers into WinPE via DISM (`DriverCenter.ps1`).

---

## 📜 Third-Party Licenses & Attributions

The core toolkit code is licensed under the **MIT License**. Third-party components bundled or referenced:
- **Ventoy**: GNU General Public License v3 (GPL-3.0)
- **smartmontools (smartctl)**: GNU General Public License v2 (GPL-2.0)
- **TestDisk & PhotoRec**: GNU General Public License v2+ (GPL-2.0-or-later)
- **MemTest86+**: GNU General Public License v2 (GPL-2.0)

Full license texts and attribution manifest are located in [`ThirdPartyLicenses/`](../ThirdPartyLicenses/).
