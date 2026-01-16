# Nexus Protocol — Frequently Asked Questions (Phase 1.2)

This document answers common architectural, economic, and operational questions about the **Nexus Protocol Phase 1.2 Gateway Node**.

---

## 🏛️ Architecture & Design

### Q: Why does Nexus use SQLite instead of PostgreSQL or MongoDB?
**A:** SQLite aligns with the **Local-First Sovereign Node** philosophy.
It:
* Requires no external services.
* Runs entirely on the local device.
* Provides ACID guarantees with minimal operational overhead.
* Enables restart-proof persistence without server management.

This makes it ideal for Phase 1.2, where correctness and sovereignty are prioritized over horizontal scale.

**Conceptual Comparison:**
```text
  [ TRADITIONAL CLOUD APP ]          [ NEXUS SOVEREIGN NODE ]
  User -> Cloud Server -> DB         User -> Local Brain -> Local File
     (Data owned by provider)          (Data owned by operator)
```

### Q: Why not execute the economic logic directly on-chain?
**A:** High-frequency micro-transactions are too slow and costly for real-time on-chain execution.
In Phase 1.2:
* All economic logic executes **locally** at zero gas cost.
* Latency is near-instant.
* The system remains usable without external dependencies.

Future phases will introduce cryptographic anchoring (e.g., Merkle roots) to external chains to combine local speed with global verifiability.

---

## 💰 Economics (60-30-10)

### Q: Is the 60-30-10 economic split hardcoded?
**A:** **Yes.**
In Phase 1.2, the split is hardcoded and non-configurable to ensure:
* Deterministic execution.
* Easy auditing.
* Elimination of governance complexity during validation.

Governance and parameterization are intentionally deferred.

**Economic Flow:**
```text
      [ INPUT: 100 ]
            |
            v
   +------------------+
   |  BRAIN ENGINE    |
   |  (Deterministic) |
   +--------+---------+
            |
    +-------+-------+
    |       |       |
  60.00   30.00   10.00
(Creator) (Pool)  (Fee)
```

### Q: How does Nexus ensure calculation accuracy?
**A:** The Brain uses **explicit deterministic rounding** to two decimal places.
This avoids floating-point drift and guarantees:
* The sum of all outputs always equals exactly the input.
* Results are repeatable across executions.
* Ledger entries are audit-safe.

---

## 💾 Persistence & Data

### Q: How is data persistence handled?
**A:** Nexus uses SQLite in **WAL (Write-Ahead Logging) mode**.
WAL enables:
* Concurrent reads and writes.
* Non-blocking UI updates.
* Crash-safe commits.

**WAL Conceptual Flow:**
```text
[ BRAIN (Writer) ]  --->  [ nexus_vault.db-wal ]
                                   |
                               (Checkpoint)
                                   v
[ BODY (Reader) ]   <---  [ nexus_vault.db ]
```

### Q: How do I reset the local ledger for testing?
**A:**
1. Stop the Brain.
2. Delete `backend/nexus_vault.db`.
3. Restart the Brain.

A fresh, empty vault will be automatically initialized.

### Q: Does Phase 1.2 require a TON wallet or blockchain connection?
**A:** **No.**
Phase 1.2 intentionally avoids:
* Wallets
* Keys
* Signatures
* On-chain execution

Identity integration and anchoring are planned for **Phase 2.0**.

---

## 🔍 Operational Status & Troubleshooting

### Q: Is Nexus production-ready?
**A:** **No.**
Phase 1.2 is a feasibility and architecture validation phase.
It is stable for development and auditing but **not suitable for real-value deployment**.

### Q: I see a red indicator in the UI. What does this mean?
**A:** The Body cannot reach the Brain.
Check the following:
* Brain is running on **port 8000**.
* Body is running on **port 8080**.
* You are accessing the app via `http://localhost:8000`, NOT `localhost:8080`.

---

## 📌 Final Notes
Phase 1.2 prioritizes:
1. **Determinism**
2. **Local sovereignty**
3. **Architectural correctness**

Security and cryptographic guarantees are introduced only **after** correctness is proven.

---

© 2026 Nexus Protocol