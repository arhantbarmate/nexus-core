# 🛠️ Node Setup Guide — Nexus Protocol (v1.3.1)

This guide provides the technical sequence required to deploy a **Sovereign Nexus Node** on local hardware. The architecture is optimized for low-latency, durability-first local execution.

---

## 📋 Prerequisites
* **Python 3.10+** (System Path enabled)
* **Git**
* **Ngrok Account** (For the $0-cost Sovereign Stack)
* **Flutter SDK 3.38.6 Stable** (If compiling the Body from source)

---

## 🚀 1. Clone & Environment Setup
Initialize the repository and isolate the Python environment.

```bash
# Clone the repository
git clone https://github.com/arhantbarmate/nexus-core.git
cd nexus-core

# Setup Virtual Environment
python -m venv venv

# Activate Environment
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Install Core & Protocol Dependencies
pip install -r requirements.txt
```

---

## ⚡ 2. Automated Node Management
We provide specialized scripts to manage the lifecycle of the **Sentry**, **Brain**, and **Tunnel** layers. In Phase 1.3.1, the Gateway serves the UI as static assets; no separate frontend server is required.

### Start the Sovereign Node
This script initializes the FastAPI Brain, starts the Ngrok tunnel, and resolves the identity perimeter.
```bash
# Follow the interactive prompts for Ngrok URL input
./start_nexus.bat
```

### Stop the Sovereign Node
To safely terminate background processes and flush the WAL journal:
```bash
./stop_nexus.bat
```

---

## 📱 3. Launching the Execution Surface (Client)
The Flutter Body must be compiled with the correct ```base-href``` to align with the Gateway architecture.



```bash
cd client
flutter build web --release --base-href "/nexus-core/app/" --no-tree-shake-icons
```

---

## 🧪 4. Verification Checklist
Once the node is active, perform a **Stability Audit**:

1. **The Brain:** Access ```http://localhost:8000/docs``` to verify the OpenAPI schema.
2. **The Sentry:** Verify the Ngrok URL bypasses the interstitial via header injection.
3. **The Ledger:** Run the 1-Million Transaction Stress Test to verify write-durability:
   ```bash
   python scripts/stress_test_1m.py
   ```

---

## 🛡️ Troubleshooting & Hardening
* **I/O Bottlenecks:** On Windows, exclude the project directory from **Real-Time Antivirus Protection** to maintain stable TPS during high-load writes.
* **Database Contention:** Ensure the ```nexus_vault.db``` is not locked by external viewers; the system enforces **WAL mode** for concurrent access.
* **Identity Resolution:** If the UI fails to sync, ensure the ```initData``` from the host container is being correctly forwarded to the Brain.

---

© 2026 Nexus Protocol · Installation Specification v1.3.1
