# 🛰️ Nexus Protocol — Sovereign Edge Gateway (v1.3.1)

Nexus is an architectural correction to the custodial fragility of modern infrastructure. It decouples **Economic Determinism** from **Global Consensus** by executing high-integrity 60/30/10 splits at the edge.

---

## 🏛️ Project Portal
For high-fidelity technical specifications and interactive operational guides:
👉 **[Launch Sovereign Portal](https://arhantbarmate.github.io/nexus-core/docs/index.html)**

---

## 🏗️ System Architecture
Nexus operates as a **Sovereign Gateway** between identity providers and persistent storage, enforcing local economic invariants before anchoring to external chains.

* **The Brain (Backend):** FastAPI/SQLite WAL engine executing deterministic logic.
* **The Body (Frontend):** Flutter-based surface for authenticated interaction.
* **The Sentry (Edge):** Custom HMAC-validated bridge for $0-cost tunneling.

---

## 📑 Technical Documentation
| Foundational | Operational | Governance |
| :--- | :--- | :--- |
| [Architecture](./docs/architecture.md) | [Installation](./docs/install.md) | [Security Policy](./SECURITY.md) |
| [Economics](./docs/economics.md) | [Roadmap](./docs/roadmap.md) | [Privacy Policy](./docs/privacy.md) |
| [Novelty](./docs/novelty.md) | [Technical FAQ](./docs/faq.md) | [Terms of Service](./docs/terms.md) |

---

## 🚀 Quick Start
Initialize a Sovereign Node on local hardware:

1. **Clone & Setup:**
   ```bash
   git clone https://github.com/arhantbarmate/nexus-core.git
   cd nexus-core
   pip install -r requirements.txt
   ```

2. **Launch Node:**
   Execute ```./start_nexus.bat``` to initialize the Brain, Sentry, and Tunnel layers.

3. **Verify Integrity:**
   Ensure the node passes the local stress test:
   ```python scripts/test_concurrency.py --users 50```

---

## 🛡️ Responsible Disclosure
Nexus implements a **Fail-Closed** security model. Responsible disclosure is encouraged via:
* **Primary:** arhantbarmate@gmail.com
* **Secondary:** arhant6armate@outlook.com

---

© 2026 Nexus Protocol · Phase 1.3.1 Specification
