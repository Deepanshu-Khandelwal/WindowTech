# Automated & Manual Testing Guide

This guide details how to execute unit, safety, integration, and dependency tests for the **Ultimate PC Technician Toolkit**.

---

## 🧪 Running the Test Suite

Open PowerShell as Administrator in the project root directory:

### 1. Run All Tests
```powershell
.\Tests\TestRunner.ps1
```

### 2. Run Dependency Auditor
```powershell
.\Tests\Test-Dependencies.ps1
```

### 3. Run Specific Safety & Unit Tests
```powershell
.\Tests\Safety\Test-BootMediaProtection.ps1
.\Tests\Safety\Test-CloningSafety.Tests.ps1
.\Tests\Integration\BackupIntegration.Tests.ps1
```

---

## 📋 Test Suite Breakdown

- **`Config.Tests.ps1`**: Validates configuration structure, default parameters, and security flags.
- **`Logger.Tests.ps1`**: Verifies structured log writing and `New-TechResult` object contract.
- **`BootMediaProtection.Tests.ps1`**: Ensures Safety Engine blocks destructive actions against active boot media.
- **`CloningSafety.Tests.ps1`**: Ensures cloning validation rejects identical source/destination and boot media targets.
- **`BackupIntegration.Tests.ps1`**: Performs real file backup against isolated test fixtures verifying nested files and Unicode encoding.
- **`ModuleLoading.Tests.ps1`**: Validates dot-sourcing and execution syntax across all 22 backend scripts.
