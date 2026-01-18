# 🗺️ Nexus Protocol — Engineering Roadmap

This document tracks the evolution of the Nexus Sovereign Node. The roadmap is strictly phased to ensure architectural correctness before feature expansion.

**Current Status:** `PHASE 1.3 — HARDENING (ACTIVE)`  
**Primary Focus:** Perimeter Security & Multichain Readiness

---

## 📅 Roadmap Overview

```text
PHASE 1.2: GATEWAY (Done)      PHASE 1.3: HARDENING (Active)     PHASE 2.0: IDENTITY (Next)
+--------------------------+      +--------------------------+      +--------------------------+
| • Gateway Pattern        |      | • Sentry Guard (HMAC)    |      | • IoTeX ioID Integration |
| • Reverse Proxy          | ---> | • Multichain Staging     | ---> | • Client-Side Signing    |
| • Unified Namespace      |      | • Fail-Closed Logic      |      | • TON / IoTeX Anchoring  |
+--------------------------+      +--------------------------+      +--------------------------+
      (Consistency)                      (Perimeter)                      (Multichain Identity)
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
**Core Question:** *Is this architecture safe enough to process multichain intents?*

* [x] **Sentry Guard:** Implementation of `sentry.py` for signature validation.
* [x] **Request Legitimacy:** Validating Telegram `initData` via HMAC-SHA256.
* [x] **v1.3.1 Multichain Staging:** Defensive framing for TON/IoTeX integration.
* [x] **Fail-Closed Security:** Unauthorized requests are rejected at the perimeter.
* [ ] **Observability:** Structured JSON logs for Sentry rejection events (In Progress).
* [ ] **Replay Awareness:** Preliminary logic for timestamp/freshness checks (Planned).

---

## 🔮 Phase 2.0 — Identity & DePIN Readiness (Next)
**Core Question:** *Who owns the state, and can we verify hardware identity?*

* [ ] **IoTeX ioID Integration:** Using IoTeX Decentralized Identity (DID) to verify physical gateway hardware.
* [ ] **Ed25519 Identity:** Persistent node/user keypairs for sovereign ownership.
* [ ] **Client Signing:** Body signs requests; Brain verifies signatures.
* [ ] **Network Anchoring:** Committing local Merkle roots to the **TON** and **IoTeX** blockchains for global auditability.

---

## 🔮 Phase 3.0 — Mesh & Settlement (Future)
* [ ] **W3bstream Integration:** Porting Sentry logs to IoTeX W3bstream for off-chain proofs.
* [ ] **Peer Discovery:** DHT-based node finding.
* [ ] **On-Chain Settlement:** Automated claim logic via TON/IoTeX smart contracts.

---

## 📊 Phase Summary Table

| Phase | Name | Core Question | Status |
| :--- | :--- | :--- | :--- |
| **1.1** | Foundation | Can it run locally? | ✅ **Closed** |
| **1.2** | Gateway | Is it consistent? | ✅ **Closed** |
| **1.3** | **Hardening** | **Is it secure?** | 🔵 **Active** |
| **2.0** | **Identity** | **Who owns the data?** | 🔮 **Grant Target** |
| **3.0** | Mesh | How to coordinate? | 🔮 **Future** |

---

© 2026 Nexus Protocol