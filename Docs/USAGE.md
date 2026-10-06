# Technician Operating Manual & Workflow Guide

---

## ⚡ Technician Workflow Strategy

The toolkit enforces a **Recovery-First** technician operating strategy:

```
    BACKUP DATA
        ↓
     DIAGNOSE
        ↓
      REPAIR
        ↓
      VERIFY
        ↓
 ONLY IF NECESSARY
  REINSTALL WINDOWS
```

Never recommend formatting or reinstalling Windows as a first step without inspecting backups and attempt diagnostic repairs.

---

## 🔍 Step-by-Step Operations

### 1. Automated Full PC Health Check
1. Launch the Control Center GUI (`GUI\TechnicianUI.ps1`).
2. Click **`⚡ FULL PC HEALTH CHECK`**.
3. The engine evaluates:
   - System CPU, RAM, Motherboard, GPU
   - Storage Drive SMART Health & HealthStatus
   - Free disk space on `C:`
   - BCD Bootloader integrity
   - Critical Windows Services status (`wuauserv`, `BITS`, `WinDefend`)
   - Windows Event Log critical errors (Last 24 Hours)
   - Active network adapters
4. Review the generated report (`Diagnostics/PC_Health_Report.json`) and overall status (**GREEN / YELLOW / RED**).

### 2. Offline Windows Servicing & Repair
When the target PC cannot boot into Windows:
1. Boot the target PC into **Ultimate PC Technician WinPE**.
2. Click **Scan Offline Windows** in the GUI or execute:
   ```powershell
   . .\Scripts\OfflineServicing.ps1
   Find-TechOfflineWindowsInstallations
   ```
3. Once the target Windows installation (e.g. `D:\Windows`) is located:
   - Run **Offline SFC**:
     ```powershell
     Invoke-TechSFC -TargetVolume "D:" -WinDir "D:\Windows"
     ```
   - Run **Offline DISM Repair**:
     ```powershell
     Invoke-TechDISMRepair -Action "RestoreHealth" -OfflineTargetDir "D:\Windows"
     ```

### 3. Bootloader / BCD Rebuild
To fix `0xc000000e` or missing boot partition errors:
1. Identify system partition (EFI FAT32 partition, e.g. `S:`) and Windows directory (e.g. `C:\Windows`).
2. Run BCD Rebuild command:
   ```powershell
   Invoke-TechBCDRepair -SystemPartitionDriveLetter "S:" -WindowsDirectory "C:\Windows"
   ```

### 4. Data Recovery & File Backup
- Use `Scripts\DiskManager.ps1` to inspect partitions.
- Copy user profiles (`Desktop`, `Documents`, `Downloads`, `Pictures`) to an external target drive before executing any disk operations.
- Open **TestDisk** from `Tools/testdisk_win.exe` for recovering deleted partitions or file carving.

### 5. Safe Preview Mode (Dry-Run)
Check the **Enable Dry-Run (Safe Preview Mode)** checkbox in the GUI header or pass `-DryRun` in PowerShell to simulate commands without executing actual changes.
