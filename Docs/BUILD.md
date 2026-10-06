# Building the Ultimate PC Technician Toolkit

This guide explains how to generate the custom WinPE bootable ISO image (`UltimateTechnicianPE.iso`) using the automated PowerShell build script `WinPE/build.ps1`.

---

## 📋 Prerequisites

1. **Host Operating System**: Windows 10 or Windows 11 (x64).
2. **Administrator Privileges**: Required for mounting WIM images and running DISM package injections.
3. **Microsoft Windows ADK**:
   - Install **Windows Assessment and Deployment Kit (ADK)** for Windows 10 or 11.
   - Install **Windows PE add-on for the Windows ADK**.
   - Official Download: [Microsoft ADK Downloads](https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install)
4. **PowerShell 5.1 or PowerShell 7+**.

---

## ⚙️ Build Process

1. Open PowerShell as **Administrator**.
2. Navigate to the project directory:
   ```powershell
   cd \path\to\UltimateTechnician
   ```
3. Run the WinPE Build Script:
   ```powershell
   .\WinPE\build.ps1
   ```

---

## 🔍 What `build.ps1` Does Automatically

1. Validates the installation of Microsoft ADK and WinPE Add-on tools.
2. Executes `copype.cmd amd64` to create an x64 WinPE working directory (`C:\WinPE_Tech_Build`).
3. Mounts `boot.wim` using DISM.
4. Injects mandatory WinPE optional components:
   - `WinPE-WMI`: Enables WMI/CIM hardware inspection queries.
   - `WinPE-NetFX`: Adds .NET Framework support for WPF/WinForms applications.
   - `WinPE-Scripting`: Adds VBScript/Batch scripting host.
   - `WinPE-PowerShell`: Adds PowerShell 5.1 engine to WinPE environment.
   - `WinPE-StorageWMI`: Adds disk, partition, and volume management cmdlets (`Get-Disk`, `Format-Volume`).
   - `WinPE-DSH`: Adds HTML Application support.
   - `WinPE-FM`: Adds File Management helpers.
5. Embeds `UltimateTechnician` toolkit binaries, GUI application, and scripts into `X:\UltimateTechnician`.
6. Configures `startnet.cmd` startup script to auto-initialize `GUI\TechnicianUI.ps1` on boot.
7. Unmounts and commits changes to `boot.wim`.
8. Calls `MakeWinPEMedia.cmd /ISO` to create the final bootable ISO at `Boot/UltimateTechnicianPE.iso`.

---

## 🧪 Dry-Run Build Verification

To test the build script configuration without modifying disk or running DISM package injections:
```powershell
.\WinPE\build.ps1 -DryRun
```
