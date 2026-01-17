<div align="center">
  <img src="client/assets/nexus-logo.png" width="120" height="120" alt="Nexus Protocol Logo">
  
  <h1>NEXUS PROTOCOL</h1>
  <p><b>Phase 1.3: The Hardened Sovereign Gateway</b></p>

  <a href="https://github.com/arhantbarmate/nexus-core/actions">
    <img src="https://github.com/arhantbarmate/nexus-core/actions/workflows/ci.yml/badge.svg?branch=main" alt="CI Status" />
  </a>

  <a href="LICENSE">
    <img src="https://img.shields.io/badge/License-Apache_2.0-blue.svg" alt="License" />
  </a>

  <a href="docs/ROADMAP.md">
    <img src="https://img.shields.io/badge/Status-PHASE_1.3_HARDENING-indigo.svg" alt="Phase 1.3" />
  </a>

  <a href="docs/ARCHITECTURE.md">
    <img src="https://img.shields.io/badge/Security-Sentry_Staged-blueviolet.svg" alt="Security Staged" />
  </a>
  
  <p><i>Request Legitimacy · Deterministic State Transitions · Perimeter Hardening</i></p>
</div>

---

## 🔎 Phase 1.3 System Status: Hardened Gateway
**Current Milestone:** `v1.3.0-staged` | **Focus:** Perimeter Security & Request Validation

Phase 1.3 marks the transition of Nexus Protocol from a consistent gateway to a **Hardened Sovereign Node**. The primary objective is to ensure that the Economic Engine only processes state transitions that have been cryptographically validated at the perimeter.

> **Note:** The Sentry is staged and audited in v1.3.0; enforcement will be enabled once perimeter validation is fully verified.

### 🏛️ Milestone Highlights
* **🛡️ Sentry Verification:** Introduced the **Sentry Guard** (`backend/sentry.py`), a deterministic perimeter module designed to validate Telegram WebApp integrity signatures (HMAC-SHA256).
* **🔒 Fail-Closed Security:** Implementation of the "Hardened Sentry" model where unverified platform requests are rejected before reaching the logic layer.
* **🧬 Economic Invariants:** The Economic Engine is treated as a **deterministic state transition primitive**, ensuring auditability across all 60-30-10 splits.
* **🌉 Consistent Authority:** Maintained the "Brain-First" architecture, ensuring the local Vault remains the single, verified source of truth.

---

## 📖 Documentation Index

| 📚 Category | 📄 Document | 🔍 Description |
| :--- | :--- | :--- |
| **Start Here** | **[Installation Guide](docs/INSTALL.md)** | ⚡ Run a hardened node locally |
| **Deep Dive** | **[Architecture](docs/ARCHITECTURE.md)** | 🏛️ Sentry-Gated Gateway design |
| **Logic** | **[Economic Model](docs/ECONOMICS.md)** | 💰 Deterministic 60-30-10 invariants |
| **Future** | **[Roadmap](docs/ROADMAP.md)** | 🗺️ Hardening → Identity evolution |
| **Security** | **[Security Policy](docs/SECURITY.md)** | 🛡️ Threat models & disclosure |

---

## 1. Overview

**Nexus Protocol** is an infrastructure research initiative building a **Local-First Sovereign Node**. 
Unlike traditional cloud-hosted Mini Apps, Nexus runs entirely on your hardware. You own the execution, the database, and the ledger history.

**Phase 1.3** introduces **Perimeter Hardening**, establishing a "Clean Room" environment where requests are validated for platform legitimacy (HMAC) before they are allowed to mutate the sovereign state.

---

## 2. Hardened Architecture

In Phase 1.3, the system enforces a strict verification gate. The **Sentry** validates the request signature, the **Brain** executes the logic, and the **Vault** persists the result.

```text
         [ USER / BROWSER / TMA ]
                   |
                   | 1. Request with HMAC Signature
                   v
+---------------------------------------+
|   THE BRAIN (Hardened Gateway)        |  🛡️ SENTRY GUARD
|   (FastAPI · Port 8000)               |  (Verification Gate)
+------------------+--------------------+
                   |
           2. If Verified: Execute
           Deterministic Logic
                   |
                   v
+------------------+--------------------+
|   THE VAULT (Sovereign Ledger)        |  🧠 BRAIN AUTHORITY
|   (SQLite WAL · nexus_vault.db)       |  (Atomic Persistence)
+---------------------------------------+
```

---

## 3. 🚦 Quick Start (Windows)

The fastest way to deploy a node and audit the Sentry-staged codebase:

1. **Start:** Double-click **`start_nexus.bat`**.
2. **Open:** Visit **`http://localhost:8000`**.
3. **Stop:** Run **`stop_nexus.bat`**.

*For manual setup or security auditing, see [docs/INSTALL.md](docs/INSTALL.md).*

---

## 4. Execution Primitive — The 60-30-10 Invariant

Every state transition processed by the Brain follows a fixed, deterministic split to ensure ledger auditability:

* **60%** → Primary Actor Allocation
* **30%** → Secondary Pool Reservation
* **10%** → Network Reserved Fee

📄 **Full details:** [docs/ECONOMICS.md](docs/ECONOMICS.md)

---

## 5. Roadmap

| Phase | Goal | Status |
| :--- | :--- | :--- |
| **1.1** | Sovereign Foundation | ✅ **Completed** |
| **1.2** | Gateway Consistency | ✅ **Completed** |
| **1.3** | **Perimeter Hardening** | 🔵 **Active** |
| **2.0** | Identity & Signing | 🔮 **Planned** |

---

## 🛡️ Governance & Safety

* **[Security Policy](docs/SECURITY.md)** — Disclosure & threat scope
* **[Contributing](docs/CONTRIBUTING.md)** — Architectural boundaries
* **[Code of Conduct](docs/CODE_OF_CONDUCT.md)** — Professional standards

---

© 2026 Nexus Protocol · Licensed under the **Apache License 2.0**
