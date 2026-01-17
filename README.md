<div align="center">
  <img src="https://raw.githubusercontent.com/arhantbarmate/nexus-core/main/client/assets/nexus-logo.png" width="120" height="120" alt="Nexus Protocol Logo">
  <h1>NEXUS PROTOCOL</h1>
  <p><b>Phase 1.2: The Gateway-Based Sovereign Node</b></p>

  <a href="https://github.com/arhantbarmate/nexus-core/actions">
    <img src="https://github.com/arhantbarmate/nexus-core/actions/workflows/ci.yml/badge.svg?branch=main" alt="CI Status" />
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/License-Apache_2.0-blue.svg" />
  </a>
  <a href="docs/ROADMAP.md">
    <img src="https://img.shields.io/badge/Status-PHASE_1.2_ACTIVE-green.svg" />
  </a>
  <a href="docs/ARCHITECTURE.md">
    <img src="https://img.shields.io/badge/Arch-Gateway_Proxy-purple.svg" />
  </a>
  
  <p><i>Local-First Execution · Deterministic Economics · Gateway Sovereignty</i></p>
</div>

---

## 🔎 Phase 1.2 System Status: Gateway Node
**Release:** `v1.2.3` | **Status:** ✅ Stable · CI-Clean · Environment-Consistent

Phase 1.2 marks the successful transition of Nexus Protocol from a local prototype to a **Gateway-based Sovereign Node**. The system now runs identically across Localhost, CI/CD, Browser, and Telegram WebApp environments.

### 🏛️ Milestone Highlights
* **🔗 Unified Platform Bridge:** Implemented `tg_bridge.dart` to isolate platform-specific APIs, allowing the Flutter "Body" to compile cleanly on Linux CI/CD while functioning as a full Mini App on Web.
* **🌉 Gateway Routing:** Established a strict `/api/*` namespace. All external traffic enters via the **Brain** (Port 8000), which reverse-proxies the UI.
* **💾 Vault Integrity:** Connected the Brain to a local SQLite Vault operating in **WAL mode** for append-only, crash-safe economic record keeping.
* **🛡️ Namespace Shielding:** Resolved Flutter/Telegram symbol collisions and locked in version-stable haptics via the internal bridge.

---

## 📖 Documentation Index

| 📚 Category | 📄 Document | 🔍 Description |
| :--- | :--- | :--- |
| **Start Here** | **[Installation Guide](docs/INSTALL.md)** | ⚡ Run a local node in minutes |
| **Deep Dive** | **[Architecture](docs/ARCHITECTURE.md)** | 🏛️ Brain-First Gateway design |
| **Logic** | **[Economic Model](docs/ECONOMICS.md)** | 💰 Deterministic 60-30-10 split |
| **Future** | **[Roadmap](docs/ROADMAP.md)** | 🗺️ Gateway → Identity evolution |
| **FAQ** | **[Common Questions](docs/FAQ.md)** | ❓ SQLite, Local-First, Scope |

---

## 1. Overview

**Nexus Protocol** is a research initiative building a **Local-First Sovereign Node**. 
Unlike cloud platforms where data and execution are rented, Nexus runs entirely on **your device**. 
You own the execution, the database, and the full transaction history.

**Phase 1.2** introduces the **Gateway Architecture**, unifying local and bridged access into a **single deterministic execution surface**.

> **Core Principle:**
> *The Brain (Backend) is the sole authority. The Body (UI) is a reflection.*

---

## 2. Phase 1.2 Architecture

In Phase 1.2, Nexus operates as a **Reverse Proxy Gateway**. Users interact **only** with the Brain (Port 8000). The Brain internally proxies the UI from the Body (Port 8080).



[Image of a reverse proxy architecture diagram]


```text
        [ USER / BROWSER ]
               |
               | 1. Request http://localhost:8000
               v
+------------------------------+
|   THE BRAIN (Gateway Node)   |  🧠 SOVEREIGN AUTHORITY
|   (FastAPI · Port 8000)      |
+-------------+----------------+
               |
       2. Internal Reverse Proxy
       (Invisible to User)
               |
               v
+------------------------------+
|   THE BODY (Visualizer)      |  📱 STATELESS UI
|   (Flutter · Port 8080)      |
+------------------------------+
```

### 🧩 System Components
1.  **🧠 Brain (FastAPI / Python):** Sole execution authority. Owns all economic logic. Writes to the Vault. Acts as the public web gateway.
2.  **📱 Body (Flutter Web):** Stateless visualization layer. Performs no calculations. Cannot mutate economic state. Uses `tg_bridge` for environment-safe execution.
3.  **💾 Vault (SQLite WAL):** Local-first, crash-safe ledger. Append-only transaction history. Stored as `nexus_vault.db`.

---

## 3. 🚦 Quick Start (Windows)

The fastest way to run a node is via the included automation scripts.

1.  **Start:** Double-click **`start_nexus.bat`**.
2.  **Open:** Visit **`http://localhost:8000`**.
3.  **Stop:** Run **`stop_nexus.bat`**.

*For manual setup or macOS/Linux, see [docs/INSTALL.md](docs/INSTALL.md).*

---

## 4. Economic Primitive — The 60-30-10 Rule

Every transaction processed by the Brain follows a deterministic split:

* **60%** → Creator
* **30%** → Network Pool
* **10%** → Protocol Fee

The rule is hardcoded in Phase 1.2 to guarantee auditability and correctness.

📄 **Full details:** [docs/ECONOMICS.md](docs/ECONOMICS.md)

---

## 5. Project Status & Roadmap

**Current Phase:** `1.2 — ACTIVE`
**Focus:** Gateway Architecture & Environment Consistency.

| Phase | Goal | Status |
| :--- | :--- | :--- |
| **1.1** | Sovereign Foundation | ✅ **Completed** |
| **1.2** | Gateway Node | ✅ **Stable / Active** |
| **1.3** | Hardening & Sentry | 🚧 **Upcoming** |
| **2.0** | Identity Layer | 🔮 **Planned** |

---

## 🛡️ Governance & Safety

* **[Code of Conduct](docs/CODE_OF_CONDUCT.md)** — Community standards
* **[Contributing](docs/CONTRIBUTING.md)** — Phase 1.2 contribution rules
* **[Security Policy](docs/SECURITY.md)** — Vulnerability disclosure & threat scope

---

© 2026 Nexus Protocol · Licensed under the **Apache License 2.0**