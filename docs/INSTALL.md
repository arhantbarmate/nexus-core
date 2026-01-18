# 🛠️ Nexus Protocol — Installation & Deployment (v1.3.1)
    
    This guide covers the deployment of the **Nexus Brain (Backend)** and **Nexus Body (Frontend)**. For Phase 1.3.1, the system is optimized for a "Sovereign Node" configuration on Linux.

    ## 🏗️ Deployment Architecture

    

    ```mermaid
    graph LR
        User((User)) -->|Port 8000| Sentry[🛡️ Sentry Guard]
        subgraph Sovereign_Node [Linux Server]
            Sentry -->|Internal Route| Brain[🧠 Nexus Brain]
            Brain -->|Query| Vault[(Nexus Vault)]
            Brain -->|Gateway Proxy| Body[🖥️ Flutter Body :8080]
        end
    ```
    
    ---
    
    ## 1. Prerequisites
    
    * **Hardware:** 1 vCPU, 2GB RAM (Minimum).
    * **OS:** Ubuntu 22.04+ or Debian 11+.
    * **Software:** * Python 3.11+
        * Flutter SDK (Stable)
        * SQLite3
    
    ---
    
    ## 2. Backend Deployment (The Brain)
    
    ### 2.1 Clone and Setup Environment
    
    ```bash
    git clone [https://github.com/arhantbarmate/nexus-core](https://github.com/arhantbarmate/nexus-core)
    cd nexus-core/backend
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    ```
    
    ### 2.2 Configure Security (Sentry)
    Create a `.env` file in the `backend/` directory:
    
    ```env
    # Required for production environments
    BOT_TOKEN=your_telegram_bot_token

    # Environment Toggle (defaults to 'dev' if unset)
    NEXUS_ENV=production
    ```
    
    ### 2.3 Initialize the Vault & Start
    ```bash
    # The Brain automatically initializes the SQLite schema on first run
    uvicorn main:app --host 0.0.0.0 --port 8000
    ```
    
    ---
    
    ## 3. Frontend Deployment (The Body)
    
    ### 3.1 Build & Serve Flutter Web
    The Body is designed to run as an independent service that the Brain proxies.
    ```bash
    cd ../client
    flutter pub get
    flutter build web --release
    # Serve locally on port 8080
    python3 -m http.server 8080 --directory build/web
    ```
    
    ### 3.2 Integration Note
    The Brain operates as a hardened gateway and reverse proxy. It dynamically forwards UI requests to the Body on port `8080` while enforcing the Sentry perimeter on all `/api/*` routes. Accessing the UI through port `8000` ensures all traffic is governed by the Sentry.
    
    ---
    
    ## 4. Verification (CI/CD Alignment)
    
    To ensure your installation is "Hardened" and matches the protocol spec, run the full test suite:
    
    ```bash
    cd ../backend
    pytest tests/test_main.py
    pytest tests/test_gateway.py
    ```
    
    **Expected Outcome:**
    * `test_api_bootstrap`: PASSED
    * `test_sentry_presence`: PASSED (403 on protected routes)
    * `test_ledger_access_unauthorized`: PASSED (403 Forbidden)
    * `test_ledger_access_authorized_ton`: PASSED (200 OK)
    * `test_iotex_staging_denies_execution`: PASSED (403)
    
    ---
    
    ## 5. Production Hardening
    
    For a permanent sovereign node, use **systemd** to ensure the Brain restarts on failure:
    
    ```ini
    [Service]
    ExecStart=/home/user/nexus-core/backend/venv/bin/uvicorn main:app --host 127.0.0.1 --port 8000
    Restart=always
    ```
    
    ---
    
    © 2026 Nexus Protocol · v1.3.1