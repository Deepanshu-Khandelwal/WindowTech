# Cybersecurity, Safety, & Legal Policy

---

## 🔒 Security Principles

The **Ultimate PC Technician Toolkit** is built on strict cybersecurity, legal compliance, and data protection principles.

### 1. Zero Credential Theft & Zero Malware Functionality
- **No Password Stealing**: The toolkit does NOT contain credential dumping, LSASS extraction, browser password stealing, keylogging, or token theft tools.
- **No Activation Bypasses**: The toolkit does NOT include Windows activation cracks, KMS emulators, or piracy utilities.
- **No Malware Evasion**: The toolkit does NOT incorporate rootkits, payload obfuscators, or persistence backdoors.

### 2. Encryption & BitLocker Protection
- The toolkit **NEVER attempts to bypass BitLocker encryption** without a legitimate recovery key provided by the user.
- BitLocker volume protection status is detected and displayed to alert the technician prior to offline registry or bootloader modifications.

### 3. Explicit Safeguards & Risk Classification
All actions in the toolkit are categorized by risk level:

| Risk Level | Description | Safeguard Enforced |
|---|---|---|
| **LOW** | Read-only hardware checks, status display, log inspection. | No prompt required. |
| **MEDIUM** | Non-destructive repairs (SFC scan, Winsock reset, DNS flush). | User prompt `(Y/N)`. |
| **HIGH** | Bootloader rebuilds, registry edits, service modifications. | Explicit prompt `(Y/N)` with warning details. |
| **DESTRUCTIVE** | Disk formatting, partition deletion, WIM image applying, drive wiping. | **Requires explicit user string entry: `CONFIRM`**. |

### 4. Audit Trail & Logging
- Every execution of a script, plugin, or diagnostic command is recorded in structured JSON format and plain text under `/Logs/YYYY-MM-DD/`.
- Logs include timestamps, tool name, user confirmation status, command arguments, and exit codes to ensure complete technician accountability.
