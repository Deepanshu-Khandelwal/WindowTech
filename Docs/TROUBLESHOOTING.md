# Technician Troubleshooting Guide

This guide assists technicians in resolving common issues encountered during toolkit building, USB creation, booting, and offline servicing.

---

## 🛠️ Common Issues & Resolutions

### 1. `build.ps1` fails: "Microsoft Windows ADK with WinPE Add-on was not found"
- **Cause**: The host machine does not have Microsoft ADK and WinPE Add-on installed in the default location.
- **Resolution**: Download and install both **Windows ADK** and **Windows PE Add-on for ADK** from the official [Microsoft ADK Download Page](https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install).

### 2. Safety Engine blocks disk operation: "CRITICAL SAFETY BLOCK: BOOT MEDIA PROTECTION"
- **Cause**: The technician attempted to format, clean, or wipe the physical disk currently running the active WinPE or toolkit environment.
- **Resolution**: Select the target customer disk (e.g. Disk 0 or Disk 2) instead of the USB/SSD drive running the toolkit.

### 3. DISM Repair returns Error 0x800f081f ("The source files could not be found")
- **Cause**: DISM RestoreHealth requires clean Windows payload files.
- **Resolution**: Mount an official Windows ISO matching the target OS build, and run DISM specifying the source:
  ```powershell
  dism /Online /Cleanup-Image /RestoreHealth /Source:W:\Sources\install.wim:1 /LimitAccess
  ```

### 4. Windows 11 setup fails hardware checks on legacy laptops
- **Cause**: Target PC lacks TPM 2.0, Secure Boot, or 8 GB RAM.
- **Resolution**: Use the included unattended template [`WindowsInstall/unattend_win11.xml`](../WindowsInstall/unattend_win11.xml) which includes LabConfig registry bypasses (`BypassTPMCheck`, `BypassSecureBootCheck`, `BypassRAMCheck`).
