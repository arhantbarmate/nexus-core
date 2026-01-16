# Security Policy — Nexus Protocol

This document defines the responsible disclosure process, security scope, and threat assumptions for **Nexus Protocol Phase 1.2**.

---

## 1. Reporting a Vulnerability

If you discover a security vulnerability in Nexus Protocol, please report it responsibly. We appreciate the work of security researchers and aim to respond in good faith.

### Preferred Disclosure Channel
Please submit private vulnerability reports to:
📧 **arhantbarmate@outlook.com**

### Reporting Guidelines
When reporting a vulnerability:
* **Do not** disclose exploit details in public issues or forums.
* If private reporting is not possible, open a GitHub issue clearly marked **[SECURITY]**.
* **Include:**
    * Clear reproduction steps.
    * Impact description.
    * A minimal Proof of Concept (PoC) where applicable.

*Please avoid weaponized exploits or automated scanning that could disrupt local node operation.*

---

## 2. Threat Model & Scope (Phase 1.2)

Nexus Protocol Phase 1.2 implements a **Gateway-based Sovereign Node**.
Security research should be evaluated against the actual architectural guarantees of this phase.

### 🎯 In-Scope Vulnerabilities (High Priority)
The following issues are considered in scope for Phase 1.2:

* **Economic Drift:** Incorrect 60-30-10 split calculations, rounding inconsistencies, negative values, or arithmetic edge cases.
* **Gateway / Proxy Violations:** Access to the internal Body (Port 8080) via the Brain (Port 8000), proxy routing bypasses, or path confusion attacks.
* **Header Manipulation:** Abuse of the `x-nexus-proxy-gate` mechanism, recursive proxy loops, or header injection exploits.
* **Vault Integrity Failures:** WAL corruption leading to unrecoverable ledger state, or partial/inconsistent transaction commits.

### 🚫 Out-of-Scope Vulnerabilities (Lower Priority)
The following are explicitly **out of scope** for Phase 1.2:

* **Physical Access Attacks:** Attacks requiring direct access to the machine hardware.
* **User-Managed Bridge Exposure:** Insecure Ngrok/tunnel configurations or leaked bridge URLs.
* **Operating System Permissions:** File-system permission issues, OS-level sandboxing, or malware.
* **Denial of Service (DoS):** CPU, memory, or disk exhaustion attacks on the local node.

*Phase 1.2 prioritizes correctness and sovereignty, not adversarial network hardening.*

---

## 3. Bridge & Network Security Assumptions

Phase 1.2 optionally allows users to expose their node via a bridge (e.g., Ngrok).

**Security Assumptions:**
* The bridge connection uses HTTPS.
* The Gateway does **not** implement authentication (JWT, OAuth, sessions).
* There is no request signing or identity verification.

**User Responsibility:**
* Keep bridge URLs private.
* Rotate tunnels if exposure is suspected.
* Treat bridged access as equivalent to local access.

---

## 4. Safe Harbor

Nexus Protocol provides safe harbor for security researchers who:
* Act in good faith.
* Avoid harm to users or data.
* Respect this disclosure policy.
* Allow reasonable time for remediation before public disclosure.

*We will not pursue legal action against researchers who comply with these conditions.*

---

## 5. Response Timeline

Nexus Protocol is currently a **feasibility and architecture validation project**.

* Vulnerability reports are handled on a **best-effort basis**.
* Initial acknowledgment is typically provided within **72 hours**.
* Updates will be shared as remediation progresses.

---

## 📌 Final Note
Phase 1.2 security relies on **architectural isolation**, not cryptographic enforcement.
Identity, signing, and adversarial hardening are planned for **Phase 2.0** and beyond.

---

© 2026 Nexus Protocol