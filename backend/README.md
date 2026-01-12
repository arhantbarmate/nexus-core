# Nexus Backend (Brain) 🧠

The Nexus Backend is the FastAPI-based execution engine (“Brain”) for the Nexus Protocol.

It enforces deterministic economic logic, manages the local sovereign vault (SQLite), and exposes a strict API consumed by the Nexus Client (“Body”).

In **Phase 1.1**, the backend runs entirely local-first to validate restart-proof execution of the **60-30-10** economic model.

## 🚀 Getting Started

These instructions allow you to run the Nexus Brain locally.

### Prerequisites

* **Python 3.10+**
* **pip** (Python Package Manager)
* **Virtual Environment** (Recommended)

### 🛠️ Installation

1.  **Navigate to the Backend Directory**
    ```bash
    cd backend
    ```

2.  **Create & Activate Virtual Environment**
    * **Windows:**
        ```bash
        python -m venv venv
        .\venv\Scripts\activate
        ```
    * **macOS / Linux:**
        ```bash
        python3 -m venv venv
        source venv/bin/activate
        ```

3.  **Install Dependencies**
    ```bash
    pip install -r requirements.txt
    ```

4.  **Run the Server**
    ```bash
    uvicorn main:app --reload
    ```
    
    The API will be available at:
    * **Base URL:** `http://127.0.0.1:8000`
    * **Swagger Docs:** `http://127.0.0.1:8000/docs`

## 🧠 Core Logic & API Endpoints

The Brain is the sole authority for enforcing the Nexus Protocol’s **60-30-10** split.

### POST /execute_split/{amount}
Executes a deterministic economic split.
* **60%** → Creator allocation
* **30%** → User pool
* **10%** → Network fee

**Validation:**
* Rejects zero or negative amounts
* Rounds values deterministically
* Appends immutable transaction record

### GET /ledger
Returns the authoritative aggregated ledger state:
```json
{
  "total_earned": 0.0,
  "global_user_pool": 0.0,
  "protocol_fees": 0.0
}
GET /transactions
Returns the append-only transaction history stored in the local vault.

📂 Project Structure
Plaintext

backend/
├── main.py              # FastAPI app, routes, and split logic
├── nexus_vault.db       # SQLite vault (auto-created at runtime)
├── requirements.txt     # Python dependencies
└── README.md            # This file
🔐 Security Model (Phase 1.1)
Local Sovereignty: All data is stored in nexus_vault.db on the user’s machine.

Deterministic Enforcement: Economic logic is executed server-side only.

Isolation: No external services or blockchain dependencies in this phase.

Restart Safety: Ledger state survives full process termination.

🔮 Roadmap
Phase 1.2: TON Connect identity + Merkle-anchored state commitments

Phase 1.3: Performance benchmarking & external audit

Phase 2.0: Opportunistic mesh synchronization & decentralized settlement

© 2026 Nexus Protocol Licensed under Apache License 2.0