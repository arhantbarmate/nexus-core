import os
import sqlite3
import httpx
import asyncio
from datetime import datetime
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, Depends, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

# Import the corrected Sentry with Dynamic ID support
from sentry import sentry

load_dotenv()
NODE_ID = "nexus_local_v1.3.1"

# --- DATABASE SETUP ---
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, "nexus_vault.db")

def get_db_connection():
    conn = sqlite3.connect(DB_PATH, timeout=5.0, check_same_thread=False)
    conn.row_factory = sqlite3.Row
    return conn

# --- ASYNC NOTIFICATION HOOK (Dynamic Routing) ---
async def send_nexus_notification(chat_id, amount, c, p, f):
    """
    Sends a formatted Telegram DM to the specific user who triggered the split.
    """
    bot_token = os.getenv("TELEGRAM_BOT_TOKEN")
    
    if not bot_token or not chat_id:
        return

    async with httpx.AsyncClient() as client:
        msg = (
            f"🏛️ *Nexus Vault Execution*\n"
            f"━━━━━━━━━━━━━━━\n"
            f"💰 *Total Split:* ${amount:.2f}\n\n"
            f"👤 *Creator (60%):* ${c:.2f}\n"
            f"🌐 *User Pool (30%):* ${p:.2f}\n"
            f"🛡️ *Protocol Fee (10%):* ${f:.2f}\n\n"
            f"✅ _Vault Transaction Verified_"
        )
        try:
            url = f"https://api.telegram.org/bot{bot_token}/sendMessage"
            await client.post(
                url,
                json={"chat_id": chat_id, "text": msg, "parse_mode": "Markdown"}
            )
        except Exception as e:
            print(f"⚠️ Notification Hook Failed: {e}")

# --- MULTICHAIN GUARD (Identity Extractor) ---
async def multichain_guard(request: Request):
    """
    Identifies and verifies the user. 
    Returns a dict containing 'verified' and 'user_id'.
    """
    ton_data = request.headers.get("X-Nexus-TMA")
    if ton_data:
        # Returns {'verified': bool, 'user_id': int}
        auth_status = sentry.verify_ton_request(ton_data)
        if auth_status.get("verified"):
            return auth_status
        raise HTTPException(status_code=403, detail="Nexus Sentry: TON Signature Failed")

    iotex_data = request.headers.get("X-Nexus-IOTX")
    if iotex_data:
        status = sentry.inspect_iotex_request(iotex_data)
        if status.get("verified"):
            return status
        raise HTTPException(status_code=403, detail="Nexus Sentry: IoTeX Staged - Execution Locked")

    raise HTTPException(status_code=403, detail="Nexus Sentry: No Verified Identity Found")

# --- LIFESPAN ---
@asynccontextmanager
async def lifespan(app: FastAPI):
    conn = get_db_connection()
    conn.execute("""
        CREATE TABLE IF NOT EXISTS transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            user_id TEXT, 
            amount REAL, 
            creator_share REAL, 
            user_pool_share REAL, 
            network_fee REAL, 
            timestamp TEXT
        )
    """)
    conn.close()
    print(f"🛡️ Nexus Hardened Gateway Active: {NODE_ID}")
    yield

app = FastAPI(title="Nexus Sovereign Brain", version="1.3.1", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- SECURE API ROUTES ---

@app.get("/api/ledger", dependencies=[Depends(multichain_guard)])
def get_ledger():
    conn = get_db_connection()
    row = conn.execute("SELECT SUM(creator_share) as c, SUM(user_pool_share) as p, SUM(network_fee) as f FROM transactions").fetchone()
    conn.close()
    return {
        "total_earned": round(row['c'] or 0.0, 2),
        "global_user_pool": round(row['p'] or 0.0, 2),
        "protocol_fees": round(row['f'] or 0.0, 2),
        "status": "verified"
    }

@app.get("/api/transactions", dependencies=[Depends(multichain_guard)])
def get_transactions():
    conn = get_db_connection()
    rows = conn.execute("SELECT id, amount, timestamp FROM transactions ORDER BY id DESC LIMIT 10").fetchall()
    conn.close()
    return [dict(row) for row in rows]

@app.post("/api/execute_split/{amount}")
async def execute_split(amount: float, auth: dict = Depends(multichain_guard)):
    """
    Executes split and sends DM to the verified user_id from the 'auth' dependency.
    """
    if amount <= 0:
        raise HTTPException(status_code=400, detail="Invalid amount")
    
    # Extract dynamic user_id from the Multichain Guard
    dynamic_user_id = auth.get("user_id")
    
    c_share = round(amount * 0.60, 2)
    p_share = round(amount * 0.30, 2)
    f_share = round(amount * 0.10, 2)
    
    conn = get_db_connection()
    try:
        conn.execute(
            "INSERT INTO transactions (user_id, amount, creator_share, user_pool_share, network_fee, timestamp) VALUES (?, ?, ?, ?, ?, ?)",
            (str(dynamic_user_id), amount, c_share, p_share, f_share, datetime.utcnow().isoformat())
        )
        conn.commit()
        
        # 🔔 Notify the specific user who triggered the event
        if dynamic_user_id:
            asyncio.create_task(send_nexus_notification(dynamic_user_id, amount, c_share, p_share, f_share))
        
        return {"status": "success", "split": {"creator": c_share, "pool": p_share, "fee": f_share}}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()

@app.get("/api/health")
def health():
    return {"status": "ok", "vault": "active", "perimeter": "hardened"}

# --- PROXY (Body Link) ---
@app.api_route("/{path_name:path}", methods=["GET", "POST", "OPTIONS"])
async def gateway_proxy(request: Request, path_name: str):
    flutter_url = f"http://127.0.0.1:8080/{path_name}"
    async with httpx.AsyncClient(timeout=10.0) as client:
        try:
            proxy_headers = {k: v for k, v in request.headers.items() if not k.lower().startswith("x-nexus-")}
            proxy_headers.pop("host", None)
            resp = await client.request(request.method, flutter_url, headers=proxy_headers, content=await request.body(), params=request.query_params)
            return Response(content=resp.content, status_code=resp.status_code)
        except Exception as e:
            return Response(f"⏳ Nexus Gateway: Connecting to Body...", status_code=503)