# NEXUS PROTOCOL

> Local-First Economic Infrastructure for Resilient Communication

STATUS: Feasibility Prototype
LICENSE: Apache License 2.0
FOCUS: Offline-First Architecture, Peer-to-Peer Relay, Sovereign Identity

---

## 1. OVERVIEW

Nexus Protocol is a research-driven infrastructure project exploring how user devices can operate as sovereign economic nodes without permanent reliance on centralized servers.

The project focuses on RESILIENCE, OWNERSHIP, and GRACEFUL DEGRADATION, enabling limited communication and value coordination to continue during network instability or partial connectivity loss.

### THE PROBLEM: FRAGILITY
Most modern applications assume continuous internet, centralized servers, and custodial identity. These assumptions break down during:
- Infrastructure outages (Natural disasters, conflict)
- Regional connectivity failures (Censorship, ISP blackouts)
- High-latency or low-bandwidth environments

### THE SOLUTION: SOVEREIGNTY
Nexus explores whether local-first execution combined with peer-to-peer relay can reduce these dependencies while remaining compatible with blockchain-based global state (TON) when connectivity is restored.

---

## 2. THE REFERENCE USE CASE (SOCIAL MEDIA)

To validate this infrastructure, Nexus is building a **"Sovereign Social" Reference Implementation**—a decentralized content-sharing and discovery system.

In this model, the "Value" being split is **simulated** and represents:
1. **Advertising-like value flows:** Test credits representing paid reach.
2. **Tips/Boosts:** Test credits representing voluntary user support.

Unlike many centralized platforms, Nexus defines allocation rules at the protocol level rather than at the application or company level.

---

## 3. ECONOMIC MODEL (THE "60-30-10" RULE)

Nexus implements a deterministic revenue split logic that runs on the user's device. For every unit of simulated value entering the system (e.g., test credits representing ad spend or user boosts), the protocol enforces:

- 60% : CREATOR (The person who made the video/post)
- 30% : USER POOL (Divided among the viewers/boosters)
- 10% : NETWORK (Protocol sustainability and relay costs)

*Note: The current prototype simulates this logic using integer credits to prove the mathematical feasibility of the split engine.*

---

## 4. SYSTEM ARCHITECTURE

Nexus is structured as a layered protocol stack, where each layer can operate independently and synchronize opportunistically.

LAYER 0: THE MESH (Resilience)
- Status: Research
- Tech: Bluetooth LE / Wi-Fi Direct
- Function: Device-to-device communication for short-range peer relaying.

LAYER 1: THE BRAIN (Execution)
- Status: Prototype Live
- Tech: Python (FastAPI) + Planned SQLite persistence
- Function: A local server on the user's device that executes the 60-30-10 logic and manages local state, with persistent storage planned via SQLite.

LAYER 2: THE BODY (Interface)
- Status: Prototype Live
- Tech: Flutter (Dart)
- Function: A cross-platform social interface that uses biometric authentication to unlock local keys.

LAYER 3: THE VAULT (Consensus)
- Status: Planned
- Tech: TON Blockchain
- Function: The global anchor for identity recovery and final settlement.

---

## 5. HOW TO RUN THE PROTOTYPE

To run the full system, you need to launch the Brain (Backend) and the Body (Client) simultaneously.

### STEP 1: START THE BRAIN (BACKEND)
Open your first terminal window and run:

cd backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload

### STEP 2: START THE BODY (CLIENT)
Open a second terminal window and run:

cd client
flutter run

---

## 6. PROJECT STATUS & GRANT INTENT

PHASE: Feasibility & Infrastructure Research
DEVELOPER: Solo Founder
GRANT GOAL: To expand prototype depth, validate architectural assumptions, and move from "Ephemeral Memory" to "Persistent SQLite Storage."

Disclaimer: Nexus Protocol is an experimental research project. Claims are limited to prototype behavior and documented observations.

---

## 7. LICENSE

This project is licensed under the **Apache License 2.0**. This license was chosen to provide users and contributors with explicit patent grants, ensuring that the protocol remains an open, accessible, and legally protected foundation for decentralized communication.

---
© 2026 Nexus Protocol