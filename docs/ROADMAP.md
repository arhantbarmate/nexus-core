# 🗺️ Nexus Protocol — Engineering Roadmap (Research)

> ⚠️ **Non-Binding Research Document**
>
> This roadmap describes **exploratory engineering directions** for Nexus Protocol.
>  
> It is **not a delivery commitment**, **not part of Phase 1.1 grant scope**, and
> **subject to change** based on feasibility, funding, and external review.

**Current Status:** Phase 1.1 (Feasibility) — **Completed**  
**Research Focus:** Phase 1.2 (Anchoring & Identity)

---

## 📍 Phase 1: Foundation (The Local Machine)

### ✅ Phase 1.1: Feasibility Prototype (Completed)
**Goal:** Prove that a deterministic economic engine can run offline on a user device.

- [x] **The Brain:** FastAPI execution engine enforcing deterministic 60-30-10 logic
- [x] **The Vault:** Restart-proof SQLite persistence (append-only ledger)
- [x] **The Body:** Flutter dashboard for real-time local state visualization
- [x] **Auditability:** ISO 8601 timestamping for all transactions
- [x] **Cryptographic Feasibility:** `merkle_anchor.py` validating local state hashing

---

### 🧪 Phase 1.2: Anchoring & Identity (Research Target)
**Goal:** Explore how local sovereign nodes can anchor state to TON without sacrificing local-first guarantees.

- [ ] **TON Connect Integration (Exploratory):**  
      Evaluate wallet-based identity binding for node ownership
- [ ] **Merkle Anchoring (Feasibility):**  
      Extend Merkle root generation toward automated submission to TON test environments
- [ ] **Protocol Fee Handling (Research):**  
      Investigate minimal on-chain mechanisms for protocol fee anchoring in controlled test environments

---

## 🚀 Phase 2: The Mesh (Research)

### Phase 2.1: Peer-to-Peer Transport
**Goal:** Explore local-area synchronization without reliance on centralized infrastructure.

- [ ] **libp2p Evaluation:** Gossip-based peer discovery and message propagation
- [ ] **Local Transport Research:** Bluetooth Low Energy (BLE) and Wi-Fi Direct packet exchange

### Phase 2.2: Incentive Layer (The 30% Pool)
**Goal:** Study economic incentives for physical infrastructure participation.

- [ ] **Proof of Relay (Concept):** Cryptographic stamping of forwarded packets
- [ ] **Relay Reward Modeling:** Research distribution of the 30% pool to relay nodes

---

## 📊 Research Timeline (Illustrative)

```mermaid
timeline
    title Nexus Protocol — Illustrative Research Progression

    section Phase 1.1 (Completed)
        Local-First Execution Engine : FastAPI Brain
        Sovereign Persistence        : SQLite Vault
        Deterministic Economics      : 60-30-10 Enforcement
        Cryptographic Feasibility    : Merkle Root Generation

    section Phase 1.2 (Research)
        Identity Integration         : TON Connect (Exploratory)
        State Commitments            : Merkle Anchoring (Feasibility)

    section Phase 2.0 (Research)
        Mesh Transport               : libp2p / Gossip
        Incentive Settlement         : Proof-of-Relay (Concept)
