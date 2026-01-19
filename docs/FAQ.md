# ❓ Frequently Asked Questions — Nexus Protocol

This document provides a technical and strategic FAQ for the **Nexus Sovereign Gateway**. It addresses architectural, economic, and multichain integration questions for Phase 1.3.1.

---

## 🏛️ Architecture & Perimeter Security

### Q: What is the "Sentry" and why is it mandatory?
**A:** The Sentry is a **Modular Verification Guard** that sits at the gateway boundary. Its role is to validate request integrity before the Economic Brain processes any state transitions. By making the Sentry mandatory, we ensure that the system follows a **Fail-Closed** security model—unauthorized traffic never touches the application logic.

### Q: Which Identity Standards does Nexus support?
**A:** Nexus is identity-agnostic. The Sentry allows you to "plug in" verification modules for your specific use case:
* **Social/App:** HMAC-SHA256 (e.g., Telegram Mini Apps).
* **Machine/DePIN:** Ed25519 (with support for additional schemes such as **Sr25519** for peaq or Solana).
* **Federated:** OIDC or DID-based resolvers.

---

## 💰 Economics & the Reference Policy

### Q: Why 60-30-10? Is it hardcoded?
**A:** The 60-30-10 split is a **Reference Policy** included in v1.3.1 to demonstrate deterministic ledger integrity. It acts as a "default setting" for testing.
* **60% (Participant):** Edge-node incentive.
* **30% (Ecosystem):** Reserve for identity/storage fees.
* **10% (Network):** Proof generation & anchoring costs.

**It is NOT hardcoded in the protocol core.** Developers can swap this logic module for custom models (e.g., Linear Bonding Curves, DAO-managed splits) via the Brain's policy interface.

### Q: Does the 10% "Network Reserved" share represent a fee?
**A:** It represents the **Cost of Truth**. In a DePIN network, this allocation covers:
* **peaq:** Storage and machine identity verification on the peaq layer.
* **IoTeX:** W3bstream proof generation.
* **TON:** State archiving and Jetton-compatible message forwarding.
It is an internal accounting allocation reserved for these future infrastructure costs.

---

## 🔌 Multichain & DePIN Integration

### Q: How does Nexus fit into ecosystems like peaq or IoTeX?
**A:** Nexus acts as a **Sovereign Gateway**.
* **For peaq:** It serves as a local "Logic Boundary" that verifies a machine's **peaq ID** signature locally before anchoring the data to the chain.
* **For IoTeX:** It pre-validates device intents before sending them to **W3bstream**, reducing on-chain noise and compute costs.
* **For TON/Solana:** It manages high-frequency user interactions off-chain, settling only the final state roots.

---

## 🔍 Operational & Legal Status

### Q: Is there any live on-chain execution in Phase 1.3.1?
**A:** **No.** Phase 1.3.1 is strictly focused on **local-first hardening**. All blockchain references (peaq, IoTeX, TON) reflect architectural interfaces and threat modeling. No tokens are issued, and no smart contracts are invoked in this phase.

### Q: Is Nexus a Bridge or an Oracle?
**A:** Neither. Nexus is a **Sovereign Gateway**. It does not move assets between chains; it manages local state transitions and prepares them for global auditability via the **Adapter Pattern**.

> **Phase 1.3.1 Scope Summary:** Nexus v1.3.1 provides a hardened, local-first execution gateway with deterministic economics and verified identity extraction. It does not execute on-chain logic, issue tokens, or provide global consensus.

---

© 2026 Nexus Protocol · v1.3.1
