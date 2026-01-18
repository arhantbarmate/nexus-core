# 🛡️ Security Policy — Nexus Protocol

This document defines the responsible disclosure process, security scope, and threat assumptions for the **Hardened Gateway Architecture (Phase 1.3.1)**.

---

## 1. Reporting a Vulnerability

If you discover a security vulnerability in Nexus Protocol, please report it responsibly. We appreciate the work of security researchers and aim to respond in good faith.

### Preferred Disclosure Channel
Please submit private vulnerability reports to:
📧 **arhantbarmate@outlook.com**

### Reporting Guidelines
* **Private First:** Do not disclose exploit details in public issues or forums.
* **Tagging:** If private reporting is not possible, open a GitHub issue clearly marked **[SECURITY]**.
* **Include:** Reproduction steps, impact description, and a minimal Proof of Concept (PoC).

---

## 2. Threat Model & Scope (Phase 1.3.1)

Phase 1.3.1 introduces the **Sentry**, a deterministic verification guard. Security research in this phase should evaluate the integrity of the gateway perimeter.



### 🎯 In-Scope Vulnerabilities (High Priority)
* **Sentry Bypass:** Any method to trigger economic logic (60-30-10 split) without a valid HMAC-SHA256 signature.
* **Integrity Logic Flaws:** Vulnerabilities in how `sentry.py` parses or validates Telegram WebApp `initData`.
* **Path Confusion:** Forcing the Gateway (Port 8000) to expose internal routes or bypass Sentry validation.
* **Deterministic Drift:** Bypassing state machine invariants via malformed payloads that pass initial validation.

### 🚫 Out-of-Scope Vulnerabilities (Lower Priority)
* **Compromised Secrets:** Attacks assuming the attacker already has the `BOT_TOKEN`.
* **Local Physical Access:** Attacks requiring direct read/write access to the machine's file system or the `nexus_vault.db` file.
* **Replay Attacks:** Recognized but not yet enforced; freshness and timestamp validation are planned extensions within Phase 1.3.1 hardening.

---

## 3. Hardened Gateway Assumptions

Phase 1.3.1 operates under a **"Fail-Closed"** security posture:

1.  **Legitimacy Over Identity:** The system verifies that a request is contextually "real" (via platform signatures) rather than identifying a specific human user (deferred to Phase 2.0).
2.  **Protocol-Level Trust:** The Brain trusts the Sentry's validation. All economic transitions are gated by this verification.
3.  **Sovereign Isolation:** Security is maintained by ensuring the **Body (UI)** never handles sensitive validation secrets or cryptographic keys.

---

## 4. Safe Harbor

Nexus Protocol provides safe harbor for security researchers who act in good faith, avoid harm to users, and follow this disclosure policy. We will not pursue legal action against researchers who comply with these conditions.

---

## 5. Response Timeline

Nexus Protocol is currently a **Security Hardening & Architecture Validation** project.

* Initial acknowledgment is typically provided within **72 hours**.
* Remediation progress will be shared via private channels until a fix is deployed.

---

**© 2026 Nexus Protocol | Phase 1.3.1 Hardened Gateway**