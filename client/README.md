# Nexus Client (Body) 📱

The Nexus Client is the Flutter-based user interface (“Body”) for the Nexus Protocol.
It provides real-time visualization and interaction with the local Nexus execution engine (“Brain”).

This client is **intentionally local-first** and communicates with a locally running FastAPI backend.

## 🚀 Getting Started

These instructions allow you to run the Nexus Client locally for development, testing, and demonstration.

### Prerequisites

* **Flutter SDK** (Stable, 3.x or higher)
* **Dart SDK** (bundled with Flutter)
* **Desktop Target Enabled** (Windows / macOS / Linux)
* **A running Nexus Backend** (e.g., `uvicorn main:app --reload`)

### 🛠️ Installation

1.  **Navigate to the Client Directory**
    ```bash
    cd client
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run the Client (Desktop)**
    ```bash
    flutter run -d windows
    # Note: Use -d macos or -d linux if you are on those platforms
    ```

    The client expects the backend to be available at:
    `http://127.0.0.1:8000`

## 🧭 Application Behavior

* **Displays Creator Balance:** Shows the 60% allocation in real-time.
* **Split Execution:** Accepts a numeric input for executing the **60-30-10** split.
* **Transaction History:** Shows persistent transaction logs.
* **State Sync:** Reflects backend state immediately after restart.

> **Note:** All economic logic is enforced server-side by the Nexus Brain.

## 📂 Project Structure

```text
client/
├── lib/
│   └── main.dart        # Application entry point
├── pubspec.yaml         # Flutter dependencies
└── README.md            # This file
The client is intentionally minimal in Phase 1.1 to prioritize:

Deterministic behavior

Clear auditability

Grant reviewer usability

🔐 Security Model (Phase 1.1)
No private keys are handled by the client.

No data is transmitted to third-party servers.

All state is sourced from the local Nexus Vault (SQLite).

TON Connect integration is planned for Phase 1.2.

🧪 Testing
Basic UI and integration testing can be run with:

Bash

flutter test
(Advanced testing and benchmarking are planned for Phase 1.3.)

🔮 Roadmap
Phase 1.2: TON Connect Identity + Merkle-Anchored State

Phase 1.3: Performance benchmarking and external audit

Phase 2.0: Opportunistic mesh synchronization

© 2026 Nexus Protocol Licensed under Apache License 2.0