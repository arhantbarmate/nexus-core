# 🏛️ Nexus Protocol — Frequently Asked Questions (v1.3.1)

This document provides a technical and strategic FAQ for the **Nexus Sovereign Node**. It addresses architectural, economic, and multichain integration questions for Phase 1.3.

---

## 🏛️ Architecture & Perimeter Security

### Q: What is the "Sentry" and why is it staged in v1.3.1?
**A:** The Sentry is a **Modular Verification Guard** that sits at the gateway boundary. Its role is to validate request integrity (via HMAC-SHA256) before the Economic Brain processes any state transitions. Runtime enforcement is currently **staged** to ensure environment stability during the multichain transition.

### Q: Why use HMAC instead of full Ed25519 signing right now?
**A:** HMAC-SHA256 provides a high-performance, low-latency "First Line of Defense" aligned with the Telegram Mini App security model. In Phase 2.0, we will introduce **Ed25519** and **ioID** for individual device identity, but the Sentry provides the prerequisite "Perimeter Hardening" to prevent unauthorized traffic from reaching the internal logic.

### Q: How does the architecture handle multichain requests?
**A:** Nexus utilizes a **Modular Gateway Pattern**. The Sentry is designed to handle different "Verification Gates." For example, a request from Telegram passes through the **TON-HMAC Gate**, while a request from a physical device will be designed to pass through the **IoTeX-ioID Gate** in Phase 2.0.

---

## 💰 Economics & State Machine

### Q: What is the purpose of the 60-30-10 Engine?
**A:** It is a **Deterministic State Transition Invariant**. Instead of speculative tokenomics, Nexus treats economics as "Code Invariants." This ensures that the local ledger remains in a consistent state, which is a prerequisite for future on-chain anchoring.

### Q: Does the 10% "Network Reserved" share represent a protocol fee?
**A:** Not in the traditional sense. It is an **internal accounting allocation** reserved for future costs of maintaining node integrity—specifically for **W3bstream proof workflows** (IoTeX) and **State-Root anchoring** (TON).

---

## 🔧 DePIN & IoTeX Alignment

### Q: How does Nexus fit into the IoTeX 2.0 "Modular DePIN" stack?
**A:** Nexus acts as a **Sovereign Edge Node**. By porting our Sentry to support **ioID**, we provide a "Local Verification Perimeter" that complements IoTeX’s off-chain compute. Our goal is to use Nexus to pre-validate device intents before they are sent to **W3bstream** for off-chain verifiable computation.

### Q: Can users tamper with the local Vault or modify balances?
**A:** The Vault is authoritative by design, but Nexus assumes a potentially hostile local environment. Any future global anchoring relies on deterministic recomputation and verification, not blind trust in local state. Phase 1.3 focuses on architectural correctness and auditability over malicious-owner enforcement.

---

## 🔍 Operational & Legal Status

### Q: Is there any live on-chain execution in Phase 1.3?
**A:** **No.** Phase 1.3 is strictly focused on **local-first hardening**. All blockchain references reflect architectural readiness and threat modeling. No tokens are issued, and no smart contracts are invoked in this phase.

### Q: Is Nexus a Bridge or an Oracle?
**A:** Neither. Nexus is a **Sovereign Gateway**. It does not move assets between chains; it manages local state transitions and prepares them for global auditability via anchoring.

> **Phase 1.3 Scope Summary:** Nexus v1.3.1 provides a hardened, local-first execution gateway with deterministic economics and staged multichain verification. It does not execute on-chain logic, issue tokens, bridge assets, or provide global consensus.

---

© 2026 Nexus Protocol · v1.3.1