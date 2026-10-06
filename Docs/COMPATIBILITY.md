# Hardware & Operating System Compatibility Matrix

This document defines the verified compatibility scope for the **Ultimate PC Technician Toolkit v1.0.0**.

---

## 🖥️ Operating System Support

| OS Version | Edition | Architecture | Online Servicing | Offline Servicing | Status |
|---|---|---|---|---|---|
| **Windows 11** (24H2 / 23H2 / 22H2) | Home, Pro, Enterprise, Workstation | x64 | Supported | Supported | **FULLY SUPPORTED** |
| **Windows 10** (22H2 / 21H2 / LTSB/LTSC) | Home, Pro, Enterprise, Education | x64 | Supported | Supported | **FULLY SUPPORTED** |
| **Windows Server 2022 / 2019 / 2016** | Standard, Datacenter | x64 | Supported | Supported | **SUPPORTED** |
| **Windows 8.1 / 7** | All Editions | x64 / x86 | Best Effort | Offline Only | **LEGACY SUPPORT** |

---

## 💻 Hardware & Firmware Compatibility

| Environment / Component | Specification | Compatibility Status | Notes |
|---|---|---|---|
| **Firmware Architecture** | UEFI (Native x64) | **FULLY SUPPORTED** | Secure Boot compatible via signed bootloaders |
| **Legacy Firmware** | Legacy BIOS / CSM | **SUPPORTED** | Via Ventoy MBR bootloader |
| **CPU Architectures** | x86_64 / AMD64 | **FULLY SUPPORTED** | Intel Core / Xeon, AMD Ryzen / EPYC |
| **Storage Controllers** | AHCI SATA, NVMe (PCIe Gen 3/4/5) | **FULLY SUPPORTED** | Native WinPE inbox driver support |
| **RAID Controllers** | Intel VMD, PERC, MegaRAID | **REQUIRES OEM DRIVER** | Inject OEM storage driver into `Drivers/` |
| **System Memory** | 4 GB Minimum (8 GB+ Recommended) | **SUPPORTED** | WinPE RAM disk requires ~1.5 GB RAM |

---

## 🛠️ WinPE & ADK Build Matrix

| ADK Release | WinPE Build | Architecture | Status |
|---|---|---|---|
| **Windows 11 ADK (10.1.26100.1)** | 10.0.26100.1 | x64 | **RECOMMENDED TARGET** |
| **Windows 10 ADK (10.1.19041.1)** | 10.0.19041.1 | x64 | **SUPPORTED** |
