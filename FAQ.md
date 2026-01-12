# Nexus Protocol — Frequently Asked Questions

This document addresses common architectural and design questions about Nexus Protocol Phase 1.1.

---

## Q: Why does Nexus use SQLite instead of a full database?
**A:** SQLite aligns with Nexus’s *local-first sovereign node* philosophy. It requires no external services, runs entirely on the user’s device, and provides restart-proof persistence without operational overhead. This allows any user to operate a Nexus node without managing infrastructure.

---

## Q: Is the 60-30-10 economic split hardcoded?
**A:** Yes, in Phase 1.1 the split is intentionally hardcoded to ensure deterministic, auditable behavior. Future phases will explore protocol-governed parameter updates once on-chain anchoring and verification are established.

---

## Q: Why not execute the split logic directly on-chain?
**A:** High-frequency micro-transactions are expensive and inefficient to execute entirely on-chain. Nexus executes economic logic locally at zero gas cost, then anchors cryptographic commitments (Merkle roots) to the blockchain, preserving trust while reducing network load.

---

## Q: How is data persistence handled?
**A:** All economic events are written to a local SQLite database (`nexus_vault.db`). Data survives application restarts and system shutdowns without requiring cloud storage.

---

## Q: How do I reset the local ledger?
**A:** Delete the `nexus_vault.db` file located in the backend directory. A fresh vault will be created automatically on the next transaction.

---

## Q: Does Nexus currently require a blockchain wallet?
**A:** No. Phase 1.1 operates without wallet integration to validate local-first execution. Phase 1.2 introduces TON Connect for verified node identity and on-chain anchoring.

---

## Q: Is Nexus a social media platform?
**A:** No. Nexus is **infrastructure**. Social or creator-economy applications are *reference use cases* built on top of the protocol, not the protocol itself.

---

## Q: Is Nexus production-ready?
**A:** Phase 1.1 is a feasibility prototype focused on correctness, persistence, and auditability. Production hardening, scaling, and integration are planned for subsequent phases.

---
© 2026 Nexus Protocol