# 🧠 Nexus Protocol — The Sovereign Brain (v1.4.0)

**Status:** Phase 1.4.0 (Secure Ingress Hardening)  
**Architecture:** Sovereign Monolith (FastAPI + SQLite + Cloudflare)

The Nexus Brain is the deterministic policy engine of the Nexus Protocol. It executes the **60/30/10 Economic Split** and manages the **Sovereign Vault** with validated concurrency.

In **v1.4.0**, the architecture was hardened by removing ephemeral tunneling (Ngrok) in favor of a strict, policy-gated **Cloudflare Zero Trust** ingress.

---

## 🏛️ Sovereign Architecture (v1.4.0)

The Brain now operates inside a fully isolated Docker network. It exposes **zero public ports**. All ingress is managed by a sidecar tunnel that authenticates traffic before it ever touches the execution layer.

> [!NOTE]
> **Architectural Scope:** Phase 1.x assumes a **Single Sovereign Node** topology. Distributed clustering, consensus anchoring, and mesh execution are explicitly deferred to **Phase 2.0**.

```mermaid
graph TD
    %% External World
    User((Public User/TMA))
    CF[Cloudflare Edge Network]
    
    %% The Host Machine
    subgraph "Sovereign Node (Docker Host)"
        
        %% Ingress Layer
        subgraph "Ingress Controller"
            Tunnel[Nexus Sentry (Cloudflare Tunnel)]
        end

        %% Isolated Network
        subgraph "Private Network (nexus_net)"
            Brain{Nexus Brain}
            Vault[(Sovereign Vault - SQLite)]
        end
    end

    %% Data Flow
    User -->|HTTPS (TLS 1.3)| CF
    CF -->|Secure Tunnel Protocol| Tunnel
    Tunnel -->|Verified Request| Brain
    Brain -->|60/30/10 Write| Vault
    
    %% Implicit Frontend Serving
    Brain -.->|Serve Flutter UI| User

    %% Removed Component Visual
    style Tunnel fill:#00d7bd,stroke:#333,stroke-width:2px
    style Brain fill:#7289da,stroke:#333,stroke-width:2px
```

### 🔒 Why Cloudflare? (Ngrok Removal)
Legacy tunneling (Ngrok) was deprecated in v1.3.1. The v1.4.0 architecture uses **Cloudflare Zero Trust** for three sovereign guarantees:
1.  **Zero Attack Surface:** Port `8000` is bound only to `127.0.0.1`. No open firewall ports required.
2.  **Persistent Identity:** The node is anchored to a stable DNS (`nexucore.xyz`) rather than a rotating random URL.
3.  **Self-Healing:** The Tunnel container is health-gated; it waits for the Brain to report "Healthy" before establishing a connection.

> **Future Roadmap (Phase 2.0):** > Cloudflare currently serves as a **bootstrap ingress layer**. In Phase 2.0, Nexus Protocol evolves toward **provider-independent, reversible ingress**, where:
> - no single routing provider is required,
> - frontend attachment is optional and detachable,
> - execution and storage remain fully local-first,
> - external networks may relay or attest, but never execute.
>
> Specific transport or hosting mechanisms are intentionally unspecified at this stage and will be evaluated only if they preserve deterministic execution and sovereign control.

---

## 💰 The 60/30/10 Economic Protocol
Every transaction processed by the Brain is bifurcated according to immutable execution logic:

| Recipient | Share | Purpose |
| :--- | :--- | :--- |
| **Creator Share** | 60% | Direct settlement to the content/node creator. |
| **User Pool** | 30% | Community redistribution and liquidity anchoring. |
| **Network Fee** | 10% | Protocol maintenance and DePIN anchoring. |

---

## 🛠️ System Requirements
Before launching the Brain, ensure the host environment meets these standards:

1.  **Docker Desktop** (Running and healthy).
2.  **Cloudflare Tunnel Token** (Set in root `.env`).
3.  **Persistence File:** The database file must exist on the host to prevent Docker directory errors.

### ⚡ Quick Start Commands

#### 1. First-Time Setup (Windows Only)
Create the database file specifically to prevent Docker from creating it as a folder:
```powershell
type nul > backend\nexus_vault.db
```

#### 2. Launch the Sovereign Node
This builds the Python Brain and starts the Secure Tunnel in detached mode.
```powershell
docker-compose up -d --build --remove-orphans
```

#### 3. Verify Health
Check the logs to ensure the Brain is accepting traffic:
```powershell
docker logs -f nexus-brain
```

---

## 🛡️ Security & Resilience (Validated)
* **Concurrency:** Validated for 50+ concurrent users via SQLite WAL (Write-Ahead Logging) mode.
* **Isolation:** The "Brain" container has no internet access except via the "Sentry" bridge.
* **Self-Healing:** Cloudflare ingress depends on the Brain's healthcheck; if the Python Brain crashes, the Tunnel automatically cuts the connection to prevent "Zombie" states.
* **Recovery:** Local-first storage ensures data survives container rebuilds.

---

## 📊 API Specification (Internal)

| Endpoint | Method | Security | Description |
| :--- | :--- | :--- | :--- |
| `/api/execute_split` | POST | Multichain Guard | Triggers 60/30/10 ledger entry. |
| `/api/vault_summary/{id}` | GET | Public/Resolved | Returns balance for a Sovereign ID. |
| `/api/transactions` | GET | Multichain Guard | Cursor-based history with Merkle pagination. |

---

© 2026 Coreframe Systems · Phase 1.4.0 Specification · Licensed under Apache 2.0
