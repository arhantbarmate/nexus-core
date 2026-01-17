# 🗺️ Nexus Protocol — Engineering Roadmap

This document tracks the evolution of the Nexus Sovereign Node. The roadmap is strictly phased to ensure architectural correctness before feature expansion.

**Current Status:** `PHASE 1.3 — HARDENING (ACTIVE)`
**Primary Focus:** Perimeter Security & Request Legitimacy

---

## 📅 Roadmap Overview

```text
PHASE 1.2: GATEWAY (Done)      PHASE 1.3: HARDENING (Active)    PHASE 2.0: IDENTITY (Next)
+--------------------------+      +--------------------------+      +--------------------------+
| • Gateway Pattern        |      | • Sentry Guard (HMAC)    |      | • Ed25519 Keypairs       |
| • Reverse Proxy          | ---> | • Request Legitimacy     | ---> | • Client-Side Signing    |
| • Unified Namespace      |      | • Fail-Closed Logic      |      | • TON Global Settlement  |
+--------------------------+      +--------------------------+      +--------------------------+
      (Consistency)                      (Perimeter)                      (Ownership)
```

---

## ✅ Phase 1.1 — Sovereign Foundation (Closed)
* [x] **Brain:** FastAPI backend execution engine.
* [x] **Vault:** SQLite database with WAL mode persistence.
* [x] **Economics:** Deterministic 60-30-10 execution.

---

## ✅ Phase 1.2 — Gateway Architecture (Closed)
* [x] **Gateway Pattern:** Brain (Port 8000) is the sole public interface.
* [x] **Reverse Proxy:** Brain routes to Body (Port 8080) internally.
* [x] **Ngrok Support:** Validated tunneling for mobile/Telegram access.

---

## 🔵 Phase 1.3 — Hardening & Perimeter (Active)
**Core Question:** *Is this architecture safe enough to process platform intents?*

* [x] **Sentry Guard:** Implementation of `sentry.py` for signature validation.
* [x] **Request Legitimacy:** Validating Telegram `initData` via HMAC-SHA256.
* [x] **Fail-Closed Security:** Unauthorized or malformed requests are rejected at the perimeter once Sentry enforcement is enabled.
* [x] **Refined Economics:** Economic splits framed as deterministic state transitions.
* [ ] **Observability:** Structured JSON logs for Sentry rejection events (In Progress).
* [ ] **Replay Awareness:** Preliminary logic for timestamp/freshness checks (Planned).

*Status: Active. This phase moves us from "Architectural Authority" to "Perimeter Security."*

---

## 🔮 Phase 2.0 — Identity & Cryptography (Future)
**Core Question:** *Who owns the state, and can we prove it on-chain?*

* [ ] **Ed25519 Identity:** Persistent node/user keypairs.
* [ ] **Client Signing:** Body signs requests; Brain verifies signatures.
* [ ] **Verified Personal Auth:** Moving beyond request legitimacy to individual user ownership.
* [ ] **TON Anchoring:** Committing local Merkle roots to the TON blockchain.

---

## 🔮 Phase 3.0 — Mesh & Settlement (Future)
* [ ] **Peer Discovery:** DHT-based node finding.
* [ ] **Gossip Protocol:** Encrypted event propagation between nodes.
* [ ] **On-Chain Settlement:** Automated claim logic via TON smart contracts.

---

## 📊 Phase Summary Table

| Phase | Name | Core Question | Status |
| :--- | :--- | :--- | :--- |
| **1.1** | Foundation | Can it run locally? | ✅ **Closed** |
| **1.2** | Gateway | Is it consistent? | ✅ **Closed** |
| **1.3** | **Hardening** | **Is it secure?** | 🔵 **Active** |
| **2.0** | Identity | Who owns the data? | 🔮 **Future** |
| **3.0** | Mesh | How to coordinate? | 🔮 **Future** |

---

## 🛑 Feature Deferral Log
*To preserve correctness, the following are explicitly deferred until Phase 2.0+:*

1.  **User-Level Private Keys** (Phase 2.0)
2.  **On-Chain Settlement** (Phase 3.0)
3.  **Governance DAO** (Phase 4.0)

---

© 2026 Nexus Protocol