# ⚖️ Terms of Service — Nexus Protocol
**Coreframe Systems Lab | Version 1.4.0**

By deploying or interacting with a Nexus Sovereign Node, you acknowledge the decentralized, local-first, and autonomous nature of the protocol.

---

## 🛠️ 1. Node Operator Sovereignty
Nexus is a sovereign infrastructure suite. The Node Operator is exclusively responsible for:
* **Hardware & Security:** The physical and digital hardening of the hosting environment.
* **Vault Integrity:** The maintenance, encryption, and backup of the local persistence layer (```nexus_vault.db```).
* **Regulatory Compliance:** Adherence to all applicable local data, privacy (GDPR/CCPA), and financial regulations.

Nexus Protocol is not a hosted service, a financial product, or a custodial system. It is a self-hosted execution engine operated entirely at the discretion and responsibility of the Node Operator. Use of Nexus Protocol does not imply endorsement by Coreframe Systems of any specific application, business model, or deployment.

## 💰 2. Economic Axioms
The **60/30/10 split** is a deterministic, integer-based accounting rule. 
* **Local Ledger:** All transactions are recorded on a local-first ledger of truth.
* **Soft Finality:** Phase 1.4.0 provides "Local Soft Finality." Any future anchoring to external networks (e.g., peaq, IoTeX) is subject to the separate terms and consensus rules of those respective layers.



## 🛡️ 3. "Fail-Closed" Operational Logic
The protocol utilizes a **Fail-Closed** security model to preserve data integrity. 
* **Execution Cease:** In the event of identity resolution failure or Sentry Bridge interruption, the protocol will immediately cease execution to protect the Sovereign Vault.
* **Routing Hygiene:** Use of the protocol requires the operator to maintain ingress-specific routing configuration (including required headers) to ensure deterministic routing and tunnel stability.

## 🚫 4. No Liability & "As-Is" Warranty
Nexus Protocol is provided "as-is" without warranty of any kind. Coreframe Systems and its contributors are not liable for:
* Any financial loss or accounting discrepancy resulting from ledger state.
* Data corruption arising from hardware failure, power loss, or improper node termination.
* Indirect or consequential damages resulting from the use of this infrastructure.

---
© 2026 Coreframe Systems · Terms of Service v1.4.0  
*Sovereign tools for a deterministic world.*
