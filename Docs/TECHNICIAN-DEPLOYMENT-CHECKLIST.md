# Technician Deployment Pre-Flight Checklist

Technicians must verify every item on this pre-flight checklist before deploying Ultimate PC Technician v1.0.0 media into the field.

---

## 📋 Pre-Flight Checklist

```text
===============================================================================
ULTIMATE PC TECHNICIAN v1.0.0 — PRE-FLIGHT DEPLOYMENT CHECKLIST
===============================================================================

[ ] 1. RELEASE INTEGRITY
    - [ ] Release package downloaded from official repository.
    - [ ] SHA-256 hashes calculated and verified against Release/SHA256SUMS.txt.
    - [ ] release-manifest.json checked for version 1.0.0 and stable channel.

[ ] 2. USB MEDIA CREATION
    - [ ] USB 3.0 Flash Drive (16GB+) or External SSD prepared.
    - [ ] Target drive formatted and loaded using Create-TechnicianUSB.ps1.
    - [ ] Ventoy bootloader files written cleanly to EFI boot partition.

[ ] 3. TOOLKIT SELF-CHECK
    - [ ] Executed Get-TechSelfCheck on target media.
    - [ ] Self-Check result returned Status: READY.
    - [ ] All 27 PowerShell backend modules present and parsing cleanly.

[ ] 4. BOOT MEDIA PROTECTION TEST
    - [ ] Tested Get-TechBootMediaDiskNumber on test bench.
    - [ ] Destructive wipe attempt on toolkit drive verified BLOCKED.

[ ] 5. HARDWARE INVENTORY & DIAGNOSTICS
    - [ ] Verified SystemDetection.ps1 collects CPU, RAM, GPU, SMART metrics.
    - [ ] Verified HealthCheck.ps1 10-Point health check engine operates.

[ ] 6. LICENSE & SECURITY COMPLIANCE
    - [ ] ThirdPartyLicenses/manifest.json present on USB drive.
    - [ ] Security settings verified (AllowCredentialTheft = false).
    - [ ] Zero illegal, cracked, or pirated binaries present.

[ ] 7. FIELD TOOLKIT PACKING
    - [ ] Ultimate Technician USB Drive (labeled with v1.0.0).
    - [ ] Secondary blank USB drive for data backup & cloning.
    - [ ] Printed Technician Safety Brief (Docs/TECHNICIAN-SAFETY-BRIEF.md).

===============================================================================
CHECKLIST VERIFIED BY: ___________________________ DATE: ______________
===============================================================================
```
