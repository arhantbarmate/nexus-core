# 🛡️ Security Policy — Nexus Protocol

## 1. Reporting a Vulnerability
Please submit private vulnerability reports to: 📧 **arhantbarmate@outlook.com**

If email is unavailable, please open a private GitHub Security Advisory via the repository's Security tab.

## 2. Threat Model & Scope (Phase 1.3.1)
Phase 1.3.1 introduces the **Sentry**, a deterministic verification guard. 

### 🎯 In-Scope Vulnerabilities
* **Sentry Bypass:** Any method to trigger logic without a valid platform signature (HMAC, Ed25519, etc.).
* **Integrity Logic Flaws:** Vulnerabilities in how `sentry.py` validates adapter-provided data.
* **Deterministic Drift:** Bypassing state machine invariants via malformed payloads.

### 🚫 Out-of-Scope
* **Compromised Secrets:** Attacks assuming the attacker already has the `BOT_TOKEN` or private keys.
* **Local Physical Access:** Attacks requiring direct access to the `nexus_vault.db` file.

---
**© 2026 Nexus Protocol | Universal Edge Gateway**
