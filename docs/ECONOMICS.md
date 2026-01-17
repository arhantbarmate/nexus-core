# Nexus Protocol — Economic Model (Phase 1.2)

This document defines the deterministic **60-30-10 economic split** implemented in Nexus Protocol Phase 1.2.

The model is intentionally fixed and minimal at this stage to validate:
1.  **Correctness**
2.  **Auditability**
3.  **Persistence**
4.  **Architectural enforcement**

...before introducing governance, adaptability, or cryptographic controls.

---

## 1. Design Goals

The Phase 1.2 economic model is designed around four primary objectives:

1.  **Creator Incentivization** — direct, predictable rewards.
2.  **User Participation** — pooled value for future distribution logic.
3.  **Protocol Sustainability** — reserved infrastructure funding.
4.  **Deterministic Auditability** — zero-trust, replayable verification.

At this phase, **stability and clarity take precedence over flexibility**.

---

## 2. The 60-30-10 Allocation

Every economic event executed by the **Sovereign Brain** is split deterministically:

-   **60% — Creator Allocation**
-   **30% — User Pool**
-   **10% — Network Fee**

*These ratios are hardcoded and non-configurable in Phase 1.2.*

### 2.1 Creator Allocation (60%)
Allocating the majority of value to creators ensures:
-   Strong incentives for contribution or content creation.
-   Clear ownership of value at the node edge.
-   Predictable and explainable outcomes.

This mirrors creator-economy dynamics while remaining **enforceable at the protocol layer**, not the UI.

### 2.2 User Pool (30%)
The user pool represents collectively tracked value intended for:
-   Future participation or engagement mechanisms.
-   Incentive distribution experiments in later phases.
-   Network effect validation.

**In Phase 1.2:**
-   The pool is accounted for in the Vault.
-   **No distribution or claim logic exists yet.**
-   The objective is to validate ledger correctness, not reward mechanics.

### 2.3 Network Fee (10%)
The network fee is reserved for future protocol costs, including:
-   Infrastructure operation.
-   Synchronization or anchoring expenses.
-   Relay or settlement mechanisms in later phases.

**In Phase 1.2, this value is tracked only and not consumed or routed.**

---

## 3. Execution & Enforcement (Visualized)

In Phase 1.2, the **Brain (Port 8000)** is the sole economic authority.

```text
       [ INPUT ]                  [ PROCESSING ]                  [ STORAGE ]
      (User Intent)            (Deterministic Logic)            (Immutable State)

+---------------------+     +-------------------------+     +----------------------+
|    BODY (UI)        |     |      BRAIN (Logic)      |     |     VAULT (DB)       |
|                     |     |                         |     |                      |
|  "Execute 100"      | --> |   Split(100)            |     |   Commit Transaction |
|  (POST /api/split)  |     |   -------------------   | --> |   ------------------ |
|                     |     |   • Creator: 60.00      |     |   [ID: 101]          |
|                     |     |   • Pool:    30.00      |     |   [Creator: 60.00]   |
|                     |     |   • Fee:     10.00      |     |   [Pool:    30.00]   |
+---------------------+     +-------------------------+     |   [Fee:     10.00]   |
                                                            +----------------------+
```

### Execution Flow
1.  **Input:** The Body submits a raw amount (e.g., `100`).
2.  **Processing:** The Brain computes the split deterministically.
3.  **Persistence:** A single atomic transaction is written to the SQLite Vault (WAL mode).

> **The Body never calculates, modifies, or persists economic values.**
> It only renders state that has already been committed by the Brain.

---

## 4. Determinism & Governance Roadmap

**In Phase 1.2:**
-   Split ratios are **hardcoded**.
-   Calculations are **purely deterministic**.
-   Ledger state is **locally auditable**.
-   **No governance or parameter mutation exists.**

**Future phases may introduce:**
-   Governance-driven parameter changes.
-   Cryptographic anchoring.
-   On-chain or mesh-based settlement.

This staged approach prevents premature complexity while preserving forward compatibility.

---

## 5. Summary

The 60-30-10 model in Phase 1.2 is **not a final economic policy**.
It is a **baseline primitive** designed to validate:

-   Local-first execution authority.
-   Persistent accounting.
-   Architectural enforcement.
-   Future cryptographic extensibility.

Once correctness is proven, policy evolution becomes safe.

---

© 2026 Nexus Protocol
