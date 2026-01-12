# NEXUS PROTOCOL

> Local-First Economic Infrastructure for Resilient Communication

**STATUS:** Phase 1.1 Feasibility Prototype (Live)  
**LICENSE:** Apache License 2.0  
**FOCUS:** Offline-First Architecture, Deterministic Value Allocation, Local Identity Foundations

---

## 📖 DOCUMENTATION
- [Installation Guide](INSTALL.md) — Get up and running in 5 minutes.
- [Architecture Overview](docs/architecture.md) — Local-first execution and vault design.
- [Economic Model](docs/economic-model.md) — Rationale behind the 60-30-10 split.
- [FAQ](FAQ.md) — Common questions about local-first design.

---

## 1. OVERVIEW
Nexus Protocol is a research-driven infrastructure project exploring how user devices can operate as sovereign economic nodes. It focuses on **Resilience, Ownership, and Graceful Degradation**, enabling value coordination to continue even during network instability or partial connectivity loss.

### The Problem: Infrastructure Fragility
Modern applications break down during outages or censorship because they rely on centralized custodians. Nexus explores whether local-first execution can reduce these dependencies while remaining compatible with global state anchors like the **TON Blockchain**.

---

## 2. SYSTEM ARCHITECTURE
Nexus is structured as a layered protocol stack designed for opportunistic synchronization.

```text
NEXUS PROTOCOL — PHASE 1.1 SYSTEM TOPOLOGY

    [ BODY ] <---------- (REST API) ----------> [ BRAIN ]
 (Flutter UI)                                (FastAPI Engine)
      |                                            |
      |                                            |
      V                                            V
 [ Dashboard ]                               [ 60-30-10 Logic ]
 [ Real-time ]                               [ State Hashing  ]
 [ Visualization ]                                 |
                                                   |
                                                   V
                                              [  VAULT  ]
                                            (SQLite DB File)
                                            (Local Persistence)
Layer Breakdown
Layer 1: The Brain (Execution Engine)

Tech: FastAPI (Python) + SQLite (sqlite3)

Function: Enforces deterministic 60-30-10 logic with strict validation and persistence.

Layer 2: The Body (Interface)

Tech: Flutter (Dart)

Function: Cross-platform dashboard reflecting the local ledger in real time.

Layer 3: The Vault (Planned)

Tech: TON Blockchain

Function: Global anchor for settlement and identity recovery.

System Components
Orchestration: Custom .bat script managing service startup and environment synchronization.

Communication: RESTful API layer with strict type validation to prevent ledger corruption.

3. ECONOMIC MODEL (THE "60-30-10" RULE)
Nexus implements a hardened, deterministic split logic. For every simulated unit entering the system, the protocol enforces:

60% — Creator Allocation (Primary content producer)

30% — User Pool (Ecosystem incentives)

10% — Network Fee (Protocol sustainability)

4. PHASE 1.1 ACHIEVEMENTS (FEASIBILITY)
✅ Persistent Ledger: Restart-proof SQLite-backed local vault.

✅ Singleton Source-of-Truth: Global ledger integrity via ID-locked records.

✅ Transactional Auditing: Real-time history with ISO 8601 timestamps.

✅ Surgical Validation: Prevention of invalid or negative inputs.

🧪 TECHNICAL FEASIBILITY
Phase 1.1 validates the technical foundations required for blockchain anchoring:

Deterministic Execution: All 60-30-10 splits enforced server-side.

Persistent State: Ledger survives full process restarts.

Cryptographic Anchoring (Validated): Standalone feasibility script (merkle_anchor.py) generates a deterministic Merkle Root directly from live SQLite data.

Identity Readiness: TON Connect manifest published and ready for wallet-based node ownership verification.

These results confirm Nexus can transition from local execution to TON-anchored global verification without redesigning the core system.

5. 🚀 HOW TO RUN
Ensure Python 3.10+ and Flutter (Stable) are installed.

Automated Launch (Windows)
Double-click start_nexus.bat

Manual Launch
Backend:

Bash

cd backend && uvicorn main:app --reload
Client:

Bash

cd client && flutter run -d windows
6. 🔮 ROADMAP
Phase 1.2: TON Anchoring via Merkle Roots & TON Connect Identity

Phase 1.3: Performance Benchmarking & External Audit (10k+ node simulation)

Phase 2.0: Opportunistic Mesh Synchronization & Decentralized Settlement

7. PROJECT STATUS & GRANT INTENT
Nexus is currently in the Feasibility & Infrastructure Research phase.

This prototype demonstrates local-first execution with client reflection, forming the foundation for TON-anchored global verification.

© 2026 Nexus Protocol. Licensed under Apache 2.0.