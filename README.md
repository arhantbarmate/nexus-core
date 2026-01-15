<div align="center">
  <img src="client/assets/nexus-logo.png" width="120" height="120" alt="Nexus Protocol Logo">
  <h1>NEXUS PROTOCOL</h1>
  <p><b>Local-First Economic Execution Engine for Sovereign Nodes</b></p>

  [![Nexus CI](https://github.com/arhantbarmate/nexus-core/actions/workflows/ci.yml/badge.svg)](https://github.com/arhantbarmate/nexus-core/actions)
  ![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)
  
  <p><i>Local-First Execution · Deterministic Economics · Cryptographic Anchoring Readiness</i></p>
</div>

---

## 📖 Documentation Index
- **[Installation & Automation](./docs/INSTALL.md)** — Run a local node in seconds using `.bat` scripts.
- **[Technical Architecture](./docs/architecture.md)** — Deep dive into the Brain / Body / Vault design.
- **[Economic Model](./docs/economic-model.md)** — Rationale behind the 60-30-10 deterministic split.
- **[Research Roadmap](./docs/ROADMAP.md)** — *Non-binding* future research directions (Phase 1.2+).
- **[Frequently Asked Questions](./docs/FAQ.md)** — Design decisions and scope clarifications.

---

## 1. Overview

**Nexus Protocol** is a research-driven infrastructure project exploring how **economic logic can execute locally on user devices**, persist independently of centralized servers, and later synchronize with a global blockchain via **cryptographic proofs** rather than raw data replication.

Nexus is **not a social media application** and **not a blockchain**. It is a **local-first economic execution engine** designed to remain functional during outages, censorship, or partial connectivity loss.

> **Core Research Question:** Can user devices operate as *sovereign economic nodes* while remaining verifiable at a global level?

---

## 2. Core Principle: Sovereignty → Sync

Most modern applications are **cloud-first**, meaning execution happens on remote servers and users "rent" their data. Nexus is **local-first**:
- **Execution:** Happens on the user’s machine (The Brain).
- **Persistence:** State is stored in a local vault (The Vault).
- **Offline-Ready:** The system remains fully functional without an internet connection.
- **Verification:** When online, Nexus synchronizes by anchoring cryptographic commitments (Merkle roots) to the TON blockchain—without uploading private data.



---

## 3. System Architecture (Phase 1.1)

Nexus follows a strict layered architecture separating execution, visualization, and persistence.

```text
NEXUS PROTOCOL — PHASE 1.1 TOPOLOGY

    [ BODY ]  <-------- REST API -------->  [ BRAIN ]
 (Flutter UI)                             (FastAPI Engine)
      |                                        |
      |                                        |
      v                                        v
 [ Dashboard ]                          [ 60-30-10 Logic ]
 [ Visualization ]                      [ Validation Layer ]
                                               |
                                               | (SQL / WAL Mode)
                                               v
                                          [   VAULT   ]
                                        (SQLite DB File)
```

### The Brain (Execution Engine)
* **Tech:** FastAPI (Python)
* **Role:** Sole authority for economic execution. Enforces deterministic **60-30-10 logic** and guarantees restart-safe persistence.

### The Body (Reference Client)
* **Tech:** Flutter (Desktop)
* **Role:** Visualization and control surface. Displays ledger state in real-time but holds **no economic authority**.

### The Vault (Persistence)
* **Tech:** SQLite (Local File)
* **Role:** Sovereign storage layer. Features an append-only transaction history that survives system crashes and is fully user-owned.

---

## 4. 🚦 Quick Start (Windows)

The fastest way to launch the Phase 1.1 prototype is via the root automation scripts:

1.  Double-click **`start_nexus.bat`**.
2.  Wait for the FastAPI server to initialize and the Flutter Dashboard to launch.
3.  To shut down, run **`stop_nexus.bat`**.

*For manual setup (Linux/macOS), see the [Full Installation Guide](./docs/INSTALL.md).*

---

## 5. Economic Primitive: The 60-30-10 Rule

Every transaction processed by the engine is split deterministically:
- **60% — Creator Allocation**
- **30% — User / Network Pool**
- **10% — Protocol Fee**

This is an **invariant of the execution engine**, ensuring absolute auditability and preventing floating-point drift through 2-decimal rounding.

---

## 6. Project Status & Scope Guard

Nexus is currently in the **Feasibility & Infrastructure Research** phase (Phase 1.1).

> **Phase 1.1 Scope Guard:** This version intentionally excludes identity, signatures, wallets, and on-chain settlement. All validated logic remains strictly local to the sovereign node. Cryptographic anchoring is currently provided as a standalone feasibility script (`research/merkle_anchor.py`).

---

## 🔮 Phase 1.2: TON Connect (Roadmap)

*Non-binding research goals for Phase 1.2 include:*
1.  **Client-Side Signing:** Integrating TON Connect 2.0 for wallet-based identity.
2.  **Merkle Anchoring:** Batching local transaction splits into signed Merkle Roots.
3.  **On-Chain Verification:** Publishing "Check-In" transactions to TON to prove ledger state without revealing raw data.

---

© 2026 Nexus Protocol  
Licensed under the **Apache License, Version 2.0**