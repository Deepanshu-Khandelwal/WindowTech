# Controlled Update Architecture & Rollback Protocol

## 🔄 Overview

The **Ultimate PC Technician Toolkit** follows a conservative, technician-controlled update model. Updates are never applied automatically in the background without explicit technician validation and authorization.

---

## 🛠️ Update Validation Workflow

```
[ Update Package / Manifest ]
             ↓
  1. Validate Manifest Schema (`Test-TechUpdatePackage`)
             ↓
  2. Verify Channel (`stable` / `beta`)
             ↓
  3. Verify Artifact SHA-256 Checksum
             ↓
  4. Core Safety Protection Check (Block silent safety module modifications)
             ↓
  5. Backup Existing Configuration (`config.json.v1.bak`)
             ↓
  6. Apply Update & Verify (`Get-TechSelfCheck`)
             ↓
  [ SUCCESS ] or [ ROLLBACK (`Invoke-TechUpdateRollback`) ]
```

---

## 📦 Update Manifest Format

Official update release manifests (`release-manifest.json`) adhere to the following schema:

```json
{
  "product": "Ultimate PC Technician",
  "version": "1.0.1",
  "channel": "stable",
  "architecture": "x64",
  "sha256": "6E8C2F3A4B5D6E7F8A9B0C1D2E3F4A5B6C7D8E9F0A1B2C3D4E5F6A7B8C9D0E1F",
  "minimumToolkitVersion": "1.0.0",
  "releaseNotes": "Maintenance patch resolving hardware detection corner cases.",
  "modifiedModules": [
    "HardwareDiagnostics.ps1",
    "SystemDetection.ps1"
  ]
}
```

---

## 🛑 Core Safety Logic Protection Rule

To prevent malicious or accidental disruption of safety safeguards, `UpdateManager.ps1` enforces the **Core Safety Protection Gate**:
- Updates targeting `SafetyEngine.ps1` or `DiskManager.ps1` are **rejected by default**.
- Replacing core safety code requires passing the explicit `-AllowCoreSafetyUpdate` switch after technician review.

---

## ⏪ Rollback Procedure

If an update fails verification or introduces unexpected behavior, rollback to the previous configuration can be performed immediately via PowerShell:

```powershell
. .\Scripts\UpdateManager.ps1
Invoke-TechUpdateRollback
```

This restores the pre-update configuration backup (`config.json.v*.bak`) and logs the rollback operation.
