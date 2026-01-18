# 🏛️ Nexus Protocol — Technical Architecture (v1.3.1)
    
    This document describes the **Multichain Hardened Gateway Architecture**. Nexus moves the "Trust Perimeter" from the cloud to user-owned hardware, providing a secure execution environment for decentralized apps on **TON** and **IoTeX**.
    
    
    
    > [!IMPORTANT]
    > **Architectural Scope & Negative Guarantees:**
    > * Phase 1.3 is **non-executing** on-chain. All blockchain interactions are restricted to identity verification and future state-root anchoring. 
    > * **Explicit Non-Goals:** No cross-node consensus, no trustless global ordering, and no permissionless identity federation in this phase.
    
    ---
    
    ## 1. Architectural Philosophy: The Modular Sentry
    
    In v1.3.1, Nexus implements a **Modular Sentry Model**. This decouples the verification of "Network Identity" (Origin) from the "Economic Logic" (Execution).
    
    1.  **Pluggable Verification Gates:** The Sentry is architected to support staged modules for **TON (HMAC)** and **IoTeX (ioID)**.
    2.  **Verify-then-Execute (VTE):** A strict gatekeeping pattern where the Economic Engine is isolated from raw internet traffic.
    3.  **Local-First Authority:** The gateway assumes the local environment is the primary source of truth, with global chains reserved for future audit anchoring and settlement.
    
    ---
    
    ## 2. High-Level Architecture (Multichain)
    
    The system enforces a **Fail-Closed** security posture. Requests are dropped at the edge if they fail network-specific integrity checks.
    
    
    
    ```mermaid
    graph TD
        User((User / Device)) -->|:8000| Sentry["🛡️ NEXUS SENTRY (Guard)"]
        
        subgraph Sentry_Modules [Verification Gates]
            Sentry -->|Module A| TON[TON HMAC Check]
            Sentry -->|Module B| IOTX[IoTeX ioID Staging]
        end
    
        TON & IOTX -->|Verified?| Logic{Gatekeeper}
        
        Logic -->|NO| Reject[403 Forbidden]
        Logic -->|YES| Brain["🧠 NEXUS BRAIN (Core)"]
        
        subgraph Brain_Internals [Execution & Routing]
            Brain -->|/api/*| Engine[60-30-10 Engine]
            Brain -->|/*| Proxy[Reverse Proxy]
        end
        
        Engine -->|Atomic Write| Vault[(Nexus Vault)]
        Proxy -->|Passive Fetch| Body[Flutter Body :8080]
    ```
    
    ---
    
    ## 3. Component Breakdown
    
    ### 3.1 The Sentry — Multichain Guard
    * **TON Module:** Validates `initData` signatures using a secret key derived from the Bot Token.
    * **IoTeX Module (Staged):** Prepared for **ioID** (Decentralized Identity) integration to verify physical hardware ownership (interface-only; not enforced in Phase 1.3).
    * **Timing-Safe Enforcement:** Verification paths are normalized to avoid observable timing variance between accepted and rejected requests.
    
    ### 3.2 The Brain — Sovereign Core (FastAPI)
    * **Engine Isolation:** Executes **60-30-10 invariants** only after Sentry approval.
    * **Deterministic State:** Ensures that regardless of the entry network (TON/IoTeX), the ledger outcome remains identical.
    
    ### 3.3 The Vault — Authoritative Ledger (SQLite)
    
    * **WAL Mode:** High-concurrency local persistence.
    * **Anchoring-Ready:** Schema is designed to generate Merkle roots for future on-chain commits to TON or IoTeX blockchains.
    
    ### 3.4 The Body — Stateless Observer (Flutter)
    * **Passive Fetching:** The UI layer has zero authority to mutate state or verify signatures; it acts as a visualization proxy for the Brain.
    
    ---
    
    ## 4. Multichain Roadmap Alignment
    
    * [x] **Phase 1.2** — Gateway Proxy Authority (Closed)
    * [x] **Phase 1.3** — **Perimeter Hardening & Multichain Staging (Active)**
    * [ ] **Phase 2.0** — **ioID Integration & W3bstream Proofs**
    
    ---
    
    © 2026 Nexus Protocol · Licensed under **Apache License 2.0**