# 🛠️ Contributing to Nexus Protocol — (v1.3.1)

Nexus is an open-source **Sovereign Gateway** architected for the DePIN ecosystem. We welcome contributions that maintain our core technical invariants and uphold our durability-first engineering discipline.

---

## 🏗️ Technical Standards
All contributions must adhere to the following architectural requirements:

1. **The Invariant:** Every economic state transition must strictly execute the **60/30/10 Deterministic Split**.
2. **Persistence:** Database operations must utilize **Write-Ahead Logging (WAL)** and avoid logic that triggers table-level locks.
3. **Identity:** New adapters must inherit from the ```BaseAdapter``` class in ```nexus/adapters/base.py```.

---

## 🚀 Development Workflow

### 1. Environment Setup
* **Backend:** Python 3.10+ (FastAPI/Uvicorn)
* **Frontend:** Flutter 3.38.6 Stable
* **Gateway:** Ngrok (for TMA testing)

### 2. Verification Protocol
Before submitting a Pull Request, you must verify that your changes do not compromise the "Brain's" integrity under load:
```bash
# Run the 1-Million Transaction Stress Test
python scripts/stress_test_1m.py
```
*Expectation:* 0% data corruption and stable TPS (~50–60 baseline on commodity hardware).

---

## 🛡️ Security & Disclosure
If you discover a security vulnerability, please do **not** open a public issue. To protect the protocol's sovereign users, report vulnerabilities privately:

* **Lead Maintainer:** Arhant Barmate
* **Primary:** arhantbarmate@gmail.com
* **Secondary:** arhant6armate@outlook.com

---

## ⚖️ License
By contributing to Nexus Protocol, you agree that your contributions will be licensed under the **Apache License 2.0**.

---

© 2026 Nexus Protocol · Contribution Specification v1.3.1
