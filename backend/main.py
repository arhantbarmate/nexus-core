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
TON_API_KEY = os.getenv("TON_BUILD_API_KEY", "").strip().replace("'", "").replace('"', "")
# MUST match your GitHub Pages URL exactly
REGISTERED_URL = "https://arhantbarmate.github.io/nexus-core/"

# --- DATABASE SETUP ---
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, "nexus_vault.db")

def get_db_connection():
    conn = sqlite3.connect(DB_PATH, timeout=5.0, check_same_thread=False, isolation_level=None)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA journal_mode=WAL;") 
    conn.execute("PRAGMA user_version = 1;")
    return conn

# --- LIFESPAN HANDLER ---
@asynccontextmanager
async def lifespan(app: FastAPI):
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

    if TON_API_KEY:
        try:
            async with httpx.AsyncClient(timeout=10.0, follow_redirects=True) as client:
                response = await client.post(
                    "https://builders.ton.org/api/v1/event",
                    headers={
                        "Authorization": f"Bearer {TON_API_KEY}",
                        "Content-Type": "application/json",
                        "Origin": "https://arhantbarmate.github.io",
                        "Referer": REGISTERED_URL,
                        "User-Agent": "NexusNode/1.1"
                    },
                    json={
                        "event_name": "app_open",
                        "properties": {"node_status": "online"}
                    }
                )
                print(f"TON Startup Heartbeat: {response.status_code}")
        except Exception as e: 
            print(f"TON Startup Error: {e}")
    yield

app = FastAPI(title="Nexus Protocol Node", version="1.1", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

async def signal_ton_builders(amount: float):
    if not TON_API_KEY: return
    try:
        async with httpx.AsyncClient(timeout=5.0, follow_redirects=True) as client:
            await client.post(
                "https://builders.ton.org/api/v1/event",
                headers={
                    "Authorization": f"Bearer {TON_API_KEY}",
                    "Referer": REGISTERED_URL
                },
                json={
                    "event_name": "transaction", 
                    "properties": {"amount": float(amount)}
                }
            )
    except Exception: pass

# --- API ENDPOINTS ---

@app.get("/health")
def health():
    return {"status": "ok", "ton_analytics": "configured" if TON_API_KEY else "disabled"}

@app.post("/execute_split/{amount}")
def execute_split(amount: float, background_tasks: BackgroundTasks):
    if amount <= 0: raise HTTPException(status_code=400, detail="Invalid amount")
    amount = round(amount, 2)
    c, p, f = round(amount*0.6, 2), round(amount*0.3, 2), round(amount*0.1, 2)
    conn = get_db_connection()
    try:
        conn.execute(
            "INSERT INTO transactions (amount, creator_share, user_pool_share, network_fee, timestamp) VALUES (?, ?, ?, ?, ?)",
            (amount, c, p, f, datetime.utcnow().isoformat())
        )
    finally: conn.close()
    background_tasks.add_task(signal_ton_builders, amount)
    return {"status": "success", "split": {"creator": c, "pool": p, "fee": f}}

@app.get("/ledger")
def get_ledger():
    conn = get_db_connection()
    try:
        row = conn.execute("SELECT SUM(creator_share) as c, SUM(user_pool_share) as p, SUM(network_fee) as f FROM transactions").fetchone()
        return {"total_earned": round(row['c'] or 0.0, 2), "global_user_pool": round(row['p'] or 0.0, 2), "protocol_fees": round(row['f'] or 0.0, 2)}
    finally: conn.close()

@app.get("/transactions")
def get_transactions():
    conn = get_db_connection()
    try:
        rows = conn.execute("SELECT id, amount, timestamp FROM transactions ORDER BY id DESC LIMIT 10").fetchall()
        return [dict(row) for row in rows]
    finally: conn.close()