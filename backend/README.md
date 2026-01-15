Nexus Backend (Brain) 🧠

The Nexus Backend is the FastAPI-based execution engine (“Brain”) for the Nexus Protocol. It is responsible for enforcing deterministic economic logic, maintaining the local sovereign vault (SQLite), and exposing a minimal, strict API consumed by the Nexus Client (“Body”).

In Phase 1.1, the Brain operates entirely local-first, validating restart-proof execution of the 60-30-10 economic model while emitting non-blocking telemetry to the TON Builders ecosystem for observability.

🚀 Getting Started
Prerequisites

Python 3.10+

pip (Python Package Manager)

Virtual Environment (strongly recommended)

🛠️ Installation
Navigate to the Backend Directory
cd backend

Create and Activate a Virtual Environment
Windows
python -m venv venv
.\venv\Scripts\activate

macOS / Linux
python3 -m venv venv
source venv/bin/activate

Install Dependencies
pip install -r requirements.txt

Run the Server
uvicorn main:app --reload

Access Points

Base URL: http://127.0.0.1:8000

Swagger UI: http://127.0.0.1:8000/docs

🧠 Core Logic and API Endpoints
📡 Automated Startup Heartbeat

On startup, the Brain emits a background heartbeat event to the TON Builders analytics endpoint using a FastAPI lifespan handler.

Observability: Confirms node availability to the TON ecosystem

Non-Blocking: Executed asynchronously; failure has no effect on local execution or ledger state

POST /execute_split/{amount}

Executes the deterministic 60-30-10 economic split.

60% → Creator allocation

30% → User pool

10% → Network fee

Dual-Path Design

Authoritative Path:
Immediate write to nexus_vault.db (SQLite WAL mode)

Observability Path:
Non-blocking background signal sent to TON Builders

GET /ledger

Returns the aggregated ledger state derived from the local vault.

{
  "total_earned": 0.0,
  "global_user_pool": 0.0,
  "protocol_fees": 0.0
}

GET /transactions

Returns the append-only transaction history, bounded to the last 10 entries.

🔐 Security and Infrastructure Model

Local Sovereignty:
All economic state is stored locally. No external service is required to validate or persist execution.

Concurrency Protection:
SQLite operates in WAL mode with an explicit 5-second connection timeout to prevent file locks.

Versioned Schema:
Uses PRAGMA user_version for forward-compatible migrations.

Isolation by Design:
Network or analytics failures cannot block the execution path.

🔮 Roadmap

Phase 1.2: Local Merkle root computation and TON Connect identity

Phase 1.3: Performance benchmarking and external audit

Phase 2.0: Opportunistic mesh synchronization and decentralized settlement

📜 License

© 2026 Nexus Protocol
Licensed under the Apache License 2.0