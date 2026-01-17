# Nexus Protocol — Frequently Asked Questions (Phase 1.3)

This document answers common architectural, economic, and operational questions about the **Hardened Gateway Node (Phase 1.3)**.

---

## 🏛️ Architecture & Perimeter Security

### Q: What is the "Sentry" and why was it added in Phase 1.3?
**A:** The Sentry is a **deterministic verification guard** that sits at the gateway boundary. Its role is to validate the integrity of incoming requests using the Telegram WebApp `initData` protocol. 

It was added to move the system from "Architectural Authority" to "Perimeter Hardening"—ensuring that the Economic Brain only processes requests that have been verified as legitimate at the protocol level.

### Q: Why not implement full authentication now?
**A:** Authentication and identity introduce long-lived keys, recovery paths, and on-chain dependencies. Phase 1.3 deliberately focuses on **request legitimacy** as a prerequisite. Identity without a hardened perimeter would increase complexity without improving safety.

### Q: Why use HMAC-SHA256 for request validation?
**A:** This aligns with the official Telegram Mini App security model. By deriving a site-specific secret from the `BOT_TOKEN`, we can verify that a request:
1. Originated from our specific Mini App.
2. Has not been tampered with in transit.
3. Is contextually legitimate.

---

## 💰 Economics & State Machine

### Q: Why do you use the term "State Transition" instead of "Transaction"?
**A:** In Phase 1.3, we treat the 60-30-10 split as a **deterministic state transition invariant**. This frames the economics as a technical "test harness" for ledger integrity rather than a finalized business model or social tokenomic structure.

### Q: Are the 60-30-10 ratios final?
**A:** **No.** These numerical ratios are **arbitrary placeholders** chosen for simplicity and auditability during early-phase validation. They allow us to test the atomicity of the Vault and the enforcement of the Sentry gate without the complexity of governance.

---

## 💾 Persistence & Data

### Q: Why SQLite instead of a cloud database?
**A:** SQLite supports the **Local-First Sovereign Node** philosophy. It allows the node to operate independently of centralized cloud providers, providing ACID-compliant persistence on the user's local environment.

### Q: How is the Vault protected from local tampering?
**A:** In Phase 1.3, protection is provided by **Process Isolation**. Only the Brain process has write-access to the Vault file. In Phase 2.0, we will introduce **Cryptographic Anchoring** to the TON blockchain to provide external verifiability of the local state.

---

## 🔍 Operational Status

### Q: Does Phase 1.3 require a TON wallet?
**A:** **No.** We continue to prioritize "correctness before crypto." By focusing on the Sentry's HMAC validation first, we ensure the gateway is secure before we introduce the complexity of on-chain wallet interactions in Phase 2.0.

### Q: Is this production-ready?
**A:** **No.** Phase 1.3 is a "Perimeter Hardening" milestone. It is designed for developers, auditors, and grant reviewers to evaluate the protocol's security mindset and architectural discipline.

---

## 📌 Phase 1.3 Focus
1. **Perimeter Hardening** (The Sentry)
2. **Request Legitimacy** (HMAC-SHA256)
3. **Execution Invariants** (State Machine Logic)

---

© 2026 Nexus Protocol