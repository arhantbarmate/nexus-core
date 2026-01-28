# 🛠️ Node Setup Guide — Nexus Protocol
**Coreframe Systems Lab | Version 1.4.0**

This guide provides the technical sequence required to deploy a **Sovereign Nexus Node** on local hardware. The architecture is optimized for low-latency, durability-first local execution.

---

## 📋 Act I: Prerequisites
Before ignition, ensure your machine meets the following baseline requirements:
* **Docker Desktop:** (Recommended) For containerized isolation.
* **Python 3.10+:** With System Path enabled.
* **Git:** For protocol versioning.
* **Tunnel Token:** A Cloudflare Zero Trust token (**Note:** Ngrok is deprecated and supported only for legacy development).

---

## 🚀 Act II: Deployment Sequence

### 1. Secure the Perimeter
Clone the repository and prepare your environment. **Never share your .env file.**
```bash
# Clone the Coreframe repository
git clone https://github.com/arhantbarmate/nexus-core.git
cd nexus-core

# Create your secret vault (Configuration)
copy .env.example .env
```
*Open ```.env``` and paste your Cloudflare Token. If you do not have a token, you can still run in **Simulation Mode** (Localhost).*

### 2. Ignite the Node
We provide a **Sovereign Master Controller** to manage the lifecycle of the Sentry, Brain, and Vault layers.

> **Note:** ```start_nexus.bat``` is the Windows controller. Linux/macOS users should utilize ```./start_nexus.sh```.

```bash
# Run the Master Controller
start_nexus.bat
```
**Select Option 1** for Production (Tunnel) or **Option 3** for Dev Simulation (Localhost). The controller will automatically handle dependency resolution and vault initialization.



### 3. Deploy the Surface (UI)
If you are an engineer compiling the Body from source:
```bash
cd client
flutter build web --release --base-href "/"
```

---

## 🧪 Act III: Verification Protocol
Once the node status is `NOMINAL`, perform an **Integrity Audit**:

1. **The Brain:** Navigate to ```http://localhost:8000/docs``` to verify the OpenAPI schema.
2. **The Ingress:** Access your public URL (e.g., coreframe.systems) or localhost to verify the handshake.
3. **The Vault:** Run the **1-Million Transaction Stress Test** to verify write-durability:
   ```bash
   python scripts/stress_test_1m.py
   ```

---

## 🛡️ Hardening & Troubleshooting
* **Antivirus Friction:** On Windows, exclude the ```nexus-core``` directory from **Real-Time Protection** to prevent I/O delays during high-frequency writes.
* **Ghost Directories (Filesystem Collision):** If you encounter a "Mount Error," it is often due to a directory being created where a file was expected. Run **Option 1** in the controller to auto-heal the vault path.
* **Identity Sync:** If the Execution Surface (UI) fails to load, verify that your ```TUNNEL_TOKEN``` in the ```.env``` is valid and active.

---
© 2026 Coreframe Systems · Installation Specification v1.4.0  
*Designed for sovereign operators. Built for durability.*
