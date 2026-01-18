<div align="center">
  <img src="client/assets/nexus-logo.png" width="120" height="120" alt="Nexus Protocol Logo">
  
  <h1>NEXUS PROTOCOL</h1>
  <p><b>Phase 1.3: Multichain Sovereign Gateway & Sentry</b></p>

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
    <img src="https://img.shields.io/badge/Network-TON_|_IOTEX_STAGING-orange.svg" alt="Network Support" />
  </a>
  
  <p><i>Sovereign Infrastructure · DePIN-Ready Identity · Perimeter Hardening</i></p>
</div>

---

## 🔎 Phase 1.3: Hardened Sovereign Node
**Current Milestone:** `v1.3.1-staged` | **Focus:** Multichain Perimeter Security & DePIN Readiness

Nexus Protocol is a **Local-First Sovereign Gateway** that moves the trust perimeter from the cloud to user-owned hardware. Phase 1.3 establishes the **Sentry Guard**, a modular verification engine designed to validate request legitimacy across heterogeneous networks (TON and IoTeX).

> [!IMPORTANT]
> **Execution Scope Disclaimer:** Phase 1.x performs **no on-chain execution or settlement**. All logic executes locally on user hardware. Blockchain networks (TON / IoTeX) are treated strictly as **future anchoring or identity layers**, not execution environments.

### 🏛️ Milestone Highlights
* **🛡️ Sentry Guard (`backend/sentry.py`):** A deterministic perimeter module that validates platform integrity. While currently optimized for Telegram HMAC, it is architected for **IoTeX ioID** integration (Phase 2).
* **🔒 Sovereign Perimeter:** Requests are rejected at the edge before hitting the Economic Engine, ensuring only cryptographically verified state transitions occur.
* **🧬 Deterministic Economics:** Every transaction follows a strictly audited 60-30-10 split, maintaining ledger invariants regardless of the settlement chain.
* **🧠 Modular Authority:** Nexus treats the local Vault as the single source of truth; the Brain acts as the authoritative logic gate for the local environment.

---

## 📖 Documentation Index

| 📚 Category | 📄 Document | 🔍 Description |
| :--- | :--- | :--- |
| **Start Here** | **[Installation Guide](docs/INSTALL.md)** | ⚡ Run a hardened node locally |
| **Deep Dive** | **[Architecture](docs/ARCHITECTURE.md)** | 🏛️ Sentry-Gated Gateway design |
| **Logic** | **[Economic Model](docs/ECONOMICS.md)** | 💰 Deterministic 60-30-10 invariants |
| **Future** | **[Roadmap](docs/ROADMAP.md)** | 🗺️ From TON Gateway to IoTeX DePIN |

---

## 1. Overview

**Nexus Protocol** is an infrastructure research initiative building **User-Owned Sovereign Nodes**. Unlike centralized cloud gateways, Nexus runs entirely on user hardware. You own the execution, the local ledger, and the verification logic.

**Network Perimeter Evolution:** Phase 1 hardens the **Telegram/TON** gateway. Phase 2 (Planned) extends this to the **IoTeX DePIN** stack, allowing the Sentry to verify physical hardware identity (ioID) and prepare for off-chain data proofs (W3bstream).

---

## 2. Why Nexus Matters to Multichain Ecosystems

Nexus explores how transaction integrity, identity verification, and economic logic can be validated **before** interacting with congested or cost-bearing networks. By shifting validation to the edge, Nexus reduces unnecessary on-chain load while preserving deterministic outcomes.

## 3. Hardened Architecture

Nexus enforces a strict **"Verify-then-Execute"** flow. The **Sentry** handles network-specific verification, while the **Brain** handles the universal economic logic.

```text
         [ USER / DEVICE / APP ]
                    |
                    | 1. Signed Request (HMAC / ioID)
                    v
+---------------------------------------+
|   THE BRAIN (Multichain Gateway)      |  🛡️ SENTRY GUARD
|   (FastAPI · Python Stack)            |  (Identity Verification)
+------------------+--------------------+
                    |
             2. Verified Logic
             Execution (60-30-10)
                    |
                    v
+------------------+--------------------+
|   THE VAULT (Sovereign Ledger)        |  🧠 BRAIN AUTHORITY
|   (Local Persistence)                 |  (Atomic State Update)
+---------------------------------------+
```

---

## 4. 🚦 Quick Start (Windows)

Audit the staged Sentry-hardening codebase:

1. **Start:** Double-click **`start_nexus.bat`**.
2. **Open:** Visit **`http://localhost:8000`**.
3. **Audit:** Review `backend/sentry.py` for the core verification logic.

> **Note:** Sentry enforcement hooks are currently **staged** and not yet mandatory in the request pipeline. This phase focuses on logic hardening and architectural auditability.

---

## 5. Roadmap

| Phase | Goal | Status |
| :--- | :--- | :--- |
| **1.1** | Sovereign Foundation (Local-First) | ✅ **Completed** |
| **1.2** | Gateway Consistency (TON) | ✅ **Completed** |
| **1.3** | **Perimeter Hardening (Sentry Staged)** | 🔵 **Active** |
| **2.0** | **DePIN Identity (IoTeX ioID)** | 🔮 **Planned Integration** |

---

© 2026 Nexus Protocol · Licensed under **Apache License 2.0**