# ====================================================
# 🏗️ NEXUS ARCHITECTURE & SYSTEM DESIGN (V1.3)
# ====================================================
# Focus: Request Legitimacy & Perimeter Hardening
# Status: Phase 1.3 (In Progress - Sentry Active)
# ----------------------------------------------------

## 1. THE SOVEREIGN DESIGN PHILOSOPHY

Nexus operates on "Separation of Concern with Authority."
- THE BRAIN (Backend): The Economic Authority.
- THE BODY (Frontend): The Stateless Observer.
- THE SENTRY (Security): The Perimeter Guard.

---

## 2. THE HARDENED GATEWAY LOGIC (VISUALIZED)

Phase 1.3 introduces the **Sentry Layer**, a cryptographic guard that validates incoming Telegram WebApp signatures before they reach the Economic Engine.

[ USER / TELEGRAM ]
       |
       | (X-Nexus-TMA Header)
       v
+------------------------------------------+
|       🛡️ NEXUS SENTRY (GATEWAY)          |
|------------------------------------------|
|  1. HMAC-SHA256 Signature Check          |
|  2. Re-calculate Hash (Bot Token Secret) |
|  3. Reject Malformed/Unsigned Requests   |
+------------------------------------------+
       |
       | (IF VERIFIED)
       v
+------------------------------------------+
|        🧠 NEXUS BRAIN (LOGIC)            |
|------------------------------------------|
|  YES (/api/*)           NO (/*)          |
|      |                     |             |
|      v                     v             |
| [ NEXUS_VAULT ]     [ FLUTTER BODY ]     |
| (SQLite WAL)        (Reverse Proxy)      |
+------------------------------------------+

---

## 3. THE SENTRY: HMAC-SHA256 VERIFICATION

The Sentry (`sentry.py`) implements the official Telegram WebApp authentication protocol:
- **Secret Derivation:** A site-specific key is derived from `BOT_TOKEN`.
- **Integrity Check:** Validates `initData` payload using timing-safe comparisons.
- **Protocol Discipline:** Establishes request legitimacy without requiring centralized OAuth.

---

## 4. DATA PERSISTENCE: THE VAULT

- MODE: Write-Ahead Logging (WAL).
- ATOMICITY: Every economic split (60-30-10) is a single atomic transaction. 
- ISOLATION: The database is locked to the Brain process to prevent external tampering.

---

## 5. EVOLVING DESIGN LIMITS (PHASE 1.3)

[X] REQUEST LEGITIMACY: Handled by Sentry (HMAC).
[ ] CRYPTOGRAPHIC IDENTITY: Reserved for Phase 2.0 (TON Anchoring).
[ ] P2P PEERING: Deferring to Phase 2.5 (Network Mesh).

----------------------------------------------------
© 2026 Nexus Protocol | Apache License 2.0
----------------------------------------------------