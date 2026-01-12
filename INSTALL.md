# Nexus Installation Guide

This guide walks you through running the Nexus Protocol Phase 1.1 prototype locally.

## Prerequisites
Ensure the following are installed on your system:
- **Python 3.10+**
- **Flutter SDK (Stable Channel)**
- **Git**

Verify installations:
```bash
python --version
flutter --version
git --version
1. Backend Setup (FastAPI – “Brain”)
Navigate to the backend directory:

Bash

cd backend
Install Python dependencies:

Bash

pip install -r requirements.txt
Start the FastAPI server:

Bash

uvicorn main:app --reload
Backend will be available at: http://127.0.0.1:8000

Keep this terminal running.

2. Frontend Setup (Flutter – “Body”)
Open a new terminal and navigate to the client directory:

Bash

cd client
Fetch Flutter dependencies:

Bash

flutter pub get
Run the desktop application:

Bash

flutter run -d windows
The Nexus Dashboard should now launch.

3. Verification Checklist
After both services are running:

Execute a transaction using the dashboard.

Confirm the file below is created automatically:

Plaintext

backend/nexus_vault.db
Restart the backend server and verify:

Ledger values persist.

Transaction history remains intact.

This confirms SQLite-backed persistence is functioning correctly.

Troubleshooting
Ensure the backend is running before launching the frontend.

If ports are blocked, verify nothing else is using port 8000.

To reset state, delete backend/nexus_vault.db and restart the backend.

© 2026 Nexus Protocol

Licensed under Apache License 2.0