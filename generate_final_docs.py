import os

# TRICK: Generate backticks safely to prevent chat render breakage
T = chr(96) * 3

# --- GOVERNANCE.MD CONTENT ---
gov_content = f"""# 🏛️ Governance Framework — Nexus Protocol
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
"""

# --- ADAPTERS.MD CONTENT ---
adapter_content = f"""# 🔌 Adapter Registry & Integration Guide — Nexus Protocol
**Coreframe Systems Lab | Version 1.4.0**

This document defines the Adapter System: the mechanism for integrating external ecosystems while preserving local-first determinism.

## 🧩 Adapter Philosophy
Adapters are **translation layers**, not execution authorities. They normalize inputs and verify identity context, but they do NOT execute economic logic or bypass the Brain.

## 📐 Universal Adapter Interface
All adapters must implement the interface defined in:
{T}backend/adapters/base.py{T}

### Core Responsibilities:
1. Implement identity verification hooks.
2. Normalize external data into Brain-compatible format.
3. Respect the 60/30/10 invariant.
4. Fail closed on ambiguity.

## ✅ Active (Production-Ready) Adapters
| Adapter | Status | Role |
| :--- | :--- | :--- |
| **TON** | ✅ Active | Reference Implementation for Telegram Mini Apps |

## 🧪 Research Adapters (Draft / Non-Production)
These reside in the {T}research/{T} namespace and are excluded from production builds.
* **peaq Adapter:** Target: Machine identity (Sr25519, peaq ID).
* **IoTeX Adapter:** Target: W3bstream & ioID verification.

## 🧱 Design Guarantee
Adapters expand reach, not authority. No adapter—regardless of chain—can override the Brain.

---
© 2026 Coreframe Systems · Adapter Registry v1.4.0
"""

# TARGET: docs/
os.makedirs("docs", exist_ok=True)

with open("docs/GOVERNANCE.md", "w", encoding="utf-8") as f:
    f.write(gov_content)

with open("docs/ADAPTERS.md", "w", encoding="utf-8") as f:
    f.write(adapter_content)

print("✅ SUCCESS: GOVERNANCE.md and ADAPTERS.md generated.")