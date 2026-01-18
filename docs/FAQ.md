# 🏛️ Nexus Protocol — Frequently Asked Questions (v1.3.1)
    
    This document provides a technical and strategic FAQ for the **Nexus Sovereign Node**. It addresses architectural, economic, and multichain integration questions for Phase 1.3.1.
    
    ---
    
    ## 🏛️ Architecture & Perimeter Security
    
    ### Q: What is the "Sentry" and why is it mandatory in v1.3.1?
    **A:** The Sentry is a **Modular Verification Guard** that sits at the gateway boundary. Its role is to validate request integrity (via HMAC-SHA256) before the Economic Brain processes any state transitions. By making the Sentry mandatory, we ensure that the system follows a **Fail-Closed** security model.
    
    ### Q: Why use HMAC instead of full Ed25519 signing right now?
    **A:** HMAC-SHA256 provides a high-performance, low-latency "First Line of Defense" aligned with the Telegram Mini App security model. While Phase 2.0 will introduce **ioID** (Ed25519) for hardware identity, the current HMAC layer provides the prerequisite "Perimeter Hardening" to prevent unauthorized traffic from reaching internal logic.
    
    ---
    
    ## 💰 Economics & the 60-30-10 Split
    
    ### Q: Why 60-30-10? Why not a different ratio or a dynamic one?
    **A:** The 60-30-10 split is a **Hardcoded Execution Invariant**. We chose these specific ratios to balance three critical DePIN requirements:
    1. **60% (Participant):** Ensures the primary actor has sufficient incentive to maintain edge-node uptime.
    2. **30% (Ecosystem):** Creates a constrained reserve for future operational costs like storage and identity fees.
    3. **10% (Network):** Specifically earmarked for the cryptographic "cost of truth"—on-chain anchoring and verifiable compute / proof generation.
    
    ### Q: Can these ratios be changed?
    **A:** In Phase 1.3.1, these ratios are **immutable invariants**. Any change would require a protocol-level upgrade. This "Rigid Economics" approach is intentional; it prevents "economic drift" and ensures the ledger remains deterministic and auditable.
    
    ### Q: Does the 10% "Network Reserved" share represent a protocol fee?
    **A:** Not in the traditional sense. It is an **internal accounting allocation** reserved for the future costs of maintaining node integrity—specifically for **W3bstream proof workflows** (IoTeX) and **Future State-Root anchoring** (TON).
    
    ---
    
    ## 🔧 DePIN & IoTeX Alignment
    
    ### Q: How does Nexus fit into the IoTeX 2.0 "Modular DePIN" stack?
    **A:** Nexus acts as a **Sovereign Edge Node**. By porting our Sentry to support **ioID**, we provide a "Local Verification Perimeter" that complements IoTeX’s off-chain compute. Nexus pre-validates device intents before they are sent to **W3bstream** for verifiable computation, reducing on-chain "noise" and costs.
    
    ---
    
    ## 🔍 Operational & Legal Status
    
    ### Q: Is there any live on-chain execution in Phase 1.3.1?
    **A:** **No.** Phase 1.3.1 is strictly focused on **local-first hardening**. All blockchain references reflect architectural readiness and threat modeling. No tokens are issued, and no smart contracts are invoked in this phase.
    
    ### Q: Is Nexus a Bridge or an Oracle?
    **A:** Neither. Nexus is a **Sovereign Gateway**. It does not move assets between chains; it manages local state transitions and prepares them for global auditability via anchoring.
    
    > **Phase 1.3.1 Scope Summary:** Nexus v1.3.1 provides a hardened, local-first execution gateway with deterministic economics and verified identity extraction. It does not execute on-chain logic, issue tokens, bridge assets, or provide global consensus.
    
    ---
    
    © 2026 Nexus Protocol · v1.3.1