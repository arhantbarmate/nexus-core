# ⚖️ Terms of Service — Nexus Protocol (v1.3.1)

By deploying or interacting with a Nexus Sovereign Node, you acknowledge the decentralized, local-first, and experimental nature of the protocol.

---

## 🛠️ 1. Node Operator Sovereignty
Nexus is a decentralized software suite. The Node Operator is solely responsible for:
* **Hardware & Security:** The physical and digital security of the hosting environment.
* **Data Management:** The integrity and backup of the local persistence layer (```nexus_vault.db```).
* **Regulatory Compliance:** Adherence to local data and financial regulations.

Nexus Protocol does not constitute a hosted service, financial product, custodial system, or identity provider. It is a self-hosted execution engine operated entirely at the discretion and responsibility of the Node Operator.

## 💰 2. Economic Invariants
The **60/30/10 split** is a deterministic local accounting rule. 
* **Local Ledger:** All transactions are recorded on a local-first ledger.
* **Soft Finality:** Phase 1.3.1 provides local "soft" finality. Any future anchoring to external networks (peaq, IoTeX, TON) will be subject to the separate terms and consensus rules of those respective layers.

## 🛡️ 3. Security & "Fail-Closed" Execution
The protocol utilizes a **Fail-Closed** security model. 
* **Interruption:** In the event of identity resolution failure or Sentry Bridge interruption, the protocol will cease execution to protect the integrity of the Sovereign Vault.
* **Handshake Hygiene:** Use of the protocol requires the operator to maintain specific client-side request headers required for tunnel routing stability during development (e.g., ngrok environments).



## 🚫 4. No Liability & "As-Is" Warranty
Nexus Protocol is provided "as-is" without warranty of any kind. The developers are not liable for:
* Any financial loss resulting from ledger state or economic splits.
* Data corruption arising from hardware failure or improper node termination.
* Indirect or consequential damages resulting from the use of this experimental software.

---

© 2026 Nexus Protocol · Terms of Service v1.3.1
