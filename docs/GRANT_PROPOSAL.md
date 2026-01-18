# 🛡️ Nexus Protocol: The Sovereign Edge Gateway for DePIN

**Project Name:** Nexus Protocol
**Category:** DePIN Infrastructure / Dev Tooling
**Funding Request:** $20,000 USDT
**Duration:** 3 Months

---

## 1. Project Overview

**The Problem:**
DePIN relies on "Real World Data," but current gateways are either centralized (AWS-dependent) or insecure (easily spoofed). If the edge node is compromised, W3bstream processes garbage data ("Garbage In, Garbage Out").

**The Solution:**
Nexus Protocol is a **Local-First Sovereign Node**. It moves the trust perimeter to the user's physical device. By implementing a **"Verify-then-Execute"** architecture, Nexus ensures that only cryptographically verified intents can trigger logic or data transmission.

**Why IoTeX?**
Nexus is the hardened edge layer for the IoTeX DePIN stack. We provide a sovereign execution gateway that feeds clean, verified data into **ioID** and **W3bstream** pipelines.

---

## 2. Technical Architecture

Nexus operates on a **Fail-Closed Sentry Model**:

1.  **Sentry Guard:** Python-based edge firewall rejecting unverified traffic before execution.
2.  **ioID Integration (Phase 2):** Hardware-backed identity verification using IoTeX DIDs.
3.  **Sovereign Vault:** Local SQLite ledger with Merkle state roots for future IoTeX anchoring.

**Current Status (Phase 1.3.1):**
* ✅ Repository: [github.com/arhantbarmate/nexus-core](https://github.com/arhantbarmate/nexus-core)
* ✅ Documentation: [nexus-core/docs](https://arhantbarmate.github.io/nexus-core/)
* ✅ CI/CD: Active & Passing

---

## 3. Value to IoTeX Ecosystem

1.  **Drives ioID Adoption:** A reference ioID integration for Python-based edge nodes.
2.  **Reduces W3bstream Noise:** Filters invalid data before off-chain compute.
3.  **DePIN Reference Stack:** A reusable sovereign node architecture for IoTeX builders.

---

## 4. Development Roadmap & Milestones

### Milestone 1: Perimeter Hardening & Production-Grade Staging (Complete)
**Deliverables:**
* Complete `sentry.py` module with HMAC verification.
* Full Documentation Suite (Architecture, Economics, Install).
* Live "Sovereign Node" Demo on Linux.
* **Funding:** $5,000

### Milestone 2: ioID & Hardware Identity (Month 1–2)
**Deliverables:**
* Augment HMAC perimeter verification with ioID-backed Ed25519 signatures.
* Integrate `iotex-antenna` SDK into the Sentry.
* Enable **SIWI (Sign-In with IoTeX)** for node access.
* **Funding:** $10,000

### Milestone 3: W3bstream Proof Pilot (Month 3)
**Deliverables:**
* Generate "Proof-of-Uptime" utilizing local logs via W3bstream.
* Anchor first Merkle state root to IoTeX Testnet.
* **Funding:** $5,000

---

## 5. Team

* **Arhant Barmate:** Lead Architect (Sovereign Systems, Local-First Execution)

---

## 6. Metrics for Success
* **100+** Active Sovereign Nodes deployed.
* **1,000+** Verified W3bstream messages/day.
* **5+** DePIN projects forking the Nexus Core stack.
