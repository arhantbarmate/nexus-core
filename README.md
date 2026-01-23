# 🛰️ Nexus Protocol — Sovereign Edge Gateway (v1.3.1)

Nexus is an architectural correction to the custodial fragility of modern infrastructure. It decouples **Economic Determinism** from **Global Consensus** by executing high-integrity 60/30/10 splits at the sovereign edge.

---

## 🏛️ Project Portal
For high-fidelity technical specifications, the threat model, and interactive operational guides:
👉 **[Launch Sovereign Portal](https://arhantbarmate.github.io/nexus-core/)**

---

## 🏗️ System Architecture
Nexus operates as a **Sovereign Gateway** between identity providers and persistent storage, enforcing local economic invariants before anchoring to external chains.

* **The Brain (Backend):** FastAPI/SQLite WAL engine. Validated for **1,000,000 transactions** with zero data corruption.
* **The Body (Frontend):** Flutter-based surface for authenticated user interaction.
* **The Sentry (Edge):** Custom fail-closed bridge with staged (non-authoritative) signature verification in Phase 1.3.1.

---

## 📑 Technical Documentation
| Foundational | Operational | Governance & Security |
| :--- | :--- | :--- |
| [Architecture](./docs/ARCHITECTURE.md) | [Installation](./docs/INSTALL.md) | [Security Policy](./SECURITY.md) |
| [Economics](./docs/ECONOMICS.md) | [Roadmap](./docs/ROADMAP.md) | [Threat Model](./docs/THREAT_MODEL.md) |
| [Novelty](./docs/NOVELTY.md) | [Technical FAQ](./docs/FAQ.md) | [Terms of Service](./docs/terms.md) |

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
   Ensure the node passes the Phase 1.3.1 baseline durability test:
   ```python scripts/stress_test_1m.py```

---

## 🛡️ Responsible Disclosure
Nexus implements a **Fail-Closed** security model. In the event of identity ambiguity, the system ceases execution to protect the Sovereign Vault.

* **Primary:** arhantbarmate@gmail.com
* **Secondary:** arhant6armate@outlook.com

---

© 2026 Nexus Protocol · Phase 1.3.1 Specification · Licensed under Apache 2.0
