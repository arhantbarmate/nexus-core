# 💰 Nexus Protocol — Economic Engine (v1.3.1)
    
    This document defines the deterministic **60-30-10 State Transition Engine**. In Phase 1.3, these ratios are treated as **hardcoded execution invariants** to ensure ledger integrity before cross-chain settlement is enabled.
    
    
    
    ---
    
    ## 1. The Multichain Utility Strategy
    
    Unlike traditional "Tokenomics," Nexus Economics focuses on **Resource Allocation at the edge**. The 60-30-10 split is designed to support the "Verify-then-Execute" model for future interaction domains, including **TON** (social/user flows) and **IoTeX** (DePIN/hardware flows).
    
    
    
    ---
    
    ## 2. Deterministic Allocation Invariants
    
    Every economic event processed by the **Sovereign Brain** follows an atomic split. An **invariant** is defined here as a rule that must hold true for every valid state transition, regardless of the network or client layer.
    
    | Allocation | Share | Logic | Ecosystem Utility |
    | :--- | :--- | :--- | :--- |
    | **Primary Actor** | 60% | Local Participant Reward | Incentivizes edge-node uptime and hardware maintenance. |
    | **Secondary Pool** | 30% | Reserved Ecosystem Value | Constrained reserve for future **ioID** identity fees or TON storage. |
    | **Network Fee** | 10% | Protocol Overhead | Reserved for **W3bstream** proof generation and on-chain gas anchoring. |
    
    > [!IMPORTANT]
    > **Value Scope Disclaimer:** In Phase 1.3, all allocations are **internal accounting entries only**. They do not represent transferable tokens, claims, or on-chain balances. No redemption, withdrawal, or settlement is possible in this phase. The Secondary Pool is not a discretionary treasury; it is a constrained reserve with predefined future cost domains.
    
    ---
    
    ## 3. Enforcement Architecture (The Economic Firewall)
    
    The Sentry acts as the "Economic Firewall." It ensures that no state transition—and thus no economic allocation—occurs without cryptographic proof of origin.
    
    ```mermaid
    graph TD
        subgraph Client [Edge Device / TMA]
            A[Intent Payload] --> B{X-Nexus-* Headers}
        end
    
        B --> C{🛡️ SENTRY GUARD}
    
        subgraph Logic [Sovereign Brain]
            C -->|Valid HMAC/ioID| D[60-30-10 Engine]
            C -->|Unverified| E[Reject / Drop]
            
            D --> F[Primary: 60%]
            D --> G[Secondary: 30%]
            D --> H[Network: 10%]
        end
    
        F & G & H --> I[(Sovereign Vault)]
        I --> J[Future: On-Chain Anchor]
    ```
    
    ---
    
    ## 4. DePIN Grant Alignment (IoTeX/TON)
    
    To ensure long-term sustainability, the 10% **Network Reserved** fee is specifically earmarked for:
    1. **W3bstream Proofs:** Paying for off-chain verifiable compute to prove "Physical Work" (IoTeX).
    2. **Future Global Anchoring/Settlement:** Paying for periodic Merkle tree root updates to the TON blockchain.
    
    ---
    
    ## 5. Summary
    
    The 60-30-10 model in Phase 1.3 is an **Enforced Execution Invariant**. By framing economics as a deterministic state machine, Nexus ensures that local value creation is always ready for global blockchain settlement without premature on-chain coupling.
    
    ---
    
    © 2026 Nexus Protocol