# 🛡️ Data Sovereignty — Nexus Protocol (v1.3.1)

Nexus is architected on the principle of **Absolute Data Sovereignty**. As a local-first gateway, the protocol ensures that data ownership remains strictly with the Node Operator. 

---

## 🔒 Local-First Persistence
* **Sovereign Vault:** All ledger entries, identity hashes, and transaction logs are stored in a local SQLite database (```nexus_vault.db```).
* **Zero Cloud Leakage:** The Nexus Brain does not transmit sensitive user data or economic state to centralized servers. All **60/30/10 splits** are computed and persisted locally on your hardware.
* **Non-Custodial:** The protocol is an accounting engine, not a wallet. It does not custody private keys or external assets; it manages a local deterministic ledger.

---

## 🛰️ Identity & Tunneling

* **Sentry Guard:** The perimeter extracts only the minimal environmental context (```initData``` or HMAC) required for identity resolution. 
* **Tunneling Resilience:** While Ngrok facilitates connectivity, Nexus utilizes header-based bypass logic (```ngrok-skip-browser-warning```) to maintain handshake integrity without exposing the internal node structure to public indexing or third-party data collection.

---

## ⚖️ Operator & User Rights
Users interacting with a Nexus Node are interacting directly with the Node Operator's sovereign hardware.
* **No Backdoors:** Nexus Protocol (the software) does not have a master key, administrative backdoor, or telemetry reporting to the developers.
* **Compliance Responsibility:** Responsibility for compliance with local data regulations rests with the Node Operator deploying the software.
* **Auditability:** The local vault is accessible to the operator for manual audit via standard SQLite tools, ensuring total transparency of the **durability-first** ledger.

---

© 2026 Nexus Protocol · Data Sovereignty Policy v1.3.1
