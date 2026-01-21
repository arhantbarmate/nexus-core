# 🛠️ Node Setup Guide — Nexus Protocol (v1.3.1)

This guide provides the technical sequence required to deploy a **Sovereign Nexus Node** on local hardware. 

---

## 📋 Prerequisites
* **Python 3.10+** (System Path enabled)
* **Git**
* **Ngrok Account** (For the $0-cost Sovereign Stack)
* **Flutter SDK** (If compiling the Execution Surface from source)

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

# Install Dependencies
pip install -r requirements.txt
```

---

## ⚡ 2. Automated Node Management
We provide specialized batch scripts to manage the lifecycle of the **Sentry**, **Brain**, and **Tunnel** layers simultaneously.

### Start the Sovereign Node
This script initializes the FastAPI Brain, starts the Ngrok tunnel, and bypasses the interstitial warning via the Sentry Bridge.
```bash
./start_nexus.bat
```

### Stop the Sovereign Node
To safely terminate all background processes and close the tunnels:
```bash
./stop_nexus.bat
```

> [!NOTE]
> The start/stop scripts are optimized for rapid development, testing, and grant evaluation. Production orchestration (e.g., systemd, Docker, or K8s) is a deferred phase concern.

---

## 📱 3. Launching the Execution Surface (Client)
The Flutter Body must be compiled with the correct base-href to align with the Gateway architecture.

```bash
cd client
flutter build web --release --base-href /nexus-core/app/
```

---

## 🧪 4. Verification Checklist
Once the node is active, verify the following endpoints:

1. **The Brain:** Navigate to ```http://localhost:8000/docs``` (Swagger UI).
2. **The Sentry:** Ensure the Ngrok URL is reachable and redirects through the Sentry Bridge.
3. **The Ledger:** Run a test split via the CLI:
   ```bash
   python scripts/test_concurrency.py --users 5
   ```

---

## 🛡️ Troubleshooting
* **Database Locks:** Ensure no other process is accessing ```nexus_vault.db```. The system uses **WAL mode** to prevent this.
* **Ngrok Handshake:** If the TMA fails to load, verify the ```ngrok-skip-browser-warning``` header logic in your `Sentry Bridge`.

---

© 2026 Nexus Protocol · Installation Specification v1.3.1
