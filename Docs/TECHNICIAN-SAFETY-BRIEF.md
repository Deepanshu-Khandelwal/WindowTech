# Technician Operational Safety Brief

> **CRITICAL OPERATIONAL RULES FOR FIELD TECHNICIANS**

---

## 🛑 The 7 Immutable Field Safety Rules

### RULE 1: NEVER ASSUME DISK 0 IS THE WINDOWS DISK
- Disk numbering varies by motherboard, NVMe slot, and BIOS boot order.
- **ALWAYS** check model name, capacity, serial number, and volume label before selecting a disk target.

### RULE 2: NEVER TEST DESTRUCTIVE FEATURES ON CUSTOMER DATA
- Destructive operations (partition wiping, disk formatting, DISM WIM OS deployment, boot repair) must **ONLY** be performed on **Class A (Disposable)** test hardware.
- On Class C (Client) PCs, perform user profile data preservation (`DataRecovery.ps1`) before servicing.

### RULE 3: VERIFY BOOT MEDIA SAFEGUARD
- The toolkit dynamically identifies its own active boot drive (`Get-TechBootMediaDiskNumber`).
- Never attempt to bypass or force execution against a protected active boot drive.

### RULE 4: ENFORCE TARGET CONFIRMATION KEYWORDS
- High-risk disk operations require typing exact target confirmation keywords (e.g., `CONFIRM <Model>`).
- Never type `CONFIRM` without re-reading the target model name and capacity displayed on screen.

### RULE 5: CLONING SOURCE CANNOT EQUAL DESTINATION
- `BackupClone.ps1` rejects identical source and destination target selections.
- Verify destination disk capacity is equal to or greater than source disk size before starting a clone.

### RULE 6: ZERO PRIVACY VIOLATIONS
- Never extract, store, or log passwords, credentials, browser keys, or BitLocker 48-digit recovery keys.
- All technician diagnostic logs remain 100% local with zero cloud upload.

### RULE 7: STOP AND LOG ON CRITICAL FAILURE
- If WinPE crashes, a disk disappears, or a safety check fails: **STOP IMMEDIATELY**.
- Do not attempt further destructive recovery commands. Save diagnostic logs to `Diagnostics/` and triage the issue.
