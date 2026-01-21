# 🛡️ Data Sovereignty — Nexus Protocol (v1.3.1)

Nexus is architected on the principle of **Absolute Data Sovereignty**. As an edge-first gateway, the protocol ensures that data ownership remains strictly with the Node Operator.

---

## 🔒 Local-First Persistence
* **Sovereign Vault:** All ledger entries, identity hashes, and transaction logs are stored in a local SQLite database (```nexus_vault.db```).
* **No Cloud Leakage:** The Nexus Brain does not transmit sensitive user data to centralized servers. All 60/30/10 splits are computed and stored locally on your hardware.

## 🛰️ Identity & Tunneling
* **Sentry Bridge:** The bridge extracts only necessary context (Signed HMAC/Init Data) for authentication. 
* **Tunneling (Ngrok):** While Ngrok facilitates connectivity, Nexus implements a **Sovereign Sentry Page** to maintain handshake integrity without exposing the underlying node structure to public indexing.

## ⚖️ User Rights
Users interacting with a Nexus Node are interacting directly with the Node Operator. Nexus Protocol (the software) does not have a "Backdoor" or a "Master Key" to access Sovereign Vaults.

---

© 2026 Nexus Protocol · Data Sovereignty Policy v1.3.1
