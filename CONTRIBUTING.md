# 🛠️ Contributing to Nexus Protocol
**Coreframe Systems Lab | Version 1.4.0**

Nexus is an open-source **Sovereign Gateway** architected for the DePIN ecosystem. We welcome contributions that maintain our core technical invariants and uphold our durability-first engineering discipline.

---

## 🏗️ Technical Invariants
All contributions must adhere to the following architectural requirements:

1. **The Economic Axiom:** Every economic state transition must strictly execute the **60/30/10 Deterministic Split**.
2. **Persistence Integrity:** Database operations must utilize **Write-Ahead Logging (WAL)**. Logic that introduces table-level locks, disables WAL mode, or demonstrably degrades ACID guarantees under concurrent load will be rejected.
3. **Modular Ingress:** New adapters must inherit from the ```BaseAdapter``` abstract class (see ```adapters/base.py```).

---

## 🚀 Development Workflow

### 1. Stack Requirements
* **Brain (Logic):** Python 3.10+ (FastAPI)
* **Body (Surface):** Flutter 3.38.6 Stable
* **Sentry (Ingress):** Zero Trust Tunnel (Reference: Cloudflare Tunnel)

### 2. Documentation & Tooling
Contributions to documentation, test coverage, and benchmarking suites are highly encouraged, provided they align with the stated technical invariants.

### 3. Verification Protocol (The Stress Test)
Before submitting a Pull Request, you must verify that your changes do not compromise the "Brain's" integrity under concurrent load. 

```bash
# Run the 1-Million Transaction Integrity Test
python scripts/stress_test_1m.py
```
*Expectation:* **0.00% data corruption** and stable TPS (~50–60 baseline on commodity edge hardware).

---

## 🛡️ Security & Disclosure
If you discover a security vulnerability, please do **not** open a public issue. To protect sovereign users, report vulnerabilities privately to Coreframe Systems Engineering:

* **Primary:** ```infrastructure@coreframe.systems```
* **Lead Maintainer:** Arhant Barmate (```arhantbarmate@gmail.com```)

---

## ⚖️ License
By contributing to Nexus Protocol, you agree that your contributions will be licensed under the **Apache License 2.0**.

---
© 2026 Coreframe Systems · Contribution Specification v1.4.0  
*This document governs the engineering contribution lifecycle.*
