# 🏛️ System Architecture — Nexus Protocol (v1.3.1)

The Nexus Protocol is a **Sovereign Edge Gateway** architected for the DePIN ecosystem. It operates on a **Verify-then-Execute** model, ensuring that economic state transitions are only committed after environmental resolution.

---

## 🛰️ High-Level Logic Flow
The following sequence defines the "Fail-Closed" lifecycle of a Nexus transaction:



```mermaid
sequenceDiagram
    participant U as UI (Execution Surface)
    participant S as Sentry (Bridge)
    participant B as Brain (FastAPI)
    participant V as Vault (SQLite)

    U->>S: Action Trigger (e.g., Execute Split)
    S->>S: Extract Environment Context (initData)
    S->>B: POST /api/execute_split (Context + Payload)
    B->>B: Resolve Identity Context (Sentry Guard)
    alt Verified
        B->>V: Commit 60/30/10 Ledger Entry
        V-->>B: Success (WAL Mode)
        B-->>U: State Updated (JSON)
    else Rejected
        B-->>U: Rejection Response
    end
```

---

## 🧠 The Brain (Persistence & Logic)
The backend is a **Unidirectional State Machine** built with FastAPI and SQLite.
* **Concurrency:** Utilizes **Write-Ahead Logging (WAL)** mode. Successfully verified under a **1-Million Transaction stress test** with no observed data corruption or write collisions.
* **Ledger Invariant:** Every incoming credit is strictly bifurcated via the **60/30/10 Protocol**:
    * **60% Creator:** Direct node/content settlement.
    * **30% User Pool:** Community redistribution.
    * **10% Network Fee:** Protocol maintenance.

## 📱 The Body (Interface & Sentry)
The frontend is a Flutter-based **Execution Surface** that interacts with the Brain through the **Sentry Bridge (Identity Perimeter)**.
* **Identity Rails:** Supports Telegram WebApp ```initData``` for containerized environments and a **Sovereign Backup-ID Bridge** for local simulation/recovery.
* **Structural Isolation:** Compiled with ```base-href /nexus-core/app/``` to ensure clean pathing behind the Sovereign Gateway.

---

## 🛡️ Infrastructure Sovereignty
* **Tunneling Resilience:** Implements header-based and static-gateway handling to bypass Ngrok free-tier interstitial interruptions, ensuring seamless headless handshakes for Telegram Mini Apps.
* **Local-First Hardware:** Optimized for low-power edge hardware (Standard PC/SBC) to maintain data ownership and local state verification.

---

© 2026 Nexus Protocol · Architecture Specification v1.3.1
