# Contributing to Nexus Protocol

Thank you for your interest in **Nexus Protocol**.
This repository currently represents the **Phase 1.3.1 Hardened Gateway**, focused on Perimeter Security, Request Legitimacy, and Deterministic State Transitions.

Contributions are welcome, but the project enforces **strict architectural boundaries** to preserve protocol integrity.

---

## 1. Project Focus (Phase 1.3.1)
At this stage, development is governed by the "Hardened Sentry" model. 
Primary priorities:

1.  **Perimeter Hardening**
    Ensure the **Sentry (HMAC-SHA256)** correctly validates platform-provided integrity signatures before requests reach the execution engine.

2.  **Request Legitimacy**
    Validating that all inbound traffic originates from a legitimate Telegram WebApp context without introducing long-lived session state.

3.  **Stateless UI Discipline**
    The Flutter client must remain a pure visualization layer with **zero economic authority** and zero local persistence of ledger state.

---

## 2. How to Contribute

### Reporting Issues
Please open a GitHub Issue for the following categories:

* **Integrity Failures:** Cases where legitimate Telegram signatures are rejected or malformed requests are accepted.
* **Environment Drift:** Bugs that appear only under bridged execution (Ngrok/Telegram) but not on localhost.
* **Documentation Gaps:** Missing or inaccurate technical specifications in the Architecture or Economics docs.

### Pull Requests
All PRs must satisfy the following:

* **Atomic Scope:** One fix or one architectural improvement per PR.
* **Sentry-Compliant:** Logic must not bypass or weaken the Sentry verification gate.
* **Stateless Enforcement:** Any PR introducing business logic, persistence, or economic computation in the Flutter client will be **rejected without exception**.
* **Phase Discipline:** Changes must align strictly with Phase 1.3.1 hardening goals.

---

## 3. Scope Boundaries (Strict Enforcement)

### ❌ Out of Scope — Do Not Submit
* **User-Level Private Keys:** Client-side signing or seed phrase management (Reserved for Phase 2.0).
* **On-Chain Settlement:** TON smart contract integration or gas management (Reserved for Phase 3.0).
* **Centralized Auth:** JWTs, sessions, or traditional OAuth systems.

### ✅ In Scope — Encouraged Contributions
* Hardening the FastAPI / Sentry verification logic.
* Improving SQLite WAL-mode performance under concurrent reads.
* Enhancing protocol observability (structured rejection telemetry).
* UI liveness indicators that confirm gateway availability and Sentry readiness.

---

## 4. Governance & Conduct
All contributors must adhere to the **Code of Conduct**. Nexus Protocol prioritizes technical objectivity and professional integrity. Violations will result in corrective action as outlined in `CODE_OF_CONDUCT.md`.

---

## 5. Architectural Philosophy
Nexus Protocol prioritizes **correctness over speed** and **integrity over features**.



If a contribution weakens determinism, sovereignty, or perimeter security, it will not be merged—regardless of intent. We value contributions that make the system more robust, transparent, and auditable.

---

© 2026 Nexus Protocol | Phase 1.3.1 Hardened Gateway