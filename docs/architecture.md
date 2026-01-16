# Nexus Protocol — Technical Architecture (Phase 1.2)

This document describes the **Gateway Architecture** of Nexus Protocol Phase 1.2.

It explains how the system achieves environment-consistent execution across **Localhost**, **Ngrok bridge**, and **Telegram WebApp**—while preserving a single sovereign execution authority.

---

## 1. Architectural Philosophy: The Gateway Model

In Phase 1.2, Nexus transitions from a side-by-side service layout to a **Brain-First Gateway Model**.

**Core principles:**

1.  **Single Public Interface**
    All external traffic targets the Brain (**Port 8000**) only.

2.  **Hidden UI Layer**
    The Body (**Port 8080**) is never exposed directly and is accessible *only* through the Brain’s reverse proxy.

3.  **Authority Enforcement**
    All economic execution is centralized in the Brain, preventing UI-level drift or desynchronization.

This model ensures **one ledger, one execution path, one authority**.

---

## 2. High-Level Architecture

The system enforces a **one-way dependency**: the Body depends on the Brain; the Brain is sovereign.

```text
       [ USER / INTERNET ]
              |
              |  (Connects to :8000)
              v
+------------------------------------------+
|          🧠 NEXUS BRAIN (GATEWAY)         |
|------------------------------------------|
|  1. Inspect Incoming Request             |
|  2. Route Based on Path                  |
|                                          |
|    /api/* /* |
|      |                    |              |
|      v                    v              |
|  +--------------+    +---------------+  |
|  |  ECONOMIC    |    |  REVERSE      |  |
|  |  LOGIC       |    |  PROXY        |  |
|  +------+-------+    +-------+-------+  |
|         |                    |          |
|         | (Writes)           | (Fetches)|
|         v                    v          |
|  [ NEXUS_VAULT ]     [ FLUTTER BODY ]    |
|   (SQLite WAL)        (localhost:8080)  |
+------------------------------------------+
```

---

## 3. Component Breakdown

### 3.1 The Brain — Sovereign Gateway (FastAPI)
**Role:** The single source of truth and traffic controller.

**Responsibilities:**
* **Reverse Proxy:** Routes all non-API requests to the internal Body service.
* **Request Inspection:** Distinguishes economic execution from UI delivery.
* **Header Sanitization:** Prevents recursive proxy loops and unsafe header propagation.
* **Unified Namespace:** Enforces a shared ledger namespace (`NEXUS_DEV_001`) to prevent environment-based state divergence.
* **Atomic Execution:** Applies deterministic **60-30-10** logic before committing to the Vault.

### 3.2 The Vault — Persistent Ledger (SQLite)
**Role:** The authoritative economic record.

**Properties:**
* **SQLite with WAL Mode:** Ensures atomic commits and non-blocking writes.
* **Local-First Storage:** All balances and transactions reside locally on the node.
* **Single Ledger Source:** There is no client-side or replicated database in Phase 1.2.

### 3.3 The Body — Stateless Proxy Target (Flutter)
**Role:** A passive UI layer with no authority.

**Characteristics:**
* **Proxy-Only Access:** Listens on Port 8080 and serves requests originating from the Brain.
* **Environment Awareness:** Adjusts API base paths depending on execution context:
    * *Local:* `http://127.0.0.1:8000/api`
    * *Bridged/Hosted:* `/api`
* **Platform Guarding:** Uses conditional imports (`platform_stub.dart`, `platform_js.dart`) to safely run inside or outside Telegram.

> **The Body cannot mutate state or bypass the Brain.**

---

## 4. Data Flow & Security

### 4.1 Deterministic Execution Path (“Happy Path”)
1.  User enters an amount in the UI.
2.  Body sends `POST /api/execute_split/{amount}`.
3.  Brain calculates deterministic shares (60 / 30 / 10).
4.  Brain commits the transaction to `nexus_vault.db`.
5.  Brain returns `200 OK`.
6.  Body refreshes its displayed state.

*At no point does the client calculate or persist economic data.*

### 4.2 Security Constraints (Phase 1.2)
* **Isolation:** The Body has zero write access to the Vault.
* **No Cryptographic Identity:** No keys, signatures, or verification logic are present in this phase.
* **Local Sovereignty:** Data remains on the node unless the user explicitly exposes it via a bridge (e.g., Ngrok).
* **Scope Discipline:** All enforcement relies on architecture, not cryptography, in Phase 1.2.

---

## 5. Forward-Looking Anchoring (Phase 2.0+)
> *The following section is future-tense and not implemented.*

Planned Phase 2.0 evolution:
1.  Client-side request signing (Ed25519).
2.  Brain-side signature verification.
3.  Execution gated on cryptographic validity.

This will upgrade the Gateway from **architectural authority** to **cryptographic authority**.

---

© 2026 Nexus Protocol