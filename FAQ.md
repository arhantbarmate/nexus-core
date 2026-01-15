# Nexus Protocol — Frequently Asked Questions

This document addresses common architectural and design questions about Nexus Protocol Phase 1.1.

---

## Q: Why does Nexus use SQLite instead of a full database (PostgreSQL/MongoDB)?
**A:** SQLite aligns with the **local-first sovereign node** philosophy. It requires zero external services, runs entirely on the user’s device, and provides restart-proof persistence without the operational overhead of a database server. This ensures the user physically owns their data file (`nexus_vault.db`).

---

## Q: Is the 60-30-10 economic split hardcoded?
**A:** Yes. In Phase 1.1, the split is intentionally hardcoded to ensure **deterministic, auditable behavior**. By fixing these parameters, we can validate the correctness of the execution engine and the persistence layer before introducing governance or adaptive parameters in later phases.

---

## Q: Why not execute the split logic directly on-chain?
**A:** High-frequency micro-transactions are often too slow and expensive for real-time on-chain execution. Nexus executes economic logic locally at **zero gas cost**, allowing for high performance. Future phases will anchor cryptographic commitments (Merkle roots) to the TON blockchain to provide global trust without the network overhead.

---

## Q: How does Nexus ensure calculation accuracy?
**A:** The "Brain" (FastAPI engine) uses **deterministic rounding to 2-decimal precision**. This prevents floating-point drift and ensures that the sum of the 60-30-10 split always equals 100% of the input, maintaining ledger integrity across millions of local transactions.

---

## Q: How is data persistence handled?
**A:** All economic events are written to a local SQLite vault using **Write-Ahead Logging (WAL) mode**. This ensures that data survives application restarts, system crashes, and power failures while allowing the Flutter "Body" to read state without blocking the "Brain."

---

## Q: How do I reset the local ledger for testing?
**A:** Simply delete the `nexus_vault.db` file located in the backend directory. The system will automatically initialize a fresh, empty vault upon the next transaction or system restart.

---

## Q: Does Phase 1.1 require a TON wallet or TON Connect?
**A:** **No.** Phase 1.1 is designed to validate local-first execution in isolation. Identity integration via TON Connect and on-chain anchoring are research targets for **Phase 1.2**.

---

## Q: Is Nexus Protocol a social media platform?
**A:** No. Nexus is **economic infrastructure**. While the 60-30-10 model is inspired by creator-economy dynamics, the protocol is a foundational layer upon which various social, content, or P2P applications can be built.

---

## Q: Is Nexus production-ready?
**A:** Phase 1.1 is a **feasibility prototype** focused on technical correctness, persistence, and auditability. It is a research foundation intended for developers and auditors, with production hardening planned for subsequent phases.

---

© 2026 Nexus Protocol