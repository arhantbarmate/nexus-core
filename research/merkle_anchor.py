"""
Nexus Protocol — Phase 1.3.1 Merkle Anchoring (Perimeter-Verified)

This script demonstrates the cryptographic feasibility of hashing local 
sovereign state into a single Merkle Root. In Phase 1.3.1, this state 
is acknowledged as having passed the Sentry's HMAC-SHA256 integrity gate.
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
    # Explicit Schema Assertion: Ensure row matches expected Phase 1.3.1 structure
    assert len(row) == 5, f"Schema mismatch: Expected 5 columns, got {len(row)}"
    
    row_bytes = "|".join(map(str, row)).encode()
    return hashlib.sha256(row_bytes).hexdigest()

def generate_merkle_root():
    """
    Connects to the Hardened Vault and reduces the verified transaction history
    into a single Merkle Root using recursive SHA-256 hashing.
    """
    if not os.path.exists(DB_PATH):
        print(f"Error: Vault not found at {DB_PATH}")
        print("Verification Failed: Run backend and generate Sentry-validated transactions first.")
        return None

    # 1. Connect to Phase 1.3.1 Vault in Read-Only Mode
    try:
        # Using URI mode for explicit read-only (ro) safety
        conn = sqlite3.connect(f"file:{DB_PATH}?mode=ro", uri=True)
        cursor = conn.cursor()

        # 2. Extract deterministic history
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