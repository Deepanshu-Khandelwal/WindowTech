# Post-1.0 Long-Term Support & Release Engineering Maintenance Policy

## 📌 Principles of Post-1.0 Maintenance

1. **Stable Core Priority**: Core safety modules (`SafetyEngine.ps1`, `DiskManager.ps1`, `BackupClone.ps1`, `WindowsInstaller.ps1`, `BootRepair.ps1`, `Create-TechnicianUSB.ps1`, `Logger.ps1`) are governed by a conservative change freeze policy.
2. **Mandatory Regression Gates**: Any proposed change to backend modules must pass the automated test runner (`Tests/TestRunner.ps1`) and dependency auditor (`Tests/Test-Dependencies.ps1`) before merging.
3. **Semantic Versioning Enforcement**:
   - **PATCH** (`1.0.x`): Bug fixes, documentation updates, safety enhancements.
   - **MINOR** (`1.x.0`): New diagnostic tools, additional non-breaking features.
   - **MAJOR** (`x.0.0`): Architectural overhauls or breaking configuration changes.

---

## 🚦 Release Gate Checklist

Before tag creation or release packaging, the following mandatory steps must be executed:

```
[ ] 1. Run Toolkit Self-Check (`Get-TechSelfCheck`) -> Status MUST be READY.
[ ] 2. Run Automated Test Suite (`TestRunner.ps1`) -> 100% PASS (0 Failures).
[ ] 3. Run Dependency Auditor (`Test-Dependencies.ps1`) -> 100% AVAILABLE (0 Missing).
[ ] 4. Audit Configuration Schema (`config.schema.json`) & Security Flags.
[ ] 5. Generate Release Manifest & SHA-256 Checksums (`Build/release-manifest.json`).
[ ] 6. Verify License Manifest Integrity (`ThirdPartyLicenses/manifest.json`).
[ ] 7. Update CHANGELOG.md & RELEASE-NOTES.md.
```

---

## 🏷️ Stable Release Version Tagging

When creating a new release tag:
```bash
git tag -a v1.0.0 -m "Ultimate PC Technician Toolkit v1.0.0 Stable Release"
```
