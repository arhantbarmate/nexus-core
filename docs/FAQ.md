# ❓ Technical FAQ — Nexus Protocol (v1.3.1)

This document addresses the architectural rationale and infrastructure choices behind the Nexus Sovereign Gateway.

---

## 🌐 Infrastructure & Connectivity

### Q: Does Nexus require a blockchain to function?
**A:** No. Phase 1.3.1 is fully operational as a standalone **Sovereign Node** without any blockchain dependency. External chains (peaq, IoTeX, TON) are utilized only for optional anchoring and cross-chain identity in later phases; they do not affect the local execution speed or ledger correctness of the Brain.

### Q: How does the Gateway bypass the Ngrok browser warning?
**A:** To maintain a **$0-cost Sovereign Stack**, we utilize a header-based bypass. The Sovereign Brain is configured to append the ```ngrok-skip-browser-warning``` header to outbound responses. This ensures that the Flutter "Body" (UI) receives a clean JSON/HTML stream, allowing for seamless headless handshakes during development.

### Q: Why use SQLite instead of a distributed database?
**A:** Local-first sovereignty and high performance on edge hardware. 
* **Write-Ahead Logging (WAL):** Utilized to manage high-density concurrent writes.
* **Scale Verification:** Successfully validated under a **1-Million Transaction stress test** with 0% data corruption and stable performance (~50-60 TPS baseline on commodity hardware).
* **Sovereignty:** Keeping the ledger local ensures the operator maintains absolute state ownership before any roots are committed to an external layer.

---

## 💰 Economic & State Logic

### Q: Is the 60/30/10 split hardcoded?
**A:** In Phase 1.3.1, the split logic is enforced at the Brain level to ensure **Economic Determinism**. Hardcoding the logic in the backend prevents UI-level tampering. The architecture is modular; future governance adapters (Phase 2.0) will be able to parameterize these values while maintaining local integrity.

### Q: What happens if a transaction fails the Sentry Guard?
**A:** The system follows **Fail-Closed** logic. Requests that fail to resolve identity context or environmental signatures are issued a rejection response at the edge. No state changes are committed to the Sovereign Vault until the resolution is successful.

---

## 🛰️ Identity & Adapters

### Q: Why frame the UI as an "Execution Surface"?
**A:** To maintain **Chain-Agnosticism**. The UI (The Body) does not own the state; it merely renders the reactive state of the Sovereign Brain. This separation ensures Nexus remains compatible with future machine-IDs (ioID) or DePIN identity systems without altering the core execution engine.

---

© 2026 Nexus Protocol · Technical FAQ v1.3.1
