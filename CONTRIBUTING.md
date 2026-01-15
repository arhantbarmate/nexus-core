# Contributing to Nexus Protocol

Thank you for your interest in **Nexus Protocol**. This repository currently represents a **Phase 1.1 feasibility prototype** focused on validating local-first economic execution, sovereign persistence, and reproducibility.

## 1. Our Focus
At this stage, the project prioritizes:
* **Reproducibility:** Ensuring the "Brain" and "Body" can be built and run on diverse local environments.
* **Deterministic Behavior:** Maintaining the integrity of the 60-30-10 economic split logic.
* **Documentation Clarity:** Improving the technical descriptions of our local-first architecture.

## 2. How to Contribute

### Reporting Issues
Please open an **Issue** for:
* **Bug Reports:** Reproducible errors in the FastAPI backend or Flutter client.
* **Documentation Improvements:** Typos, unclear architectural diagrams, or missing setup steps.
* **Design Questions:** Inquiries regarding our use of SQLite WAL mode or background task isolation.

### Pull Requests
Pull requests are welcome, but should be:
* **Small and Focused:** Avoid large architectural overhauls in a single PR.
* **Clearly Described:** Explain the "why" and "how" behind the change.
* **Aligned with Scope:** PRs that introduce external dependencies or blockchain settlement logic will be deferred to later research phases.

## 3. Scope Notice (Phase 1.1)
Nexus Protocol is currently in a **hardened feasibility phase**. Feature expansion—specifically regarding TON Connect integration, Merkle anchoring, or peer-to-peer transport—is reserved for the Phase 1.2 research track. Architectural changes that violate our local-first "Sovereign Node" philosophy will not be accepted at this time.

---

© 2026 Nexus Protocol