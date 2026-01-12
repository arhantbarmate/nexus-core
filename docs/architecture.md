# Nexus Protocol — Technical Architecture (Phase 1.1)

This document describes the technical architecture of Nexus Protocol Phase 1.1, with a focus on its **local-first execution model**.

---

## 1. Architectural Philosophy

Nexus Protocol is designed around **sovereign local nodes**.

Rather than assuming continuous connectivity or centralized services, Nexus prioritizes:
- **Local Execution:** Logic runs on the user's machine, not a cloud server.
- **Persistent Local State:** Data lives in a local vault, not a remote database.
- **Graceful Degradation:** The system functions fully even during network instability.

Global blockchains (like TON) are used as **anchors of truth**, not as real-time execution engines.

---

## 2. High-Level Architecture

The system follows a strict separation of concerns between the Interface (Body), Logic (Brain), and Storage (Vault).

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
    (Real-time State)              (Surgical Validation)
                                            |
                                            | (SQL)
                                            v
                                       [  VAULT  ]
                                    (SQLite DB File)
                                  (Immutable History)
3. Component Breakdown
3.1 The Brain — Execution Engine
Technology: FastAPI (Python)

Role: The authoritative source of economic truth.

Responsibilities:

Enforces the 60-30-10 economic logic deterministically.

Validates inputs (e.g., preventing negative values or double-spends).

Manages connections to the local Vault.

Exposes a strictly typed REST API.

3.2 The Vault — Persistent Ledger
Technology: SQLite (Local File)

Role: The sovereign storage layer.

Responsibilities:

Stores every economic event as an immutable record.

Preserves state across application restarts and system crashes.

Enables local auditability and transaction replay.

Why SQLite? It eliminates external infrastructure dependencies, reduces operational complexity, and ensures the user physically owns their data file.

3.3 The Body — Client Interface
Technology: Flutter (Desktop)

Role: The visualization and control layer.

Responsibilities:

Visualizes the ledger state (wallet balances, transaction history).

Sends user intents (actions) to the Brain.

Polling mechanism reflects backend truth in real-time.

Note: The Body does not execute economic logic. It only displays what the Brain has validated.

4. Local-First as a Feature
Local-first architecture provides:

Sovereign Data Ownership: The user holds the database file.

Zero-Gas Execution: High-frequency micro-transactions (like 60-30-10 splits) happen locally without network fees.

Offline Operation: The node functions perfectly without internet access; synchronization can happen opportunistically later.

Reduced Congestion: Only finalized "anchors" need to be sent to the blockchain, not every micro-event.

5. Future Anchoring (Phase 1.2)
In the upcoming Phase 1.2, the local ledger state will be:

Hashed into Merkle Trees.

Anchored to the TON Blockchain.

Verifiable via TON Connect 2.0 identity.

This preserves privacy (users don't publish raw data) while enabling global trust (users publish cryptographic proofs of their state).

© 2026 Nexus Protocol