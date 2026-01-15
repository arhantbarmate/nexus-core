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
# Hardened API Key loading: removes quotes and whitespace to prevent token corruption
TON_API_KEY = os.getenv("TON_BUILD_API_KEY", "").strip().replace("'", "").replace('"', "")

# MUST match the URL exactly as registered in the TON Builders Dashboard.
# This aligns the local node's identity with the GitHub Pages deployment.
REGISTERED_URL = "https://arhantbarmate.github.io/nexus-core/"

# --- DATABASE SETUP ---
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, "nexus_vault.db")

def get_db_connection():
    """
    Creates a connection to the local SQLite vault.
    Optimized for sovereign concurrency with WAL mode and a 5s timeout.
    """
    conn = sqlite3.connect(DB_PATH, timeout=5.0, check_same_thread=False, isolation_level=None)
    conn.row_factory = sqlite3.Row
    # Enable Write-Ahead Logging for high-concurrency environments
    conn.execute("PRAGMA journal_mode=WAL;") 
    conn.execute("PRAGMA user_version = 1;")
    return conn

# --- LIFESPAN HANDLER (Startup Heartbeat) ---
@asynccontextmanager
async def lifespan(app: FastAPI):
    # 1. Initialize Local Vault Table
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

    # 2. Signaling the TON Builders Ecosystem
    if TON_API_KEY:
        try:
            # follow_redirects=True is required for many 2026 API gateways
            async with httpx.AsyncClient(timeout=10.0, follow_redirects=True) as client:
                response = await client.post(
                    "https://builders.ton.org/api/v1/event",
                    headers={
                        "Authorization": f"Bearer {TON_API_KEY}",
                        "Content-Type": "application/json",
                        "Origin": "https://arhantbarmate.github.io",
                        "Referer": REGISTERED_URL,
                        "User-Agent": "NexusNode/1.1 (Sovereign Framework)"
                    },
                    json={
                        "event_name": "app_open",
                        "properties": {"node_status": "online", "environment": "local_dev"}
                    }
                )
                print(f"TON Startup Heartbeat: {response.status_code}")
        except Exception as e: 
            print(f"TON Startup Error: {e}")
    yield

# --- APP INITIALIZATION ---
app = FastAPI(title="Nexus Protocol Node", version="1.1", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- ANALYTICS HANDSHAKE ---
async def signal_ton_builders(amount: float):
    """Sends non-blocking telemetry to TON Builders for observability."""
    if not TON_API_KEY: 
        return
    try:
        async with httpx.AsyncClient(timeout=5.0, follow_redirects=True) as client:
            # We use the same identity headers to ensure authorized origin verification
            await client.post(
                "https://builders.ton.org/api/v1/event",
                headers={
                    "Authorization": f"Bearer {TON_API_KEY}",
                    "Referer": REGISTERED_URL
                },
                json={
                    "event_name": "transaction", 
                    "properties": {
                        "amount": float(amount),
                        "currency": "USD"
                    }
                }
            )
    except Exception: 
        pass

# --- API ENDPOINTS ---

@app.get("/health")
def health():
    """Confirms local node status and analytics configuration."""
    return {
        "status": "ok", 
        "ton_analytics": "configured" if TON_API_KEY else "disabled", 
        "timestamp": datetime.utcnow().isoformat()
    }

@app.post("/execute_split/{amount}")
def execute_split(amount: float, background_tasks: BackgroundTasks):
    """
    The Core Engine: Executes 60-30-10 split and persists to Sovereign Vault.
    Signals external analytics dashboard in the background.
    """
    if amount <= 0: 
        raise HTTPException(status_code=400, detail="Invalid amount")
    
    amount = round(amount, 2)
    creator, pool, fee = round(amount*0.6, 2), round(amount*0.3, 2), round(amount*0.1, 2)
    
    conn = get_db_connection()
    try:
        # Atomic commit to the local sovereign vault (SQLite)
        conn.execute(
            "INSERT INTO transactions (amount, creator_share, user_pool_share, network_fee, timestamp) VALUES (?, ?, ?, ?, ?)",
            (amount, creator, pool, fee, datetime.utcnow().isoformat())
        )
    finally: 
        conn.close()

    # Fire background task so network latency doesn't slow down the local split process
    background_tasks.add_task(signal_ton_builders, amount)

    return {
        "status": "success", 
        "split": {"creator": creator, "pool": pool, "fee": fee}
    }

@app.get("/ledger")
def get_ledger():
    """Aggregates all historical split data from the local vault."""
    conn = get_db_connection()
    try:
        row = conn.execute("""
            SELECT 
                SUM(creator_share) as total_earned, 
                SUM(user_pool_share) as global_user_pool, 
                SUM(network_fee) as protocol_fees 
            FROM transactions
        """).fetchone()
        
        return {
            "total_earned": round(row["total_earned"] or 0.0, 2),
            "global_user_pool": round(row["global_user_pool"] or 0.0, 2),
            "protocol_fees": round(row["protocol_fees"] or 0.0, 2)
        }
    finally:
        conn.close()

@app.get("/transactions")
def get_transactions():
    """Returns a history of the last 10 local split events."""
    conn = get_db_connection()
    try:
        rows = conn.execute("""
            SELECT id, amount, timestamp 
            FROM transactions 
            ORDER BY id DESC 
            LIMIT 10
        """).fetchall()
        return [dict(row) for row in rows]
    finally:
        conn.close()