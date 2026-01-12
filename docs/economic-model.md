# Nexus Protocol — Economic Model (Phase 1.1)

This document explains the rationale behind the deterministic **60-30-10 economic split** implemented in Nexus Protocol Phase 1.1.

The model is intentionally simple and fixed at this stage to validate correctness, auditability, and persistence before introducing governance or adaptive parameters.

---

## 1. Design Goals

The economic model is designed to satisfy four core objectives:

1. **Creator Incentivization**
2. **User Participation & Retention**
3. **Protocol Sustainability**
4. **Deterministic Auditability**

Phase 1.1 prioritizes *stability and clarity* over flexibility.

---

## 2. The 60-30-10 Allocation

Each economic event processed by a Nexus node is split as follows:

- **60% — Creator Allocation**
- **30% — User Pool**
- **10% — Network Fee**

### 2.1 Creator Allocation (60%)

Allocating the majority of value to creators ensures:

- Strong incentives for high-quality content or contribution
- Clear value ownership at the edge (local node)
- Predictable reward outcomes for participants

This mirrors creator-economy dynamics while remaining enforceable at the protocol level.

---

### 2.2 User Pool (30%)

The user pool represents collective incentives for:

- Viewers, supporters, or participants
- Future distribution mechanisms (e.g. engagement rewards, boosts)
- Viral retention and network effects

In Phase 1.1, this pool is tracked but not redistributed, allowing the ledger logic to be validated independently.

---

### 2.3 Network Fee (10%)

The network fee is reserved for:

- Protocol sustainability
- Future relay, synchronization, or anchoring costs
- Long-term infrastructure maintenance

This allocation establishes economic viability without external monetization dependencies.

---

## 3. Determinism and Governance Roadmap

In Phase 1.1:

- The split ratio is **hardcoded**
- All calculations are **deterministic**
- All outcomes are **locally auditable**

Future phases will explore:

- Governance-based parameter updates
- On-chain anchoring and verification
- Community-informed adjustments

This staged approach prevents premature complexity while preserving upgrade paths.

---

## 4. Summary

The 60-30-10 model is not a final economic policy.  
It is a **baseline primitive** designed to validate:

- Local-first execution
- Persistent accounting
- Future cryptographic anchoring

---

© 2026 Nexus Protocol
