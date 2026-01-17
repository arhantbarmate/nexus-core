# ðŸ—ºï¸ Nexus Protocol â€” Engineering Roadmap

This document tracks the evolution of the Nexus Sovereign Node. The roadmap is strictly phased to ensure architectural correctness before feature expansion.

**Current Status:** `PHASE 1.2 â€” GATEWAY (LOCKED)`
**Primary Focus:** Environment Consistency & Documentation

---

## ðŸ“… Roadmap Overview

```text
PHASE 1.1: FOUNDATION (Done)      PHASE 1.2: GATEWAY (Active)      PHASE 1.3: HARDENING (Next)
+--------------------------+      +--------------------------+      +--------------------------+
| â€¢ FastAPI Brain          |      | â€¢ Gateway Pattern        |      | â€¢ Observability          |
| â€¢ SQLite Vault (WAL)     | ---> | â€¢ Reverse Proxy          | ---> | â€¢ Failure Mode Tests     |
| â€¢ 60-30-10 Logic         |      | â€¢ Stateless Body         |      | â€¢ Operator Ergonomics    |
+--------------------------+      +--------------------------+      +--------------------------+
       (Localhost)                     (Bridge / WebApp)                  (Production Ready)
```

---

## âœ… Phase 0 â€” Concept & Feasibility (Closed)
**Core Question:** *Is this idea worth building?*

* [x] **Economic Thesis:** Defined 60-30-10 split.
* [x] **Local-First Verification:** Proved `merkle_anchor.py` feasibility.
* [x] **Prototypes:** Throwaway scripts to validate deterministic math.

---

## âœ… Phase 1.1 â€” Sovereign Foundation (Closed)
**Core Question:** *Can this run locally and deterministically?*

* [x] **Brain:** FastAPI backend execution engine.
* [x] **Vault:** SQLite database with WAL mode persistence.
* [x] **Economics:** Deterministic 60-30-10 execution.
* [x] **Local Execution:** Functional on localhost.

*Status: Closed. The foundation is solid.*

---

## ðŸŸ¢ Phase 1.2 â€” Gateway Architecture (LOCKED)
**Core Question:** *Can a sovereign node behave identically across environments?*

### Core Architecture
* [x] **Gateway Pattern:** Brain (Port 8000) is the sole public interface.
* [x] **Reverse Proxy:** Brain routes to Body (Port 8080) internally.
* [x] **Unified Namespace:** `NEXUS_DEV_001` enforced for consistency.

### Bridge & Security
* [x] **Ngrok Support:** Validated tunneling for mobile/Telegram access.
* [x] **Isolation:** Body is stateless; only Brain writes to Vault.
* [x] **Recursion Guard:** Header-based protection against proxy loops.

*Status: Active & Released. This is the current public baseline.*

---

## â³ Phase 1.3 â€” Hardening & Readiness (Planned)
**Core Question:** *Is this architecture safe enough to build cryptography on?*

Before adding identity, we must ensure the system handles failure gracefully.

* [ ] **Observability:** Structured JSON logs and `/health` endpoints.
* [ ] **Vault Integrity:** Startup checks for database corruption.
* [ ] **Stress Testing:** Determinism validation under high load.
* [ ] **Degraded States:** Clear UI feedback when the Brain is unreachable.

*Status: Not Started. Recommended before Phase 2.0.*

---

## ðŸ”® Phase 2.0 â€” Identity & Cryptography (Future)
**Core Question:** *Who is allowed to execute, and can we prove it?*

* [ ] **Ed25519 Identity:** Persistent node/user keypairs.
* [ ] **Client Signing:** Body signs requests; Brain verifies signatures.
* [ ] **Verified Telegram Auth:** Cryptographic validation of `initData`.
* [ ] **Multi-User Schema:** Ledger support for multiple `user_id`s.

*Status: Future. Introduces cryptographic trust.*

---

## ðŸ”® Phase 3.0 â€” Mesh & Settlement (Future)
**Core Question:** *How do sovereign nodes coordinate globally?*

* [ ] **Peer Discovery:** mDNS / DHT-based node finding.
* [ ] **Gossip Protocol:** Encrypted event propagation.
* [ ] **Settlement Anchoring:** Merkle root commitments to TON.

---

## ðŸ”® Phase 4.0 â€” Ecosystem (Future)
**Core Question:** *What can be built on top of Nexus?*

* [ ] **Plugin System:** Third-party economic modules.
* [ ] **Creator Tools:** SDKs for building sovereign apps.
* [ ] **Governance:** Deterministic protocol updates.

---

## ðŸ“Š Phase Summary Table

| Phase | Name | Core Question | Status |
| :--- | :--- | :--- | :--- |
| **0** | Concept | Is it worth building? | âœ… **Closed** |
| **1.1** | Foundation | Can it run locally? | âœ… **Closed** |
| **1.2** | **Gateway** | **Is it consistent?** | ðŸŸ¢ **Locked** |
| **1.3** | Hardening | Is it robust? | â³ **Next** |
| **2.0** | Identity | Who can execute? | ðŸ”® **Future** |
| **3.0** | Mesh | How to coordinate? | ðŸ”® **Future** |

---

## ðŸ›‘ Feature Deferral Log
*To preserve correctness, the following are explicitly deferred until Phase 2.0+:*

1.  **JWT / Session Tokens** (Phase 2.0)
2.  **Client-Side Private Keys** (Phase 2.0)
3.  **Peer-to-Peer Networking** (Phase 3.0)
4.  **On-Chain Settlement** (Phase 3.0)

---

Â© 2026 Nexus Protocol
