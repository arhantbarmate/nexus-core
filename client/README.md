Nexus Client (Body) 📱

The Nexus Client is a high-performance Flutter-based user interface (“Body”) for the Nexus Protocol.

It provides real-time visualization and interaction with the local sovereign execution engine (“Brain”) while remaining strictly local-first in Phase 1.1.

The client is environment-aware, allowing it to run seamlessly as a standalone desktop or web application while remaining ready for future Telegram Mini App (TMA) integration.

🚀 Architectural Innovation: Platform Guarding

To resolve the constraints of running a blockchain-integrated application across multiple environments, the Nexus Client uses a Custom Stubbing Pattern.

Universal Compatibility

Compiles for Web and Desktop without requiring the Telegram WebApp SDK at runtime

Avoids platform-specific crashes during local development and testing

Platform Stubs

Uses conditional imports to mock environment-specific behavior

Safely handles Telegram WebApp and TON Connect APIs when running outside Telegram

Prevents runtime dependency failures on Windows, macOS, Linux, and Web

Sovereign Mock Mode

Automatically activates when no external context is detected

Ensures the 60-30-10 split protocol remains fully functional

Preserves local-first execution under all conditions

🛠️ Getting Started
Prerequisites

Flutter SDK (Stable, 3.x or higher)

Dart SDK (bundled with Flutter)

Desktop or Web target enabled

A running Nexus Backend (FastAPI on port 8000)

Installation & Launch
Navigate and Fetch Dependencies
cd client
flutter pub get

Sovereign Launch (Web)
flutter run -d web-server --web-port 5000 --release


Open the client in your browser at:

http://localhost:5000


The client expects the backend to be available at:

http://127.0.0.1:8000

🧭 Application Behavior

Liveness Indicator
Real-time heartbeat monitor (Green / Red) validating connectivity between the UI (Body) and the Sovereign Vault (Brain)

Deterministic Split Input
Hardened numeric input field for executing the 60-30-10 split protocol

Vault Visualization
Persistent table displaying the last 10 local split events, sourced directly from the SQLite vault

Zero-Knowledge UI
The client never calculates economic logic and never mutates state independently
It acts purely as a visual “window” into the backend’s deterministic execution

🔐 Security Model (Phase 1.1)

Vault Isolation
No private data is cached in the browser or local storage
All state is fetched on-demand from the backend

Local-First Privacy
All interaction is restricted to localhost, preventing third-party data leakage

Handshake Discipline
Communication with the Brain uses standardized request headers
Only authorized local requests can mutate vault state

🧪 Testing

Basic widget and integration tests can be run with:

flutter test


Advanced performance benchmarking and stress testing are planned for Phase 1.3.

🔮 Roadmap

Phase 1.2 — TON Connect v2 integration and Merkle-anchored state commits

Phase 1.3 — Performance stress-testing and UI/UX audit for Telegram users

Phase 2.0 — Decentralized peer-to-peer synchronization between sovereign nodes

📜 License

© 2026 Nexus Protocol
Licensed under the Apache License 2.0