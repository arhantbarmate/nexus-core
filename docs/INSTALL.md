# 🛠️ Nexus Installation Guide (Phase 1.1)

This guide walks you through the steps to deploy the **Nexus Protocol Phase 1.1** prototype on your local machine.

---

## 1. Prerequisites
Before beginning, ensure your environment meets the following requirements:
* **Python 3.10+** (Required for the FastAPI Brain)
* **Flutter SDK** (Stable Channel - Required for the Desktop Body)
* **Git** (For version control)

Verify your installations:
```bash
python --version
flutter --version
git --version
```

---

## 2. Automated Startup (Windows Preferred)
For the fastest setup on Windows, use the automation scripts located in the root directory:

* **`start_nexus.bat`**: Automatically installs Python dependencies and launches both the Brain (FastAPI) and Body (Flutter) in separate terminal windows.
* **`stop_nexus.bat`**: Safely terminates all running Nexus-related processes (Python, Uvicorn, Dart/Flutter).

---

## 3. Manual Backend Setup (The "Brain")
If you are on Linux/macOS or prefer manual control, follow these steps:

1.  **Navigate to the backend directory:**
    ```bash
    cd backend
    ```
2.  **Install dependencies:**
    ```bash
    pip install -r requirements.txt
    ```
3.  **Start the server:**
    ```bash
    uvicorn main:app --reload
    ```
*The Brain is now active at:* `http://127.0.0.1:8000`

---

## 4. Manual Frontend Setup (The "Body")
1.  **Open a new terminal and navigate to the client directory:**
    ```bash
    cd client
    ```
2.  **Fetch dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Launch the application:**
    ```bash
    flutter run -d windows
    ```
*(For Linux/macOS users, use `-d linux` or `-d macos` accordingly).*

---

## 5. Verification Checklist
Once both services are running, perform these steps to confirm **Phase 1.1 Hardening**:

1.  **Execute an Action:** Trigger a transaction via the Flutter Dashboard.
2.  **Verify Persistence:** Confirm the file `backend/nexus_vault.db` is created automatically.
3.  **Persistence Test:** Restart the backend terminal. Re-open the dashboard and verify that all balances and transaction history remain intact.



---

## 6. Troubleshooting
* **Connection Error:** Ensure the backend is running on port `8000` before starting the frontend.
* **Port Conflict:** If port 8000 is occupied, you can change the port using `uvicorn main:app --port XXXX` and update the API URL in the Flutter config.
* **Resetting State:** To clear all data, delete `backend/nexus_vault.db` and restart the Brain.

---

© 2026 Nexus Protocol  
Licensed under the **Apache License 2.0**