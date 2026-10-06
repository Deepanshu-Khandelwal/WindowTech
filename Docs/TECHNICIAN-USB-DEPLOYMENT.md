# Technician USB Deployment & Media Creation Guide

This guide describes the step-by-step process for building, deploying, and verifying **Ultimate PC Technician v1.0.0** onto a bootable USB flash drive or external SSD.

---

## 🛠️ Prerequisites

- **Target Media**: USB 3.0 Flash Drive (16 GB minimum, 32 GB+ recommended) or External NVMe/SATA SSD.
- **Host Workstation**: Windows 10 or Windows 11 x64.
- **Toolkit Workspace**: Local toolkit repository at `C:\UltimateTechnician` or extracted release package.
- **PowerShell**: PowerShell 5.1 or 7.x running as Administrator.

---

## 🚀 Step-by-Step Deployment Procedure

### Step 1: Verify Release Checksums
Before deploying, compute and compare release file hashes against `Release/SHA256SUMS.txt`:
```powershell
Get-FileHash -Path .\Release\release-manifest.json -Algorithm SHA256
```

### Step 2: Launch Technician USB Creator Wizard
Run the automated USB deployment script from an elevated PowerShell prompt:
```powershell
. .\Scripts\Create-TechnicianUSB.ps1
```

### Step 3: Select Target USB Disk Safely
1. The script enumerates attached removable USB drives with Model, Serial Number, Capacity, and Volume Label.
2. Select the target USB disk number when prompted.
3. **SAFETY WARNING**: The deployment wizard displays target details and requires typing `CONFIRM` before formatting.

### Step 4: Formatting & File Transfer
1. The deployment engine formats the target USB drive with FAT32/NTFS partitions.
2. Embeds Ventoy multi-boot bootloader structure into the USB EFI boot sector.
3. Copies backend modules (`Scripts/`), Control Center GUI (`GUI/`), configuration manifests (`Config/`), tools (`Tools/`), portable applications (`PortableApps/`), and license inventory (`ThirdPartyLicenses/`).

### Step 5: Verification & Self-Check
Once copy is complete, execute `Get-TechSelfCheck` directly against the target USB drive letter:
```powershell
. E:\UltimateTechnician\Scripts\SelfCheck.ps1
Get-TechSelfCheck
```
Verify that the output displays: `Status: READY`.

---

## 🔒 Target USB Safeguard Invariants

- **Active Drive Protection**: The wizard prevents selecting `$env:SystemDrive` or the disk hosting the active PowerShell process.
- **Target Confirmation Gate**: Formatting requires typing `CONFIRM` for high-risk write operations.
- **Ventoy Integration**: Configures fallback UEFI/Legacy boot entries without altering non-toolkit partitions.
