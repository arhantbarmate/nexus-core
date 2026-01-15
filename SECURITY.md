# Security Policy — Nexus Protocol

## 1. Reporting a Vulnerability
If you discover a security vulnerability in Nexus Protocol, please report it responsibly. We appreciate your help in keeping the protocol secure.

### Preferred Disclosure
Please send a private report to: **arhantbarmate@outlook.com**

### Reporting Guidelines
* **Do not** include exploit code or sensitive details in public issues.
* If a private report is not possible, open a GitHub Issue and mark it clearly as **[SECURITY]**.
* Provide a clear **Proof of Concept (PoC)** so we can validate the impact.

---

## 2. Threat Model & Scope (Phase 1.1)
Nexus Protocol is a **local-first research prototype**. Security researchers should consider the following scope boundaries:

### In-Scope (High Priority)
* **Logic Flaws:** Vulnerabilities in the 60-30-10 split calculation (e.g., rounding exploits).
* **Data Corruption:** Flaws that cause unrecoverable corruption of the `nexus_vault.db`.
* **Engine Exploits:** Remote Code Execution (RCE) via the FastAPI Brain's local REST API.

### Out-of-Scope (Lower Priority)
* **Physical Access:** Vulnerabilities requiring physical access to the node hardware.
* **Local File Permissions:** Standard OS-level file permission issues regarding the vault file.
* **DDoS:** Local Denial of Service attacks against the node's local port.

---

## 3. Safe Harbor
We promise not to pursue legal action against researchers who:
* Engage in vulnerability research without harming users or the protocol.
* Adhere to this policy and provide a reasonable timeframe for remediation before public disclosure.
* Avoid the use of automated scanners that may disrupt local node stability.

---

## 4. Response Timeline
As this is a **research and feasibility prototype**, reports are reviewed on a **best-effort basis**. We typically acknowledge reports within **72 hours** and provide periodic updates during the remediation process.

---

© 2026 Nexus Protocol