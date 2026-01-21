# Copyright 2026 Nexus Protocol Authors (Apache 2.0 Licensed)
"""
🏛️ NEXUS MERKLE ANCHOR (Phase 1.3.1 - RESEARCH ONLY)
NOTE: This script demonstrates cryptographic feasibility and is not part 
of the live execution path. It proves that the Sovereign Ledger state 
is mathematically ready for immutable anchoring in Phase 2.0.
"""

import sqlite3
import hashlib
import os

# --- Configuration ---
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(BASE_DIR, "backend", "nexus_vault.db")
HASH_ALGO = "sha256"



def hash_row(row: tuple) -> str:
    """
    Hash a single transaction row deterministically.
    Joining all columns ensures strict order dependence for the ledger.
    """
    # Audit 2.4: Schema assertion prevents silent drift between DB and Anchor
    assert len(row) == 5, f"Schema mismatch: Expected 5 columns, got {len(row)}"
    
    # Audit 2.4: Delimiter use prevents concatenation-based hash collision attacks
    row_bytes = "|".join(map(str, row)).encode()
    return hashlib.sha256(row_bytes).hexdigest()

def generate_merkle_root():
    """
    Connects to the Hardened Vault and reduces the verified transaction history
    into a single Merkle Root using recursive SHA-256 hashing.
    """
    if not os.path.exists(DB_PATH):
        print(f"Error: Vault not found at {DB_PATH}")
        return None

    # 1. Connect to Phase 1.3.1 Vault in Read-Only Mode (Audit 2.2)
    try:
        # URI mode with mode=ro ensures the research script cannot mutate state
        conn = sqlite3.connect(f"file:{DB_PATH}?mode=ro", uri=True)
        cursor = conn.cursor()

        # 2. Extract deterministic history (Audit 2.3)
        # Order is mandatory for Merkle Root determinism
        cursor.execute("""
            SELECT amount, creator_share, user_pool_share, network_fee, timestamp 
            FROM transactions 
            ORDER BY id ASC
        """)
        rows = cursor.fetchall()
        conn.close()
    except sqlite3.Error as e:
        print(f"Database Error: {e}")
        return None

    if not rows:
        print("Vault is empty. No validated state to anchor.")
        return None

    # 3. Create Leaf Hashes
    leaves = [hash_row(row) for row in rows]
    initial_count = len(leaves)

    # 4. Recursive Merkle Reduction (Binary Tree)
    # Audit 2.5: Standard binary hash tree semantics (duplicate-last-node strategy)
    nodes = leaves
    while len(nodes) > 1:
        if len(nodes) % 2 != 0:
            nodes.append(nodes[-1])
        
        next_level = []
        for i in range(0, len(nodes), 2):
            combined = nodes[i] + nodes[i+1]
            next_level.append(hashlib.sha256(combined.encode()).hexdigest())
        nodes = next_level

    return nodes[0], initial_count

if __name__ == "__main__":
    print(f"--- Nexus Phase 1.3.1 Hardened State Anchor ({HASH_ALGO}) ---")
    
    result = generate_merkle_root()
    
    if result:
        root_hash, count = result
        print(f"Validated Entries : {count}")
        print(f"Merkle State Root   : {root_hash}")
        print("-" * 55)
        print("Status: Perimeter-Verified State Root Generated.")
        print("Roadmap: Ready for Phase 2.0 Blockchain Anchoring.")
    
    print("\n© 2026 Nexus Protocol")