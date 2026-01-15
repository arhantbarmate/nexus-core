import os
import sqlite3
import httpx
from datetime import datetime
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

# --- CONFIGURATION ---
load_dotenv()

# Analytics Token from Data Chief Bot (Manage section)
# If this is empty, the node runs in "Stealth Mode" (Local Only)
ANALYTICS_TOKEN = os.getenv("TON_BUILD_API_KEY", "").strip()

# Static Node Identity (Decoupled from URL/Domain for Phase 1.1 Sovereignty)
NODE_ID = "nexus_local_v1"

# --- DATABASE SETUP ---
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, "nexus_vault.db")

def get_db_connection():
    """
    Sovereign Vault: Single-file SQLite.
    WAL mode enabled for high-concurrency performance.
    """
    conn = sqlite3.connect(DB_PATH, timeout=5.0, check_same_thread=False, isolation_level=None)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA journal_mode=WAL;") 
    return conn

# --- LIFESPAN HANDLER ---
@asynccontextmanager
async def lifespan(app: FastAPI):
    # 1. Initialize Local Vault (The Source of Truth)
    conn = get_db_connection()
    conn.execute("""
        CREATE TABLE IF NOT EXISTS transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL NOT NULL,
            creator_share REAL NOT NULL,
            user_pool_share REAL NOT NULL,
            network_fee REAL NOT NULL,
            timestamp TEXT NOT NULL
        )
    """)
    conn.close()

    # 2. Silent Heartbeat (Observability Path)
    # This fires once on startup to signal "Online" status to TON Builders.
    if ANALYTICS_TOKEN:
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                await client.post(
                    "https://builders.ton.org/api/v1/analytics/event",
                    headers={
                        "Authorization": f"Bearer {ANALYTICS_TOKEN}",
                        "Content-Type": "application/json",
                        "User-Agent": "NexusNode/1.1"
                    },
                    json={
                        "event_name": "node_started",
                        "node_id": NODE_ID,
                        "timestamp": datetime.utcnow().isoformat()
                    }
                )
        except Exception:
            # SILENT FAIL: Analytics network errors must never stop the node.
            pass
            
    print(f"✅ Nexus Brain Active: Sovereign Mode | Node ID: {NODE_ID}")
    yield

# --- APP INITIALIZATION ---
app = FastAPI(title="Nexus Protocol Node", version="1.1", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- ANALYTICS HANDSHAKE (Non-Blocking) ---
async def signal_ton_builders(amount: float):
    """
    Sends execution telemetry to TON Builders in the background.
    Failure here does not affect the local ledger.
    """
    if not ANALYTICS_TOKEN:
        return
    try:
        async with httpx.AsyncClient(timeout=3.0) as client:
            await client.post(
                "https://builders.ton.org/api/v1/analytics/event",
                headers={
                    "Authorization": f"Bearer {ANALYTICS_TOKEN}",
                    "Content-Type": "application/json"
                },
                json={
                    "event_name": "split_executed",
                    "amount": float(amount),
                    "node_id": NODE_ID,
                    "timestamp": datetime.utcnow().isoformat()
                }
            )
    except Exception:
        pass

# --- CORE ENDPOINTS ---

@app.post("/execute_split/{amount}")
def execute_split(amount: float, background_tasks: BackgroundTasks):
    """
    Execution Engine: 60-30-10 Deterministic Split.
    """
    if amount <= 0:
        raise HTTPException(status_code=400, detail="Invalid amount")
    
    # 1. Calculate Shares (Deterministic)
    amount = round(amount, 2)
    c = round(amount * 0.6, 2)
    p = round(amount * 0.3, 2)
    f = round(amount * 0.1, 2)
    
    # 2. Atomic Commit to Sovereign Vault
    conn = get_db_connection()
    try:
        conn.execute(
            "INSERT INTO transactions (amount, creator_share, user_pool_share, network_fee, timestamp) VALUES (?, ?, ?, ?, ?)",
            (amount, c, p, f, datetime.utcnow().isoformat())
        )
    finally:
        conn.close()

    # 3. Fire-and-Forget Analytics (Background)
    background_tasks.add_task(signal_ton_builders, amount)

    return {"status": "success", "split": {"creator": c, "pool": p, "fee": f}}

@app.get("/ledger")
def get_ledger():
    """Read-Only View of the Local Ledger"""
    conn = get_db_connection()
    try:
        row = conn.execute("SELECT SUM(creator_share) as c, SUM(user_pool_share) as p, SUM(network_fee) as f FROM transactions").fetchone()
        return {
            "total_earned": round(row['c'] or 0.0, 2),
            "global_user_pool": round(row['p'] or 0.0, 2),
            "protocol_fees": round(row['f'] or 0.0, 2)
        }
    finally:
        conn.close()

@app.get("/transactions")
def get_transactions():
    """Recent Transaction History"""
    conn = get_db_connection()
    try:
        rows = conn.execute("SELECT id, amount, timestamp FROM transactions ORDER BY id DESC LIMIT 10").fetchall()
        return [dict(row) for row in rows]
    finally:
        conn.close()

@app.get("/health")
def health():
    return {"status": "ok", "vault": "active", "node_id": NODE_ID}