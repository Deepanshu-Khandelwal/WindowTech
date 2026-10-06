# Changelog

All notable changes to the **Ultimate PC Technician Toolkit** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-10-06

### Added
- **Official Stable Release v1.0.0**.
- Automated 10-Point PC Health Check engine with green/yellow/red indicators.
- Active WinPE boot media protection (`Get-TechBootMediaDiskNumber`).
- WPF Technician Control Center UI with 14 functional operation tabs and dark theme.
- Offline Windows volume scanner (`C:\Windows`, `D:\Windows`) supporting offline SFC and DISM servicing.
- User profile data backup wizard for non-destructive data recovery (`Desktop`, `Documents`, `Downloads`, `Pictures`, `Videos`, Browser profiles).
- Driver management module for DISM driver export and offline injection.
- Automated WinPE builder script (`WinPE/build.ps1`) with ADK/MakeWinPEMedia automation.
- Comprehensive automated test runner suite (`Tests/TestRunner.ps1`) verifying backend modules and safety rules.
- Toolkit Self-Check Engine (`Scripts/SelfCheck.ps1`) for pre-flight environment verification.
- Controlled Post-1.0 Update & Migration Manager (`Scripts/UpdateManager.ps1`) with SHA-256 integrity verification and rollback support.
- JSON schema for configuration validation (`Config/config.schema.json`).

### Changed
- Refactored `OfflineServicing.ps1` variable string interpolation to ensure 100% module loading validation.
- Standardized all script paths to relative `$PSScriptRoot` resolution for full portability across USB drives and external SSDs.

### Security
- Mandated target-specific `CONFIRM <Model>` confirmation keywords for all high-risk disk operations.
- Enforced strict read-only source and capacity validation in disk cloning module.
- Omitted all credential theft, BitLocker password defeat, and activation bypass capabilities by design.

---

## [0.9.0-rc.1] - 2026-10-06

### Added
- Release Candidate 1 release package.
- Full inventory of open-source third-party licenses under `ThirdPartyLicenses/`.
