# 🛰️ Nexus Protocol — Sovereign Edge Gateway (v1.4.0)

> **Status:** Phase 1.4.0 — Infrastructure Hardening (Local-First, No On-Chain Settlement)

Nexus is an architectural correction to the custodial fragility of modern infrastructure. It decouples **Economic Determinism** from **Global Consensus** by executing high-integrity 60/30/10 splits at the sovereign edge.

---

## 🏛️ Why Nexus Protocol?

Nexus exists to displace the "Cloud Middleman." By moving the point of economic settlement to the user's own hardware, we ensure that data and value remain non-custodial and unassailable.

### 🧩 Ecosystem Solutions:
* **For IoTeX (DePIN Logic):** Nexus acts as a local-first buffer for W3bstream. It ensures physical activity proofs are validated and partitioned with ACID integrity before hitting the chain.
* **For peaq (Machine Identity):** It enables "Verify-then-Execute" for machine-owners. Nexus resolves peaq IDs locally, ensuring rewards are calculated at the source.
* **For TON (Telegram Ecosystem):** Nexus transforms Telegram Mini Apps into "Stateless Surfaces"—reducing backend cost and failure domains for high-frequency apps. Users interact with sovereign hardware without the app ever seeing their sensitive ledger state.

---

## 🏗️ System Architecture & Logic Flow

Nexus operates on a **Verify-then-Execute** model. The **Sentry Bridge** acts as a logic gate, ensuring only validated environmental contexts reach the **Brain**.

### 🔹 Current State (Phase 1.4.0):
Stand-alone Sovereign Node. Hardened Ingress via Cloudflare Zero Trust. Local finality via SQLite WAL.



### 🔮 Envisioned Workflow (Phase 2.0+):
Nexus will evolve into a **Cross-Machine Settlement Engine**. Local finality roots will be cryptographically anchored to multiple DePIN chains (peaq, IoTeX) simultaneously, enabling global verification of local edge events.

---

## 🛡️ Threat Model & Resilience

Nexus is architected for **Sovereign Resilience**. We prioritize "Fail-Closed" security.

### 🔹 Current Model (Hardened Ingress):
We assume an untrusted public ingress. The **Sentry Perimeter** uses deterministic header-routing to prevent unauthorized writes to the **Sovereign Vault**.



---

## 🌐 Project Launchpad
For high-fidelity technical specifications and interactive operational guides:
👉 **[Launch Sovereign Portal](https://arhantbarmate.github.io/nexus-core/)**

👉 **[Explore Coreframe Systems](https://coreframe.systems)** *(Launching Post-v1.4.0 Push)*

---

## 📑 Technical Documentation
| Foundational | Operational | Governance & Security |
| :--- | :--- | :--- |
| [Architecture](./docs/ARCHITECTURE.md) | [Installation](./docs/INSTALL.md) | [Security Policy](./docs/SECURITY.md) |
| [Economics](./docs/ECONOMICS.md) | [Roadmap](./docs/ROADMAP.md) | [Threat Model](./docs/THREAT_MODEL.md) |
| [Novelty](./docs/NOVELTY.md) | [Technical FAQ](./docs/FAQ.md) | [Privacy Policy](./docs/privacy.md) |

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
   Execute ```start_nexus.bat``` (Windows) or ```./start_nexus.sh``` (Linux/macOS) to initialize the Brain, Sentry, and Tunnel layers.

3. **Verify Integrity:**
   Ensure the node passes the Phase 1.4.0 baseline durability test:
   ```python scripts/stress_test_1m.py```

---

## 🛡️ Responsible Disclosure
Nexus implements a **Fail-Closed** security model. Report vulnerabilities regarding the 60/30/10 Invariant to:
* **Official:** infrastructure@coreframe.systems
* **Secondary:** arhant6armate@gmail.com

---
© 2026 Coreframe Systems · Phase 1.4.0 Specification · Licensed under Apache 2.0
