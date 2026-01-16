# Contributing to Nexus Protocol

Thank you for your interest in **Nexus Protocol**.
This repository currently represents the **Phase 1.2 Gateway Node**, focused on Environment Sovereignty, Gateway Architecture, and deterministic local-first execution.

Contributions are welcome, but the project enforces **strict architectural boundaries** to preserve correctness.

---

## 1. Project Focus (Phase 1.2)
At this stage, development is intentionally constrained.
Primary priorities:

1.  **Gateway Integrity**
    Ensure the Brain (Port 8000) correctly proxies, routes, and isolates the Body (Port 8080).

2.  **Environment Consistency**
    The node must behave identically across:
    * Localhost
    * Ngrok bridge
    * Telegram WebApp context

3.  **Stateless UI Discipline**
    The Flutter client must remain a pure visualization layer with **zero economic authority**.

---

## 2. How to Contribute

### Reporting Issues
Please open a GitHub Issue for the following categories only:

* **Proxy Failures:** Cases where the Brain fails to correctly route or serve the Body.
* **Environment Drift:** Bugs that appear only under bridged execution but not on localhost (or vice versa).
* **Documentation Gaps:** Missing, inaccurate, or confusing information in the Installation guide, Architecture docs, or Phase descriptions.

**When reporting issues, include:**
* Execution environment (Local / Bridge / Telegram)
* Relevant logs (Brain preferred)
* Clear reproduction steps

### Pull Requests
Pull requests are welcome but strictly reviewed.
All PRs must satisfy the following:

* **Atomic Scope:** One bug fix or one architectural improvement per PR.
* **Gateway-Compliant:** All economic or routing logic must reside in the Brain. UI-only changes must not affect execution semantics.
* **Stateless UI Enforcement:** Any PR introducing business logic, persistence, or economic computation in the Flutter client will be **rejected without exception**.
* **Phase Discipline:** Changes must align strictly with Phase 1.2 goals.

---

## 3. Scope Boundaries (Strict Enforcement)
Nexus Protocol is currently in **Phase 1.2**.
The following boundaries are non-negotiable.

### ❌ Out of Scope — Do Not Submit
* **Cryptographic Identity:** Wallets, private keys, signing, or verification logic (Reserved for Phase 2.0).
* **Peer-to-Peer Networking:** Libp2p, gossip protocols, mesh logic (Reserved for Phase 3.0).
* **Client-Side Persistence:** LocalStorage, IndexedDB, cookies, or cached ledger state.
* **Authentication Layers:** JWTs, sessions, OAuth, or role systems.

### ✅ In Scope — Encouraged Contributions
* Hardening the FastAPI reverse proxy.
* Improving SQLite WAL performance or safety.
* Enhancing observability (logs, health signals).
* Improving UI liveness indicators (non-authoritative).
* Documentation corrections and clarifications.

---

## 4. Governance & Conduct
All contributors are expected to follow the project’s **Code of Conduct** (Contributor Covenant v2.1).

Violations may result in warnings, temporary bans, or permanent removal from the project, as outlined in `CODE_OF_CONDUCT.md`.

---

## 5. Final Note
Nexus Protocol prioritizes **correctness over speed** and **architecture over features**.

If a contribution weakens determinism, sovereignty, or phase discipline, it will not be merged—regardless of intent. Thank you for respecting the constraints that make this system coherent.

---

© 2026 Nexus Protocol