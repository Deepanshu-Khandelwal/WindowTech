# Installing to USB Flash Drives & External HDDs/SSDs

This document details how to install and configure the **Ultimate PC Technician Toolkit** on a bootable USB flash drive, external HDD, or external SSD.

---

## 🎯 Supported Target Devices

- USB 3.0 / 3.1 / 3.2 Flash Drives (16 GB or larger recommended)
- External USB HDDs
- External USB NVMe / SATA SSDs (Recommended for high performance)

---

## 🚀 Option 1: Automated Wizard (`Create-TechnicianUSB.ps1`)

The repository includes an automated installation wizard that prepares your external storage device with GPT UEFI boot structure and persistent toolkit data storage.

### Steps:

1. Insert your target USB flash drive or external SSD into your technician workstation.
2. Open PowerShell as **Administrator**.
3. Run the installer script:
   ```powershell
   .\Scripts\Create-TechnicianUSB.ps1
   ```
4. The wizard will display all detected non-system external drives:
   ```
   Available Target Disks for Technician Toolkit Installation:
   [Disk 1] Model: Samsung SSD 980 1TB | Size: 931.51 GB | Bus: NVMe
   [Disk 2] Model: SanDisk Ultra USB 3.0 | Size: 28.64 GB | Bus: USB
   ```
5. Type the desired **Disk Number**.
6. Review the safety warning and type **`CONFIRM`** to proceed.
7. The wizard will partition the drive (EFI Boot FAT32 + Persistent Data NTFS) and copy all toolkit assets.

---

## 🚀 Option 2: Ventoy Multi-Boot Integration (Recommended for Multi-ISO Setup)

Ventoy is an open-source multi-boot tool that allows booting ISO files directly without reformatting the USB drive when adding new Windows ISOs or tools.

### Steps:

1. Download **Ventoy** from [ventoy.net](https://www.ventoy.net).
2. Install Ventoy onto your external USB/SSD (GPT + Secure Boot Support enabled).
3. Copy the built `Boot/UltimateTechnicianPE.iso` into the root of the Ventoy partition.
4. Copy your official Windows 10 ISO (`Windows10.iso`) and Windows 11 ISO (`Windows11.iso`) into `WindowsInstall/`.
5. Copy the `/UltimateTechnician` toolkit root directory into the Ventoy data partition.
6. Boot the target PC from the USB/SSD drive. Ventoy will display the boot menu with all ISOs and WinPE.
