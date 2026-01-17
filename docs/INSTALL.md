# 🛠️ Nexus Installation Guide (Phase 1.3)

This guide describes how to deploy a **Nexus Protocol Phase 1.3 Hardened Gateway Node** on a local machine.

Phase 1.3 introduces the **Sentry security layer**. Currently, the Sentry logic is staged in the codebase for auditing and pitch-grade evidence, while the execution remains in its stable "Phase 1.2" configuration for development ease.

---

## 1. Deployment Visualization

In Phase 1.3, the architecture remains a single-gateway model. The Sentry is present as a dormant perimeter guard (not yet enforced on startup) within the Brain.



```text
       [ WEB BROWSER / TMA ]
              |
              | 1. Open http://localhost:8000
              |
              v
+------------------------------+
|   TERMINAL 1: THE BRAIN 🧠   |
|   (FastAPI + Sentry Guard)   |  ← HARDENED GATEWAY
+------------------------------+
              |
              | 2. Brain internally proxies UI
              |    from localhost:8080
              v
+------------------------------+
|   TERMINAL 2: THE BODY 📱    |
|   (Flutter Web :8080)        |  ← INTERNAL TARGET
+------------------------------+
```

---

## 2. Prerequisites

Ensure the following are installed:
* **Python 3.9+** (required for the Brain & Sentry)
* **Flutter SDK** (3.x stable) (required for the Body)
* **Git**

Verify installations:
```bash
python --version
flutter --version
git --version
```

---

## 3. Automated Startup (Windows)

For Windows users, use the automation scripts at the repository root for a "One-Click" deployment.

* **`start_nexus.bat`**: Launches the Brain and Body simultaneously.
* **`stop_nexus.bat`**: Gracefully terminates all Nexus services.

---

## 4. Manual Backend Setup (The Brain)

The Brain serves as the host for the **Sentry (Request Validation)** layer.

1.  **Navigate to the backend directory**
    ```bash
    cd backend
    ```
2.  **Install dependencies**
    *No new external libraries are required for the Sentry (uses standard Python hmac/hashlib).*
    ```bash
    pip install -r requirements.txt
    ```
3.  **Start the Gateway (Terminal 1)**
    ```bash
    python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
    ```

**Note:** In this iteration of Phase 1.3, `sentry.py` is present in the directory but is not yet enforced on public routes to allow for unhindered development testing. Enforcement will be enabled explicitly in a future Phase 1.3 iteration once audit and developer testing is complete.

---

## 5. Manual Frontend Setup (The Body)

The Body operates as a **Stateless Observer**.

1.  **Open Terminal 2 and navigate to the client**
    ```bash
    cd client
    ```
2.  **Fetch dependencies**
    ```bash
    flutter pub get
    ```
3.  **Launch the Body**
    ```bash
    flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0 --release
    ```

> **⚠️ Important:** Always access the application via **`http://localhost:8000`**.

---

## 6. Verification Checklist (Phase 1.3 Readiness)

1.  **Directory Check:** Confirm `backend/sentry.py` is present.
2.  **Proxy Check:** Open `http://localhost:8000` — UI should load.
3.  **Vault Check:** Execute a split and confirm the **60-30-10** transition persists in `nexus_vault.db`.
4.  **Header Readiness:** Check Browser DevTools to confirm the Client is ready to inject `X-Nexus-TMA` headers.

---

## 7. Bridge Setup (Optional)

To access the node via a Telegram WebApp:
1.  **Start Ngrok:** `ngrok http 8000`
2.  **Configure Bot:** Point your Telegram Bot's WebApp URL to the Ngrok HTTPS link.
3.  **Verification:** The Sentry is now positioned to validate incoming TMA signatures.

---

## 8. Troubleshooting

* **Sentry Module Errors:** Ensure `sentry.py` is in the same directory as `main.py`.
* **Port Conflict:** Ensure no other services are using 8000 or 8080.
* **Resetting the Vault:** Stop the Brain and delete `backend/nexus_vault.db`.

---

© 2026 Nexus Protocol | Apache License 2.0