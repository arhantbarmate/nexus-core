# NEXUS PROTOCOL

> **Local-First Economic Execution Engine for Sovereign Nodes**

**STATUS:** Phase 1.1 — Feasibility Prototype (Live)
![Nexus CI](https://github.com/arhantbarmate/nexus-core/actions/workflows/ci.yml/badge.svg)  
**LICENSE:** Apache License 2.0  
**FOCUS:** Local-First Execution · Deterministic Economics · Cryptographic Anchoring Readiness  

---

## 📖 Documentation
- **[Installation Guide](INSTALL.md)** — Run a local Nexus node in minutes.
- **[Architecture Overview](docs/architecture.md)** — Brain / Body / Vault design.
- **[Economic Model](docs/economic-model.md)** — Deterministic 60-30-10 split rationale.
- **[Research Roadmap](docs/ROADMAP.md)** — *Non-binding* future research directions.
- **[FAQ](FAQ.md)** — Design decisions and scope clarifications.

---

## 1. Overview

**Nexus Protocol** is a research-driven infrastructure project exploring how **economic logic can execute locally on user devices**, persist independently of centralized servers, and later synchronize with a global blockchain via **cryptographic proofs rather than raw data replication**.

Nexus is **not a social media application** and **not a blockchain**.  
It is a **local-first economic execution engine** designed to remain functional during outages, censorship, or partial connectivity loss.

The core question Nexus investigates:

> Can user devices operate as *sovereign economic nodes* while remaining verifiable at a global level?

---

## 2. Core Principle — Sovereignty → Sync

Most modern applications are **cloud-first**:
- Execution happens on remote servers
- Users rent identity and data
- Outages or bans result in total loss of access

Nexus is **local-first**:
- Execution happens on the user’s machine
- State is stored in a local vault
- The system remains fully functional offline

When connectivity is available, Nexus is designed to **synchronize outward** by anchoring cryptographic commitments (Merkle roots) to a blockchain—without uploading private data.

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
                                               v
                                         [  VAULT  ]
                                       (SQLite DB File)
                                      (Local Persistence)
```

### Layer 1 — The Brain (Execution Engine)
- **Tech:** FastAPI (Python)
- **Role:** Sole authority for economic execution
- **Responsibilities:**
  - Enforces deterministic 60-30-10 logic
  - Validates inputs
  - Writes append-only ledger entries
  - Guarantees restart-safe persistence

### Layer 2 — The Body (Reference Client)
- **Tech:** Flutter (Desktop)
- **Role:** Visualization and control surface
- **Responsibilities:**
  - Displays ledger state in real time
  - Submits user intents to the Brain
- **Important:** Holds no economic authority

### Layer 3 — The Vault (Persistence)
- **Tech:** SQLite (local file)
- **Role:** Sovereign storage layer
- **Properties:**
  - Append-only transaction history
  - Survives restarts and crashes
  - Fully user-owned

---

## 4. Economic Primitive — The 60-30-10 Rule

At the core of Nexus is a **hard-coded, deterministic economic rule**.

Every transaction processed by the engine is split as follows:

- **60% — Creator Allocation**
- **30% — User / Network Pool**
- **10% — Protocol Fee**

This is **not** a policy layer.  
It is an **invariant of the execution engine**.

---

## 5. Cryptographic Anchoring Feasibility

Phase 1.1 includes a standalone feasibility script:

```
merkle_anchor.py
```

This validates that Nexus can anchor local economic state to TON **without exposing raw data**, enabling future on-chain verification without redesigning the core system.

---

## 6. Project Status

Nexus is currently in the **Feasibility & Infrastructure Research** phase.

This repository represents the **canonical Phase 1.1 reference implementation**.

---

## 🔮 Phase 1.2: TON Connect Integration (Roadmap — Non-Binding)

> **Note:** The following section describes exploratory, non-binding research goals.
> It is not part of the Phase 1.1 deliverable scope and is subject to change based on feasibility and review.

**Planned Architecture:**
1.  **Client-Side Signing:** The Flutter client will integrate the TON Connect SDK to request transaction signatures directly from the user's non-custodial wallet (e.g., Tonkeeper).
2.  **Merkle Anchoring:** The "Brain" (FastAPI) will batch local transaction splits and generate a Merkle Root.
3.  **On-Chain Verification:** The signed Merkle Root is published to the TON Blockchain as a "Check-In" transaction, proving the state of the local ledger without revealing private data.

**Integration Scope:**
- Integration of TON Connect 2.0 manifest and authentication flow.
- Development of the `merkle-anchor` smart contract interface.
- Security auditing of the client-side signing process.

---

© 2026 Nexus Protocol  
Licensed under the Apache License, Version 2.0
