# 🔌 Universal Adapters

This directory contains the chain-specific integration logic.

## Structure
* `base.py` - The abstract base class that enforces the Universal Interface.
* `dummy.py` - **Active.** A local test harness for development (no internet required).
* `resources/` - JSON configuration artifacts for specific chains.
* `peaq/` - (Planned) Machine ID verification logic.

## Adding a Chain
To add a new chain (e.g., Solana), create a new class inheriting from `BaseAdapter` and implement:
1. `verify_identity()`
2. `anchor_state()`
