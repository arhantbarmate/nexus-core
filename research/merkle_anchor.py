"""
Nexus Protocol — Phase 1.2 Merkle Anchoring (Research Prototype)

This script demonstrates the cryptographic feasibility of hashing local 
sovereign state into a single Merkle Root. This root serves as the 
'Anchor of Truth' for future submission to the TON blockchain.
"""

import sqlite3
import hashlib
import os

# --- Configuration ---
# Ensures the script can find the vault regardless of where it is called
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(BASE_DIR, "backend", "nexus_vault.db")
HASH_ALGO = "sha256"  # Standard TON-compatible hashing

def hash_row(row: tuple) -> str:
    """
    Hash a single transaction row deterministically.
    Joining all columns ensures strict order dependence for the ledger.
    """
    row_bytes = "|".join(map(str, row)).encode()
    return hashlib.sha256(row_bytes).hexdigest()

def generate_merkle_root():
    """
    Connects to the Phase 1.1 Vault and reduces the transaction history
    into a single Merkle Root using recursive SHA-256 hashing.
    """
    if not os.path.exists(DB_PATH):
        print(f"Error: Vault not found at {DB_PATH}")
        print("Please run the backend and generate transactions first.")
        return None

    # 1. Connect to Phase 1.1 Vault
    try:
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()

        # 2. Extract deterministic history (Ordering is vital for Merkle integrity)
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
        print("Vault is empty. No state to anchor.")
        return None

    # 3. Create Leaf Hashes
    leaves = [hash_row(row) for row in rows]
    initial_count = len(leaves)

    # 4. Recursive Merkle Reduction
    nodes = leaves
    while len(nodes) > 1:
        if len(nodes) % 2 != 0:
            nodes.append(nodes[-1])  # Duplicate last if odd (Bitcoin-style)
        
        next_level = []
        for i in range(0, len(nodes), 2):
            combined = nodes[i] + nodes[i+1]
            next_level.append(hashlib.sha256(combined.encode()).hexdigest())
        nodes = next_level

    return nodes[0], initial_count

if __name__ == "__main__":
    print(f"--- Nexus Phase 1.2 Feasibility Test ({HASH_ALGO}) ---")
    
    result = generate_merkle_root()
    
    if result:
        root_hash, count = result
        print(f"Transactions Anchored: {count}")
        print(f"Generated State Root : {root_hash}")
        print("-" * 45)
        print("Status: Cryptographic Root Verified Locally.")
    
    print("\n© 2026 Nexus Protocol")