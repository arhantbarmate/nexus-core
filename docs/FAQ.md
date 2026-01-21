# ❓ Technical FAQ — Nexus Protocol (v1.3.1)

This document addresses the architectural rationale and infrastructure choices behind the Nexus Sovereign Gateway.

---

## 🌐 Infrastructure & Connectivity

### Q: Why does the Gateway use a custom HTML proxy for Ngrok?
**A:** To maintain a **$0-cost Sovereign Stack**. Ngrok's free tier includes a mandatory "Browser Warning" interstitial that breaks headless handshakes for Telegram Mini Apps (TMA). 

We implement a **Sovereign Sentry Bridge (HTML/JS Interface)** that:
1. **Detection:** Checks for the ```ngrok-skip-browser-warning``` header or interstitial presence.
2. **Auto-Bypass:** Executes a client-side "Proceed" command via a lightweight, zero-latency HTML UI.
3. **Handshake Integrity:** Ensures the Sentry Bridge in the Flutter "Body" receives a clean connection, allowing the TMA to authenticate without manual user intervention during development and demos.

### Q: Why use SQLite instead of a distributed database?
**A:** Local-first sovereignty and high performance on edge hardware. 
* **Write-Ahead Logging (WAL):** Utilized to manage concurrent identity surges.
* **Verification:** Successfully handles a **50-user concurrent settlement load** with 100% split accuracy.
* **Sovereignty:** Keeping the ledger local ensures the operator maintains state ownership before anchoring to an external chain.

---

## 💰 Economic & State Logic

### Q: Is the 60/30/10 split hardcoded?
**A:** In Phase 1.3.1, yes. This ensures **Economic Determinism**. Hardcoding the split in the "Brain" prevents UI-level tampering. The architecture allows future anchoring layers (peaq/IoTeX) to parameterize these values via governance adapters.

### Q: What happens if a transaction fails the Sentry Guard?
**A:** The system follows a **Fail-Closed** logic. Requests failing HMAC or Signed Context validation are rejected (403 Forbidden) at the edge. No state changes are committed to the Vault.

---

## 🛰️ Identity & Adapters

### Q: Why frame the UI as an "Execution Surface"?
**A:** To maintain **Chain-Agnosticism**. The UI merely renders the state of the Sovereign Brain. This separation ensures Nexus remains compatible with future machine, device, or DID-based identity systems without altering core execution logic.

---

© 2026 Nexus Protocol · Technical FAQ v1.3.1
