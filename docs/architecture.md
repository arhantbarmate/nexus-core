# Nexus Protocol — Technical Architecture (Phase 1.1)

This document describes the hardened technical architecture of Nexus Protocol Phase 1.1, with a focus on its **local-first execution model** and **sovereign observability**.

---

## 1. Architectural Philosophy
Nexus Protocol is designed around **sovereign local nodes**. Rather than assuming continuous connectivity, Nexus prioritizes:
- **Local Execution:** Economic logic runs on the user's machine.
- **Persistent Local State:** Data lives in a local vault, not a remote database.
- **Graceful Degradation:** The system functions fully even during network instability.
- **Observability Isolation:** Analytics are non-blocking and decoupled from the execution engine.

Global blockchains (like TON) are used as **anchors of truth**, not as real-time execution engines.

---

## 2. High-Level Architecture
The system follows a strict separation of concerns between the Interface (**Body**), Logic (**Brain**), and Storage (**Vault**).

```text
       [ BODY ]                         [ BRAIN ]
    (Flutter Client)                 (FastAPI Engine)
           |                                |
           |          (REST API)            |
           +------------------------------->|
           |     JSON Payload (Action)      |
           |                                |
           |                                v
     [ Visualization ]               [ 60-30-10 Logic ]
    (Real-time State)              (Deterministic Rounding)
           ^                                |
           |                                | (SQL / WAL Mode)
           |                                v
    [ HEARTBEAT ]                    [   VAULT   ]
    (Silent Post)                    (SQLite DB File)
```

---

## 3. Component Breakdown

### 3.1 The Brain — Execution Engine (FastAPI)
**Role:** The authoritative source of economic truth.
- **Deterministic 60-30-10 Split:** Enforces economic logic with **2-decimal precision rounding** (`round(amount, 2)`) to prevent floating-point drift in the ledger.
- **Background Observability:** Uses `fastapi.BackgroundTasks` to signal external telemetry (TON Builders). This ensures that external API failures **never** block local transaction commits.
- **Input Validation:** Strictly enforces 2-decimal precision and rejects **invalid or non-conforming inputs** (e.g., negative values) at the API gateway.

### 3.2 The Vault — Persistent Ledger (SQLite)
**Role:** The sovereign storage layer.
- **Database Schema:** Phase 1.1 utilizes a **single append-only `transactions` table**. Aggregated ledger values are computed deterministically at query time using SQL aggregation functions, eliminating redundant state tables and ensuring restart-safe correctness.
- **WAL Mode Persistence:** Implements **Write-Ahead Logging** to support high-concurrency read/write operations between the Brain and Body.

### 3.3 The Body — Client Interface (Flutter)
**Role:** The visualization and control layer.
- **Cross-Platform Sovereignty:** Uses platform-aware JS stubs to ensure the app runs natively on Desktop while remaining compatible with the Telegram Mini App (TMA) ecosystem.
- **Real-time Liveness:** Polls local `/health` and `/ledger` endpoints to provide a visual "Heartbeat" of the Brain's status.

---

## 4. Local-First Features
- **Sovereign Data Ownership:** The user holds the physical `.db` file, ensuring total data ownership.
- **Zero-Gas Execution:** High-frequency micro-transactions happen locally without network fees.

---

## 5. Future Anchoring (Phase 1.2 Research)
> **Note:** The following mechanisms are not present in Phase 1.1 and are described here strictly as forward-looking design.

In Phase 1.2, the local ledger state will be hashed into Merkle Trees and anchored to the TON Blockchain. This preserves privacy (raw data stays local) while providing global cryptographic proof of state.

---

© 2026 Nexus Protocol