# 🛣️ Engineering Roadmap — Nexus Protocol (v1.3.1)

This document tracks the evolution of the **Nexus Universal Gateway**. The roadmap is strictly phased to ensure architectural correctness and "durability-first" stability before feature expansion.

> [!NOTE]
> **Roadmap Disclaimer:** This represents an engineering dependency plan. Later phases (specifically Phase 2.0+) are contingent on system correctness, security audits, and ecosystem grant availability.

**Current Status:** ```PHASE 1.3.1 — UNIVERSAL HARDENING (ACTIVE)```  
**Primary Focus:** Adapter Interface Standardization & Fail-Closed Perimeter

---

## 📅 Roadmap Overview

```mermaid
timeline
    title Nexus Protocol Engineering Phases
    Phase 1.1 : Foundation : FastAPI Brain : SQLite Vault : 60-30-10 Economics
    Phase 1.2 : Gateway : Reverse Proxy : Tunneling (ngrok) : Unidirectional Pipeline
    Phase 1.3.1 (ACTIVE) : Universal Hardening : Adapter Interface : Fail-Closed Perimeter : 1M Stress Test Validated
    Phase 2.0 (NEXT) : Identity & Anchoring : peaq ID Integration : IoTeX ioID : Multi-Chain Merkle Roots
    Phase 3.0 : Mesh & Settlement : W3bstream Proofs : Peer Discovery : Optional On-Chain Settlement
```

---

## 🔵 Phase 1.3.1 — Universal Hardening (Active)
**Core Question:** *Is the architecture modular enough to support any chain safely?*

* [x] **Universal Adapter Interface:** Creation of ```nexus/adapters/base.py``` abstract class for cross-chain modularity.
* [x] **Reference Adapter (TON):** Validation of the interface using a lightweight, message-oriented chain.
* [x] **Performance Benchmark:** 1-Million Transaction stress test validated (~50–60 TPS, durability-first baseline).
* [x] **Sentry Guard (Staged):** Sentry module implemented and validated; currently staged for live path integration.
* [x] **Fail-Closed Perimeter:** ```multichain_guard``` enforces deterministic identity fallback and unauthorized rejection.
* [ ] **Observability:** Structured rejection telemetry for Sentry events (local logging).
* [ ] **Adapter Specs:** Finalizing interface requirements for **peaq** and **IoTeX** (Phase 2 readiness).

---

## 🔮 Phase 2.0 — Identity & DePIN Readiness (Next)
**Core Question:** *Who owns the state, and can we verify hardware identity?*

* [ ] **peaq Integration:**
    * Implementation of **peaq ID** (Sr25519) verification in the Sentry.
    * Anchoring machine state roots to the peaq testnet.
* [ ] **IoTeX Integration:**
    * Support for **ioID** (Ed25519) signatures.
    * Preparation of data schemas for **W3bstream**.
* [ ] **Multi-Chain Merkle Anchoring:** Submitting local state roots to multiple chains simultaneously for cryptographic finality.

---

## 📊 Phase Summary Table

| Phase | Name | Core Question | Status |
| :--- | :--- | :--- | :--- |
| **1.1** | Foundation | Can it run locally? | ✅ **Closed** |
| **1.2** | Gateway | Is it consistent? | ✅ **Closed** |
| **1.3.1** | **Universal Hardening** | **Is it modular?** | 🔵 **Active** |
| **2.0** | **Identity** | **Who owns the data?** | 🔮 **Grant Target** |

---

© 2026 Nexus Protocol · Licensed under **Apache License 2.0**
