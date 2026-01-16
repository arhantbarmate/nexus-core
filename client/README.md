# 📱 Nexus Client (Stateless Body v1.2)

The **Nexus Client (Body)** is a high-performance, stateless user interface for the Nexus Protocol.

The Body has **zero economic authority**.
- It does not calculate balances.
- It does not persist state.
- It does not own data.

All economic logic is executed by the **Sovereign Brain** and exposed via a gateway.

---

## 📌 Phase Status

- **Phase 1.1:** Platform guarding & local mocking — **Closed**
- **Phase 1.2:** Proxy target & dynamic routing — **Current**

> *Note: No client-side signing, identity, or mesh logic exists in this phase.*

---

## 🏗️ Architecture: Proxy Target Model (Phase 1.2)

In Phase 1.2, the Body runs on **Port 8080**, but it is never accessed directly by users. All UI traffic flows through the Brain.

```mermaid
graph TD
    User((User)) -->|Visits :8000| Brain[🧠 Brain (Gateway)]
    Brain -->|Proxy Fetch| Body[📱 Body :8080]
    Body -->|HTML / JS| Brain
    Brain -->|Served UI| User
```

### Key Properties
1.  The Brain is the **only** public interface.
2.  The Body is a **proxy target only**.
3.  The Body cannot bypass the Brain.

---

## ⚡ Phase 1.2 Capabilities

### Environment-Aware Routing
The client automatically adapts its API base path:

* **Local execution:** `http://127.0.0.1:8000/api`
* **Bridged / Hosted execution:** Relative path `/api`

This allows the same build to function correctly across:
* Local browser
* Telegram WebApp
* Ngrok bridge

### Platform Guarding
Conditional imports are used to ensure safe compilation across environments:

* `platform_stub.dart` — Desktop / non-Telegram
* `platform_js.dart` — Telegram WebApp (Web only)

This prevents runtime crashes such as: `ReferenceError: Telegram is not defined`.

---

## 🚀 Quick Start

### Prerequisites
* Flutter SDK (3.x stable)
* A running Nexus Brain on port 8000

### Installation

```bash
cd client
flutter pub get
```

### Launch the Body (Proxy Mode)

```bash
# MUST run on port 8080
flutter run -d web-server \
  --web-port 8080 \
  --web-hostname 0.0.0.0 \
  --release
```

> **⚠️ Important:**
> * Do not open `http://localhost:8080` directly.
> * Always access the application via: **`http://localhost:8000`**

---

## 🧭 Application Behavior

### 🟢 Liveness Indicator
A real-time heartbeat indicator validates connectivity with the Brain:
* **Green** → Brain reachable (Gateway active)
* **Red** → Brain offline or proxy misconfigured

### 🔢 Deterministic Input
The client provides a hardened numeric input for split execution.
* The client sends **intent only**.
* The Brain performs all calculations.
* The Vault is updated exclusively server-side.

### 🚫 Stateless UI Guarantees
* No ledger data stored in browser storage.
* No caching of economic state.
* Clearing browser data does not affect balances (All persistence lives in the Brain’s vault).

---

## 🔐 Security & Isolation Model

### 1. Zero Authority UI
The Body cannot:
* Write to the database.
* Compute economic values.
* Modify ledger state.

### 2. Proxy Discipline
* All requests flow through the Brain.
* The client does not call external APIs directly.

### 3. Scope Discipline
* No private keys.
* No cryptographic signing.
* No peer-to-peer logic.
*(These are explicitly deferred)*.

---

## 🧭 Roadmap Alignment

- [x] **Phase 1.1** — Platform guarding & local mocking (Closed)
- [x] **Phase 1.2** — **Proxy target & dynamic routing (Current)**
- [ ] **Phase 2.0** — Client-side request signing (Ed25519)
- [ ] **Phase 3.0** — Mesh visualization & relay UI

---

### 📜 License
**© 2026 Nexus Protocol**

Licensed under the Apache License 2.0