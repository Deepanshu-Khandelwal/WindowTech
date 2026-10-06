# Post-1.0 Security Baseline & Governance Protocol

## 🛡️ Security Architecture Overview

The **Ultimate PC Technician Toolkit** operates on a zero-trust, privacy-first, offline-by-default administrative model designed for legitimate IT maintenance, system repair, and data recovery.

---

## 🔒 Core Security Controls & Guarantees

### 1. Absolute Prohibition of Malicious & Destructive Capabilities
- **Zero Telemetry / Zero Cloud Upload**: No technician logs, system data, hardware details, or user files are ever transmitted remotely.
- **No Credential Theft / Password Extraction**: Passphrase cracking, LSASS memory dumping, credential extraction, and browser password decryption are strictly omitted.
- **No Windows Activation Defeat**: KMS emulators, licensing cracks, or digital license bypasses are prohibited.
- **No Security/Authentication Bypasses**: The toolkit operates within standard administrative security models and does not bypass OS security boundaries.

### 2. Physical Disk & Boot Media Safeguards
- **Active Boot Drive Identification (`Get-TechBootMediaDiskNumber`)**: Automatically detects the active WinPE or technician boot drive letter and blocks disk wipe, format, clean, or partition modification operations against it.
- **Target-Specific String Confirmation**: Destructive operations require explicit confirmation matching the target model name (e.g., `CONFIRM <Model>`).
- **Cloning Reversal Protection**: Rejects identical source and destination target selections and verifies destination disk capacity before initiating write operations.

### 3. Execution & Script Security
- **PowerShell Execution Boundary**: All scripts run with explicit parameters and error handling. Generic `Invoke-Expression` execution of untrusted remote URLs is forbidden.
- **Plugin Governance**: Plugins in `Config/plugins.json` are explicitly cataloged with risk levels and permissions. Third-party executable binaries undergo SHA-256 verification.

---

## 📋 Security Triage Matrix

| Severity Level | Definition | SLA / Remediation Priority |
|---|---|---|
| **CRITICAL** | Potential data loss bug, boot media block failure, or unsafe automatic execution | **Immediate P0 Patch** |
| **HIGH** | Incorrect disk model resolution or permission bypass | **P1 Maintenance Release** |
| **MEDIUM** | UI display anomaly or non-fatal logging failure | **Next Scheduled Patch Release** |
| **LOW** | Cosmetic or documentation typo | **Standard Release Cycle** |

---

## 🔍 Audit & Verification Protocol

Technicians can verify script integrity and policy enforcement by inspecting backend modules under `Scripts/`:
- `SafetyEngine.ps1`: Core safety checks and boot media protection.
- `SelfCheck.ps1`: Environment and module integrity checker.
- `UpdateManager.ps1`: Safe update checksum and migration engine.
