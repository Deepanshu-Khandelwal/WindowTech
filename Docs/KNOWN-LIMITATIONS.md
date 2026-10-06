# Known Technical Limitations

This document lists the real, verified technical limitations of the **Ultimate PC Technician Toolkit v1.0.0 (Stable Release)**.

---

## 📋 Technical Limitations Inventory

### 1. Microsoft ADK Host Build Prerequisite
- **Feature**: WinPE Image Compilation (`WinPE/build.ps1`)
- **Current Status**: `REQUIRES HOST ADK`
- **Reason**: WinPE creation requires official DISM binaries and WinPE package cabs supplied by Microsoft.
- **Impact**: Technicians cannot build `UltimateTechnician-x64.iso` without installing Microsoft ADK and WinPE Add-on on the host builder PC.
- **Workaround**: Install official Microsoft ADK for Windows 10/11 prior to running `build.ps1`.

### 2. Physical Clean Install Bare-Metal Validation
- **Feature**: Windows OS Deployment (`WindowsInstaller.ps1`)
- **Current Status**: `DRY-RUN TESTED`
- **Reason**: Automated unit testing on live host PCs blocks destructive `Clear-Disk` and `dism /Apply-Image` execution to preserve host system data.
- **Impact**: Partition formatting and WIM image deployment are validated via Dry-Run simulation. Real clean installation requires a disposable target test machine.
- **Workaround**: Test deployment workflows using hypervisor virtual disks (Hyper-V / VMware).

### 3. Defender WMI Provider in WinPE
- **Feature**: Windows Defender Security Status (`SecurityCenter.ps1`)
- **Current Status**: `FULL WINDOWS ONLY`
- **Reason**: `Get-MpComputerStatus` cmdlet requires desktop Windows Defender WMI provider packages not included in standard WinPE images.
- **Impact**: Running `SecurityCenter.ps1` inside minimal WinPE reports "Defender Module Not Loaded".
- **Workaround**: Offline malware scanning can be initiated via external open-source offline antivirus tools registered in `Config/plugins.json`.

### 4. OEM Hardware RAID Drivers
- **Feature**: Storage Drive Discovery (`DiskManager.ps1`)
- **Current Status**: `REQUIRES OEM DRIVERS`
- **Reason**: Proprietary hardware RAID controllers (e.g. Intel VMD, PERC RAID) require vendor storage drivers `.inf` to expose virtual disks to WinPE.
- **Impact**: Target disks behind un-configured RAID controllers may not be visible in WinPE disk query.
- **Workaround**: Place vendor storage drivers in `Drivers/` and inject them into WinPE via DISM (`dism /Image:mount /Add-Driver /Driver:Drivers /Recurse`).
