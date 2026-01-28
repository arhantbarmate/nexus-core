# 🏛️ Governance Framework — Nexus Protocol
**Coreframe Systems Lab | Version 1.4.0**

This document defines the decision-making framework of a Nexus Sovereign Node. In Phase 1.4.0, governance is explicitly operator-centric but rule-bound.

## 🎯 Governance Scope (Phase 1.4.0)
Nexus governance in Phase 1.4.0 governs operations, not economics.

| Domain | Governed By |
| :--- | :--- |
| Hardware & Deployment | Node Operator |
| Vault Ownership | Node Operator |
| Ingress Configuration | Node Operator |
| Execution Logic | Protocol (Hardcoded) |
| Economic Rules (60/30/10) | Protocol (Immutable) |

**Key Principle:** The operator controls the machine, not the rules.

## 🔒 The Sovereign Invariant (Non-Negotiable)
The **60/30/10 Economic Split** is a protocol-level invariant. It is hardcoded in the Brain and enforced prior to vault commit. Any attempt to bypass this results in a **Fail-Closed** execution halt.

## 🧠 Node Autonomy (Operator Authority)
Within the bounds of the Invariant, the operator has absolute autonomy over:
* Physical hardware and OS environment.
* Ingress providers (Cloudflare, Nginx).
* Vault backup and encryption.

**Explicit Limitation:** Once execution begins, the operator cannot retroactively modify committed state or alter transaction finality.

## 🗳️ Governance Roadmap
* **Phase 1.4.0:** Local Governance (Current). Determinism > Flexibility.
* **Phase 3.0:** Cross-Chain Governance (Envisioned). Anchoring local state roots to external chains like **peaq** and **IoTeX**.

---
© 2026 Coreframe Systems · Governance Specification v1.4.0
