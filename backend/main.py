import os
import sqlite3
import httpx
from datetime import datetime
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, BackgroundTasks, Header, Depends, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from telegram_init_data import parse

# --- CONFIGURATION ---
load_dotenv()
BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN", "").strip() 
NODE_ID = "nexus_local_v1"

# --- DATABASE SETUP ---
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, "nexus_vault.db")

def get_db_connection():
    conn = sqlite3.connect(DB_PATH, timeout=5.0, check_same_thread=False, isolation_level=None)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA journal_mode=WAL;") 
    return conn

# --- NOTIFICATION LOGIC ---
async def send_telegram_notification(user_id: str, message: str):
    if not BOT_TOKEN or not user_id:
        return
    url = f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"
    payload = {"chat_id": user_id, "text": message, "parse_mode": "Markdown"}
    async with httpx.AsyncClient(timeout=10.0) as client:
        try:
            await client.post(url, json=payload)
        except Exception:
            pass

# --- IDENTITY VERIFICATION ---
def verify_telegram_user(authorization: str = Header(None)):
    # Phase 1.1: Unified Namespace for Sync
    DEBUG_NAMESPACE = "NEXUS_DEV_001"
    result = {
        "ledger_id": DEBUG_NAMESPACE,
        "notification_id": None,
        "username": "Sovereign Developer"
    }
    if authorization and authorization.startswith("tma "):
        try:
            raw_init_data = authorization[4:]
            data = parse(raw_init_data)
            result["notification_id"] = data.get("user", {}).get("id")
            result["username"] = data.get("user", {}).get("username", "Telegram User")
        except:
            pass
    return result

# --- LIFESPAN ---
@asynccontextmanager
async def lifespan(app: FastAPI):
    conn = get_db_connection()
    conn.execute("""
        CREATE TABLE IF NOT EXISTS transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT,
            amount REAL NOT NULL,
            creator_share REAL NOT NULL,
            user_pool_share REAL NOT NULL,
            network_fee REAL NOT NULL,
            timestamp TEXT NOT NULL
        )
    """)
    conn.close()
    print(f"✅ Nexus Gateway Active: {NODE_ID}")
    yield

app = FastAPI(title="Nexus Gateway", version="1.1", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------
# 📡 SECTION A: THE API (NATIVE)
# ---------------------------------------------------------

@app.get("/api/ledger")
def get_ledger(user_data: dict = Depends(verify_telegram_user)):
    ledger_id = user_data["ledger_id"]
    conn = get_db_connection()
    try:
        row = conn.execute(
            "SELECT SUM(creator_share) as c, SUM(user_pool_share) as p, SUM(network_fee) as f FROM transactions WHERE user_id = ?",
            (ledger_id,)
        ).fetchone()
        return {
            "total_earned": round(row['c'] or 0.0, 2),
            "global_user_pool": round(row['p'] or 0.0, 2),
            "protocol_fees": round(row['f'] or 0.0, 2),
            "verified_user": ledger_id
        }
    finally:
        conn.close()

@app.get("/api/transactions")
def get_transactions(user_data: dict = Depends(verify_telegram_user)):
    ledger_id = user_data["ledger_id"]
    conn = get_db_connection()
    try:
        rows = conn.execute(
            "SELECT id, amount, timestamp FROM transactions WHERE user_id = ? ORDER BY id DESC LIMIT 10", 
            (ledger_id,)
        ).fetchall()
        return [dict(row) for row in rows]
    finally:
        conn.close()

@app.post("/api/execute_split/{amount}")
def execute_split(amount: float, background_tasks: BackgroundTasks, user_data: dict = Depends(verify_telegram_user)):
    if amount <= 0: raise HTTPException(status_code=400, detail="Invalid amount")
    
    ledger_id, notification_id = user_data["ledger_id"], user_data["notification_id"]
    username = user_data["username"]
    amount = round(amount, 2)
    c, p, f = round(amount * 0.6, 2), round(amount * 0.3, 2), round(amount * 0.1, 2)
    
    conn = get_db_connection()
    try:
        conn.execute(
            "INSERT INTO transactions (user_id, amount, creator_share, user_pool_share, network_fee, timestamp) VALUES (?, ?, ?, ?, ?, ?)",
            (ledger_id, amount, c, p, f, datetime.utcnow().isoformat())
        )
        if notification_id:
            msg = f"🚀 *Nexus Split!*\n👤 @{username}\n💰 Total: ${amount:.2f}"
            background_tasks.add_task(send_telegram_notification, notification_id, msg)
    finally:
        conn.close()
    return {"status": "success", "split": {"creator": c, "pool": p, "fee": f}}

@app.get("/api/health")
def health():
    return {"status": "ok", "vault": "active"}

# ---------------------------------------------------------
# 🖥️ SECTION B: THE PROXY (GATEWAY TO FLUTTER)
# ---------------------------------------------------------

@app.api_route("/{path_name:path}", methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"])
async def gateway_proxy(request: Request, path_name: str):
    # Proxy everything else to Flutter Dev Server (8080)
    flutter_url = f"http://127.0.0.1:8080/{path_name}"
    
    async with httpx.AsyncClient() as client:
        try:
            proxy_headers = dict(request.headers)
            proxy_headers.pop("host", None)
            
            resp = await client.request(
                request.method,
                flutter_url,
                headers=proxy_headers,
                content=await request.body(),
                params=request.query_params
            )
            
            # Clean headers to prevent browser confusion
            headers = {k: v for k, v in resp.headers.items() if k.lower() not in ['content-length', 'content-encoding', 'transfer-encoding']}
            return Response(content=resp.content, status_code=resp.status_code, headers=headers)
        except Exception:
            return Response("⏳ Nexus Gateway: Waiting for Body (Flutter)... Refresh in 5s.", status_code=502)