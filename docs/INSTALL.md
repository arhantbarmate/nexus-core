# 🛠️ Nexus Installation Guide (Phase 1.2)

This guide describes how to deploy a **Nexus Protocol Phase 1.2 Gateway Node** on a local machine.

Phase 1.2 introduces the **Gateway Architecture**, where the Brain (backend) acts as the single public interface and reverse proxy for the Body (frontend).

---

## 1. Deployment Visualization

In Phase 1.2, two services run in parallel, but **only one port is accessed by the user**.

```text
       [ WEB BROWSER ]
              |
              | 1. Open http://localhost:8000
              |
              v
+------------------------------+
|  TERMINAL 1: THE BRAIN 🧠    |
|  (Uvicorn / FastAPI :8000)   |  ← PUBLIC GATEWAY
+------------------------------+
              |
              | 2. Brain internally proxies UI
              |    from localhost:8080
              v
+------------------------------+
|  TERMINAL 2: THE BODY 📱     |
|  (Flutter Web :8080)         |  ← INTERNAL TARGET
+------------------------------+
```

**The Body is never accessed directly.**

---

## 2. Prerequisites

Ensure the following are installed:
* **Python 3.9+** (required for the Brain)
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

For Windows users, automation scripts are provided at the repository root.

### Scripts
* **`start_nexus.bat`**
    * Launches the Brain
    * Launches the Body
    * Optionally launches Ngrok (if configured)
* **`stop_nexus.bat`**
    * Gracefully terminates all Nexus processes

*This is the recommended startup method on Windows.*

---

## 4. Manual Backend Setup (The Brain)

The Brain must be started **first**, as it serves as the gateway.

1.  **Navigate to the backend directory**
    ```bash
    cd backend
    ```
2.  **Install dependencies**
    ```bash
    pip install -r requirements.txt
    ```
3.  **Start the Gateway (Terminal 1)**
    ```bash
    # Must bind to 0.0.0.0 for bridge compatibility
    python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
    ```

The Brain is now active at: **`http://localhost:8000`**

---

## 5. Manual Frontend Setup (The Body)

In Phase 1.2, the Body runs in **Proxy Mode**.

1.  **Open a second terminal and navigate to the client**
    ```bash
    cd client
    ```
2.  **Fetch dependencies**
    ```bash
    flutter pub get
    ```
3.  **Launch the Body (Terminal 2)**
    ```bash
    # MUST run on port 8080
    flutter run -d web-server \
      --web-port 8080 \
      --web-hostname 0.0.0.0 \
      --release
    ```

> **⚠️ Important:**
> * Do not open `http://localhost:8080`
> * Always access the application via: **`http://localhost:8000`**

---

## 6. Verification Checklist

Confirm correct Phase 1.2 operation:

1.  Open `http://localhost:8000` — Flutter UI should load.
2.  Verify the **Heartbeat indicator** is green.
3.  Execute a split (e.g., enter `100`).
4.  Restart the Brain.
5.  Reload the page and confirm the transaction persists.

This validates:
* Proxy routing
* Vault persistence
* Gateway authority

---

## 7. Bridge Setup (Optional)

To access the node remotely (mobile or Telegram WebApp):

1.  **Install Ngrok:** Download from [ngrok.com](https://ngrok.com).
2.  **Start a tunnel:**
    ```bash
    # Always point Ngrok to the Brain only
    ngrok http 8000
    ```
3.  **Access the generated HTTPS URL.**
    * The Brain will proxy the UI automatically.
    * No additional configuration is required on the client.

---

## 8. Troubleshooting

* **Brain Disconnected (Red Indicator):**
    * Ensure FastAPI is running on port 8000.
    * Confirm no other service is occupying the port.

* **UI Not Loading at :8000:**
    * Verify Flutter is running on port 8080.
    * Check Brain logs for proxy errors.

* **Resetting State:**
    * To reset all local data:
        1. Stop the Brain.
        2. Delete `backend/nexus_vault.db`.
        3. Restart the Brain.

---

© 2026 Nexus Protocol

Licensed under the **Apache License 2.0**