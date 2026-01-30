# 🔌 Adapter Registry & Integration Guide — Nexus Protocol
**Coreframe Systems™ Lab | Version 1.4.0**

This document defines the Adapter System: the mechanism for integrating external ecosystems while preserving local-first determinism.

## 🧩 Adapter Philosophy
Adapters are **translation layers**, not execution authorities. They normalize inputs and verify identity context, but they do NOT execute economic logic or bypass the Brain.

## 📐 Universal Adapter Interface
All adapters must implement the interface defined in:
```backend/adapters/base.py```

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
These reside in the ```research/``` namespace and are excluded from production builds.
* **peaq Adapter:** Target: Machine identity (Sr25519, peaq ID).
* **IoTeX Adapter:** Target: W3bstream & ioID verification.

## 🧱 Design Guarantee
Adapters expand reach, not authority. No adapter—regardless of chain—can override the Brain.

---
---

Coreframe Systems™ is a technical brand and research initiative of **Coreframe Infrastructure Labs Private Limited Private Limited Private Limited**, Madhya Pradesh, India (NIC 72900).
---

Coreframe Systems™ is a technical brand and research initiative of **Coreframe Infrastructure Labs Private Limited Private Limited**, Madhya Pradesh, India (NIC 72900).
---
© 2026 Coreframe Systems™ · All Rights Reserved
Coreframe Systems™ is a technical brand and research initiative of **Coreframe Infrastructure Labs Private Limited**, Madhya Pradesh, India (NIC 72900).