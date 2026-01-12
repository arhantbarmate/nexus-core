import os
import sqlite3
from datetime import datetime
from fastapi import FastAPI, HTTPException

app = FastAPI(title="Nexus Protocol Execution Engine", version="1.1")

# --- CONFIGURATION & DATABASE SETUP ---

# Get the directory where main.py is located to ensure DB is saved in the same folder
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, "nexus_vault.db")

def get_db_connection():
    """Safety wrapper for database connection with row factory."""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row  # Allows accessing columns by name
    return conn

def init_db():
    """Initializes the deterministic 60-30-10 ledger."""
    conn = get_db_connection()
    try:
        curr = conn.cursor()
        curr.execute('''
            CREATE TABLE IF NOT EXISTS transactions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                amount REAL NOT NULL,
                creator_share REAL NOT NULL,
                user_pool_share REAL NOT NULL,
                network_fee REAL NOT NULL,
                timestamp TEXT NOT NULL
            )
        ''')
        conn.commit()
    finally:
        conn.close()

# Initialize the Vault on startup
init_db()

# --- API ENDPOINTS ---

@app.get("/")
def read_root():
    return {"status": "Nexus Brain Online", "mode": "Local Sovereign", "version": "1.1"}

@app.get("/ledger")
async def get_ledger():
    """Returns the authoritative aggregated ledger state."""
    conn = get_db_connection()
    try:
        curr = conn.cursor()
        curr.execute("SELECT SUM(creator_share), SUM(user_pool_share), SUM(network_fee) FROM transactions")
        creator, user_pool, network = curr.fetchone()
        
        return {
            "total_earned": creator or 0.0,
            "global_user_pool": user_pool or 0.0,
            "protocol_fees": network or 0.0
        }
    finally:
        conn.close()

@app.get("/transactions")
async def get_transactions():
    """Returns the full append-only transaction history for audit."""
    conn = get_db_connection()
    try:
        curr = conn.cursor()
        # Select ALL columns to prove the split math is correct in the logs
        curr.execute("SELECT * FROM transactions ORDER BY id DESC")
        rows = [dict(row) for row in curr.fetchall()]
        return rows
    finally:
        conn.close()

@app.post("/execute_split/{amount}")
async def execute_split(amount: float):
    """Executes and records the 60-30-10 split."""
    if amount <= 0:
        raise HTTPException(status_code=400, detail="Amount must be positive")

    # Authoritative 60-30-10 Logic (Deterministic Rounding)
    creator = round(amount * 0.60, 2)
    user_pool = round(amount * 0.30, 2)
    network = round(amount * 0.10, 2)

    conn = get_db_connection()
    try:
        curr = conn.cursor()
        curr.execute(
            "INSERT INTO transactions (amount, creator_share, user_pool_share, network_fee, timestamp) VALUES (?, ?, ?, ?, ?)",
            (amount, creator, user_pool, network, datetime.now().isoformat())
        )
        conn.commit()
        
        return {
            "status": "success",
            "transaction_id": curr.lastrowid,
            "split": {
                "creator": creator,
                "user_pool": user_pool,
                "network": network
            }
        }
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()