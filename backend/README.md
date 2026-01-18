# ====================================================
# 🧠 NEXUS BACKEND: SOVEREIGN BRAIN & SENTRY
# ====================================================
# Focus: Request Legitimacy & Multichain Hardening
# Status: Phase 1.3 (v1.3.1 - Staged Staging)
# ----------------------------------------------------

## 1. THE SOVEREIGN DESIGN PHILOSOPHY

Nexus operates on a strict **"Verify-then-Execute"** model, moving the trust perimeter from the cloud to the user's local hardware.

- **🛡️ THE SENTRY (`sentry.py`):** The Perimeter Guard. Validates request origin.
- **🧠 THE BRAIN (`main.py`):** The Economic Authority. Executes deterministic logic.
- **💾 THE VAULT (`nexus_vault.db`):** The Source of Truth. ACID-compliant local persistence.

---

## 2. THE HARDENED GATEWAY LOGIC (VISUALIZED)

Phase 1.3 introduces a **Modular Sentry**, capable of validating requests from heterogeneous networks (TON Social / IoTeX DePIN).

```text
       [ USER / DEVICE / TMA ]
                  |
                  | (Signed Intent Payload)
                  v
+------------------------------------------+
|        🛡️ NEXUS SENTRY (GATEWAY)         |
|------------------------------------------|
|  1. TON GATE: HMAC-SHA256 Check (Active) |
|  2. IOTX GATE: ioID Identity (Staged)    |
|  3. Reject Malformed/Unsigned Requests   |
+------------------------------------------+
                  |
                  | (IF VERIFIED)
                  v
+------------------------------------------+
|         🧠 NEXUS BRAIN (CORE)            |
|------------------------------------------|
|  /api/* (Logic)        /* (Reverse Proxy)|
|        |                      |          |
|        v                      v          |
|  [ NEXUS_VAULT ]        [ FLUTTER BODY ] |
|  (Deterministic)        (Visualization)  |
+------------------------------------------+
```

---

## 3. THE SENTRY: MULTICHAIN VALIDATION

The Sentry implements a "Fail-Closed" posture, ensuring the Brain only processes authenticated state transitions.

### 🔹 TON Module (Current)
- **Secret Derivation:** Site-specific key derived from `BOT_TOKEN`.
- **Integrity Check:** Validates `initData` using timing-safe comparisons to prevent side-channel leaks.

### 🔹 IoTeX Module (Staging)
- **Identity Readiness:** Architected to support **ioID** (Decentralized Identity) for hardware-rooted trust.
- **W3bstream Staging:** Prepared to export verified logs for off-chain verifiable compute and proof generation.

---

## 4. DATA PERSISTENCE: THE VAULT

- **Mode:** Write-Ahead Logging (WAL) for high-concurrency reliability.
- **Invariants:** Enforces the **60-30-10** split as a deterministic system property. 
- **Anchoring-Ready:** Schema includes Merkle-root support for future on-chain commits.

---

## 5. REVENUE & SYSTEM INVARIANTS (PHASE 1.3)

[x] **HMAC PERIMETER:** Sentry-gated request validation.
[x] **ATOMIC EXECUTION:** Deterministic state machine logic.
[ ] **ioID INTEGRITY:** (Phase 2.0) Hardware-based identity verification.
[ ] **DEPIN PROOFS:** (Phase 2.1) W3bstream off-chain verifiable compute.

----------------------------------------------------
© 2026 Nexus Protocol | Apache License 2.0
----------------------------------------------------