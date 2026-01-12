# NEXUS PROTOCOL

> Local-First Economic Infrastructure for Resilient Communication

**STATUS:** Phase 1.1 Feasibility Prototype (Live)  
**LICENSE:** Apache License 2.0  
**FOCUS:** Offline-First Architecture, Deterministic Value Allocation, Local Identity Foundations

---

## 1. OVERVIEW
Nexus Protocol is a research-driven infrastructure project exploring how user devices can operate as sovereign economic nodes. It focuses on **Resilience, Ownership, and Graceful Degradation**, enabling value coordination to continue even during network instability or partial connectivity loss.

### The Problem: Infrastructure Fragility
Modern applications break down during outages or censorship because they rely on centralized custodians. Nexus explores whether local-first execution can reduce these dependencies while remaining compatible with global state anchors like the **TON Blockchain**.

---

## 2. SYSTEM ARCHITECTURE
Nexus is structured as a layered protocol stack designed for opportunistic synchronization.

* **LAYER 1: THE BRAIN (Execution Engine)**
    * *Tech:* FastAPI (Python) + SQLite (via sqlite3).
    * *Function:* A local server enforcing the **60-30-10 Logic** with surgical validation and SQLite-backed persistence.
* **LAYER 2: THE BODY (Interface)**
    * *Tech:* Flutter (Dart).
    * *Function:* A cross-platform dashboard providing a real-time reflection of the local ledger.
* **LAYER 3: THE VAULT (Planned)**
    * *Tech:* TON Blockchain.
    * *Function:* Global anchor for final settlement and identity recovery.
* **ORCHESTRATION:** Custom `.bat` orchestration script managing service dependencies and environment synchronization.
* **COMMUNICATION:** RESTful API layer with strict type-validation to prevent ledger corruption.

---

## 3. ECONOMIC MODEL (THE "60-30-10" RULE)
Nexus implements a hardened, deterministic split logic. For every simulated unit entering the system, the protocol enforces:

* **60% : CREATOR ALLOCATION** (Primary content producer)
* **30% : USER POOL** (Ecosystem incentives)
* **10% : NETWORK FEE** (Protocol sustainability)

---

## 4. PHASE 1.1 ACHIEVEMENTS (FEASIBILITY)
- [x] **Persistent Ledger:** Migrated from ephemeral memory to a restart-proof **SQLite-backed local vault**.
- [x] **Singleton Source-of-Truth:** Ensured global ledger integrity via ID-locked records.
- [x] **Transactional Auditing:** Real-time history tracking with ISO 8601 timestamps.
- [x] **Surgical Validation:** Prevention of invalid/negative amounts at the API layer.

---

## 5. 🚀 HOW TO RUN
1. Ensure Python 3.10+ and Flutter are installed.
2. **Automated Launch (Windows):** Double-click `start_nexus.bat` in the root folder.
3. **Manual Launch:**
    * **Backend:** `cd backend && uvicorn main:app --reload`
    * **Client:** `cd client && flutter run -d windows`

---

## 6. PROJECT STATUS & GRANT INTENT
Nexus is currently in the **Feasibility & Infrastructure Research** phase. This prototype successfully demonstrates **"Local-first execution with client reflection,"** a critical milestone for moving toward a decentralized TON-integrated mainnet.

**Roadmap Note:** Phase 1.2 will focus on TON anchoring, Merkle-tree state verification, and asynchronous settlement.

---
© 2026 Nexus Protocol. Licensed under Apache 2.0.