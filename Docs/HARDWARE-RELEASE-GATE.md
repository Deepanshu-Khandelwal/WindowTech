# Hardware Release Gate & Certification Requirements

This document defines the formal certification gate for transitioning **Ultimate PC Technician Toolkit v1.0.0** across certification levels.

---

## 🚦 Certification Tiers

```
[ LEVEL 1: SOFTWARE VALIDATED ]
  -> 100% Automated Script & Unit Tests Passing (9/9 Test Suites)
  -> 100% Native Dependency & Manifest Check (12/12 Available)
  -> Zero P0 / P1 / P2 / P3 Open Release Blockers
  -> Status: PASS

             ↓

[ LEVEL 2: LAB / VIRTUAL MACHINE VALIDATED ]
  -> Active WinPE Boot Media Safeguard Verified in Lab Fixture (`Get-TechBootMediaDiskNumber`)
  -> Hyper-V / VMware Virtual Machine Servicing & Dry-Run Deployment
  -> Disposable Virtual Disk WIM Deployment & Partitioning Simulation
  -> Status: PASS

             ↓

[ LEVEL 3: BARE-METAL HARDWARE VALIDATED ]
  -> Multi-Machine Physical UEFI & Legacy BIOS Field Certification
  -> Physical NVMe / SATA Storage Hardware Enumeration
  -> Physical USB Media Boot & Hardware Diagnostics Verification
  -> Status: NOT VERIFIED (Physical Hardware Field Test Required)

             ↓

[ LEVEL 4: LTS RELEASE CERTIFIED ]
  -> SHA-256 Release Artifact Checksum Verification (`SHA256SUMS.txt`)
  -> Complete Security Baseline & License Inventory Audit
  -> Status: CONDITIONALLY CERTIFIED (LEVEL 2 LAB/VM CERTIFIED)
```

---

## 📋 Release Certification Gate Checklist

| Category | Requirement | Verification Method | Status |
|---|---|---|---|
| **Software Integrity** | All 27 backend scripts parse & dot-source cleanly | `ModuleLoading.Tests.ps1` | **PASS** |
| **Boot Protection** | Active technician drive format/wipe strictly blocked | `BootMediaProtection.Tests.ps1` | **PASS** |
| **Cloning Safety** | Source vs destination reversal & identical target blocked | `CloningSafety.Tests.ps1` | **PASS** |
| **Config Schema** | Security invariants (`AllowCredentialTheft = false`) enforced | `Config.Tests.ps1` | **PASS** |
| **Update Safety** | SHA-256 package checksum & rollback tested | `UpdateManager.Tests.ps1` | **PASS** |
| **Self-Check Engine** | `Get-TechSelfCheck` returns status `READY` | `SelfCheck.Tests.ps1` | **PASS** |
| **Hardware Framework** | Safety policy & machine classification engine tested | `HardwareValidation.Tests.ps1` | **PASS** |
| **WinPE Builder** | `build.ps1 -DryRun` validates prerequisites cleanly | `WinPE/build.ps1` | **PASS** |
| **Licensing Manifest** | Inventory manifest catalog verified for all third-party tools | `ThirdPartyLicenses/manifest.json` | **PASS** |
| **Documentation** | Complete technical suite updated for v1.0.0 LTS | Docs Inventory Audit | **PASS** |

---

## 🏆 Official Certification Decision

**CURRENT CERTIFICATION DECISION**: **CONDITIONALLY CERTIFIED (LEVEL 2 LAB/VM CERTIFIED - BARE-METAL PHYSICAL FIELD TEST PENDING)**
