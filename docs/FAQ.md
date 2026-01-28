# ❓ Technical FAQ — Nexus Protocol
**Coreframe Systems Lab | Version 1.4.0**

This document addresses the architectural rationale, infrastructure constraints, and economic logic behind the Nexus Sovereign Gateway.

---

## 🌐 Infrastructure & Connectivity

### Q: Does Nexus require a blockchain to function?
**A:** No. Phase 1.4.0 is a standalone **Sovereign Node**. It operates with full autonomy without external blockchain dependencies. External layers (peaq, IoTeX) are treated as optional **Anchoring Adapters** for identity and global settlement; they do not dictate the local execution speed or ledger correctness of the Brain.

### Q: How does the Gateway handle "interstitial" or browser warnings?
**A:** To maintain a **Zero-Cost Sovereign Stack**, Nexus utilizes header-based bypasses in development environments. The Brain is configured to append ingress-specific bypass headers (e.g., ```ngrok-skip-browser-warning```, Cloudflare, or Nginx equivalents) to outbound responses. This ensures a clean, headless JSON/HTML stream for automated handshakes and Telegram Mini App integration.

### Q: Why SQLite instead of a distributed database?
**A:** Local-first sovereignty and high performance on edge hardware. 
* **WAL Mode:** Write-Ahead Logging manages high-density concurrent writes without blocking.
* **Integrity:** Validated under a **1-Million Transaction stress test** with 0.00% data corruption.
* **Portability:** Keeping the ledger in a single-file sovereign vault ensures the operator maintains absolute state ownership.

---

## 💰 Economic & State Logic

### Q: Is the 60/30/10 split hardcoded?
**A:** Yes. In the current release, the split logic is enforced as a **Deterministic Invariant** at the Brain level. This prevents UI-level tampering and ensures economic integrity. While future phases will allow parameterized governance, any future parameterization occurs at the governance layer and does not alter the Brain’s deterministic execution guarantees.



### Q: What happens if a transaction fails the Sentry Guard?
**A:** The system operates on a **Zero Trust** model. If a request fails to resolve identity context (e.g., invalid ```initData```) or environmental signatures, the Sentry rejects it at the perimeter. No logic is executed, and no state is committed to the Vault.

---

## 🛰️ Identity & Adapters

### Q: Why frame the UI as an "Execution Surface"?
**A:** To maintain **Chain-Agnosticism**. The UI (The Body) does not own the state; it merely renders the reactive state of the Sovereign Brain. This separation ensures that the Protocol remains compatible with any future identity system (ioID, Sr25519, etc.) without requiring a rebuild of the core execution engine.

---

## 📋 Comprehensive Question Summary
1. **Blockchain Dependency:** Standalone sovereignty vs. optional anchoring.
2. **Ingress Handling:** Bypassing interstitials via ingress-agnostic headers.
3. **Storage Logic:** Performance and portability of SQLite/WAL.
4. **Economic Split:** The deterministic 60/30/10 invariant.
5. **Security Failure:** Zero Trust and Fail-Closed Sentry Guard logic.
6. **Architectural Framing:** The "Body" as a reactive execution surface.

---
© 2026 Coreframe Systems · Technical FAQ v1.4.0  
*This document addresses architectural rationale for Phase 1.4.0 nodes.*
