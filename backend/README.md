# ====================================================
# 🏗️ NEXUS ARCHITECTURE & SYSTEM DESIGN (V1.2)
# ====================================================
# Focus: Economic Authority & Gateway Proxy Logic
# Status: Phase 1.2 (Active)
# ----------------------------------------------------

## 1. THE SOVEREIGN DESIGN PHILOSOPHY

Nexus is built on the principle of "Separation of Concern with 
Authority."

- THE BRAIN (Backend): The Economic Authority.
- THE BODY (Frontend): The Stateless Observer.

By routing all traffic through the Brain (Port 8000), we 
ensure the UI can never "trick" the ledger.

---

## 2. THE GATEWAY PROXY LOGIC (VISUALIZED)

In Phase 1.1, we had two ports open. In Phase 1.2, we moved to 
a Single Gateway model to ensure consistent behavior across 
Localhost and Ngrok.

[ USER / TELEGRAM ]
       |
       | (Connects to Port 8000)
       v
+------------------------------------------+
|          🧠 NEXUS BRAIN (GATEWAY)        |
|------------------------------------------|
|  1. Incoming Request Check               |
|  2. "Is this an API call?"               |
|                                          |
|    YES (/api/*)           NO (/*)        |
|         |                    |           |
|         v                    v           |
|  +--------------+    +---------------+   |
|  |  FASTAPI     |    |  REVERSE      |   |
|  |  LOGIC       |    |  PROXY        |   |
|  +------+-------+    +-------+-------+   |
|         |                    |           |
|         | (Writes)           | (Fetches) |
|         v                    v           |
|  [ NEXUS_VAULT ]     [ FLUTTER BODY ]    |
|  (SQLite DB)         (Localhost:8080)    |
+------------------------------------------+

This design allows the Node to appear as a single unified 
service to the outside world.

---

## 3. DATA PERSISTENCE: THE VAULT

The node uses SQLite for its "Sovereign Vault."

- MODE: Write-Ahead Logging (WAL).
- ATOMICITY: Every split (60-30-10) is a single transaction. 
- ISOLATION: The database file is locked to the backend process.

---

## 4. UNIFIED NAMESPACE (SYNC STRATEGY)

To ensure that state is identical whether accessed from 
a desktop browser or a mobile Telegram app, the system 
uses a hardcoded Debug Namespace in this phase:

   ID: "NEXUS_DEV_001"

This prevents the "Split-Brain" scenario where different 
devices see different balances before we implement real 
cryptographic identity.

---

## 5. DESIGN DISCIPLINE (PHASE 1.2 LIMITS)

Consistent with Phase 1.2 goals, the following are 
INTENTIONALLY EXCLUDED from the current architecture:

[ ] NO CRYPTO IDENTITY: User authentication is context-based.
[ ] NO P2P PEERING: This node does not talk to other nodes.
[ ] NO BLOCKCHAIN ANCHORING: State is local-only.

----------------------------------------------------
© 2026 Nexus Protocol | Apache License 2.0
----------------------------------------------------