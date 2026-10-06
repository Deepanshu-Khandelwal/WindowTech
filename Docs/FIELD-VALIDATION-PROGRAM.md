# Field Validation Program & Physical Hardware Certification Standard

## 📌 Program Purpose & Scope

The **Field Validation Program** defines the official, repeatable operational procedure for field technicians to test and certify **Ultimate PC Technician Toolkit v1.0.0** on physical target PCs.

While software unit tests and virtual machine fixtures establish Level 1 (Software) and Level 2 (Lab/VM) validation, **Level 3 Bare-Metal Hardware Certification** requires physical boot and storage testing across real UEFI, Legacy BIOS, NVMe, and SATA hardware.

---

## 🔒 Machine Classification Policy

Technicians must strictly classify every machine prior to initiating validation tests:

1. **Class A — Disposable Test Machine**: Dedicated bench hardware with zero production data.  
   - **Allowed**: Full destructive testing (partition formatting, drive wiping, DISM WIM deployment, BCD boot rebuild, cloning).
2. **Class B — Controlled Lab Machine**: Controlled lab bench PC.  
   - **Allowed**: Non-destructive diagnostics, hardware inventory, offline SFC/DISM servicing, driver store exports, user profile data backup.
3. **Class C — Production / Client Machine**: Customer or production workstation.  
   - **STRICT SAFETY RULE**: DESTRUCTIVE TESTING IS STRICTLY FORBIDDEN ON CLASS C MACHINES. Data preservation must precede any repair operation.

---

## 🛠️ Required Field Test Equipment

- **Toolkit USB Media**: Ultimate PC Technician v1.0.0 Bootable USB 3.0 Flash Drive (16 GB+) or External NVMe/SATA SSD.
- **Secondary Target USB**: Blank 16 GB+ USB drive for cloning destination testing.
- **Disposable SATA / NVMe Drive**: Dedicated test disk for bare-metal OS installation.
- **Official Installation Media**: Legitimate Windows 10/11 x64 ISO/WIM image source.
- **Network Cables / Wi-Fi Adapter**: For diagnostic network stack verification.

---

## 🏷️ Test ID System & Artifact Storage

Every physical hardware validation run receives a unique identifier formatted as: `UT-FIELD-xxx` (e.g. `UT-FIELD-001`).

Field validation logs and JSON telemetry are written locally to:
```text
Diagnostics/FieldValidation/UT-FIELD-001/
├── machine.json
└── result.json
```

---

## 🚦 Operational Step-by-Step Test Procedure

### Step 1: Pre-Flight USB & SHA-256 Verification
1. Verify `Release/SHA256SUMS.txt` against local release artifacts before writing USB media.
2. Build/Deploy USB using `Scripts/Create-TechnicianUSB.ps1`.
3. Perform local `Get-TechSelfCheck` to ensure status is `READY`.

### Step 2: Firmware & Non-Destructive Boot Verification (Test Group A)
1. Insert Technician USB into target hardware USB 3.0 port.
2. Enter firmware setup (F2 / F12 / Del) and verify UEFI / Legacy BIOS mode and Secure Boot state.
3. Boot into WinPE operating environment.
4. Launch WPF Control Center UI (`TechnicianUI.ps1`).
5. Execute `Get-TechSelfCheck` inside WinPE and verify all checks return `PASS` or `READY`.

### Step 3: Hardware Inventory & Diagnostic Verification (Test Group B)
1. Launch Automated 10-Point Health Check (`Start-TechAutomatedHealthCheck`).
2. Verify detection of CPU, RAM capacity, GPU model, motherboard BIOS version, and storage SMART attributes.
3. Record diagnostic output in `Diagnostics/PC_Health_Report.json`.

### Step 4: Boot Media Safeguard & Multi-Disk Safety Verification (Test Group C)
1. Verify that `Get-TechBootMediaDiskNumber` correctly identifies the physical disk index hosting the toolkit USB.
2. Attempt a formatting operation against the active toolkit disk.
3. **Expected Result**: Safety Engine **BLOCKS** execution with a critical safety alert.
4. Verify multi-disk display clearly distinguishes internal Windows SSDs from the technician USB drive.

### Step 5: Destructive Servicing & Deployment (Class A Machine Only)
1. On Class A Disposable Machine only, initiate Windows 10/11 deployment wizard (`WindowsInstaller.ps1`).
2. Verify explicit target model confirmation (`CONFIRM <Model>`).
3. Complete DISM WIM image apply, BCDboot UEFI bootloader creation, and unattend setup processing.
4. Reboot into newly installed OS to certify bare-metal deployment.

---

## 🛑 Failure Handling & P0 Triage

If a critical safety failure occurs (e.g., boot media protection fails, wrong disk is targeted, WinPE crashes):
1. **STOP IMMEDIATELY**.
2. Do not proceed to any further operations.
3. Log the failure in `Diagnostics/FieldValidation/<TestID>/result.json`.
4. Submit P0 safety blocker report.
