import os
import sqlite3
import httpx
import asyncio
import json
from datetime import datetime
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, Depends, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

# --- 1. BOOTSTRAP: Load environment & constants ---
load_dotenv()
NODE_ID = "nexus_local_v1.3.1"
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, "nexus_vault.db")

# --- 2. LIFESPAN: Database Perimeter Initialization ---
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Ensures the Vault is ready and structured before accepting traffic."""
    conn = sqlite3.connect(DB_PATH)
    try:
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
        conn.commit()
    finally:
        conn.close()
    print(f"🛡️ Nexus Hardened Gateway Active: {NODE_ID}")
    yield

# --- 3. INITIALIZE APP (CRITICAL: Must be defined before any @app routes) ---
app = FastAPI(title="Nexus Sovereign Brain", version="1.3.1", lifespan=lifespan)

# --- 4. SENTRY ATTACHMENT ---
# Importing from backend.sentry ensures the Switchboard is armed
from backend.sentry import sentry

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- 5. UTILITIES & DATABASE ---
def get_db_connection():
    """Provides a thread-safe connection to the Nexus Vault."""
    conn = sqlite3.connect(DB_PATH, timeout=5.0, check_same_thread=False)
    conn.row_factory = sqlite3.Row
    return conn

async def send_nexus_notification(chat_id, amount, c, p, f):
    """Sends a formatted Telegram DM to the verified user_id (Side-Effect)."""
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

# --- 6. MULTICHAIN GUARD (Identity Enforcement) ---
async def multichain_guard(request: Request):
    """
    Identifies and verifies the user via the Nexus Sentry Switchboard.
    Phase 1.3.1 Strategy: Priority TON | Staged IoTeX | Conflict Rejection.
    """
    ton_data = request.headers.get("X-Nexus-TMA")
    iotex_data = request.headers.get("X-Nexus-IOTX")

    # DEFENSIVE: Reject ambiguous multichain identities
    if ton_data and iotex_data:
        raise HTTPException(
            status_code=400, 
            detail="Nexus Sentry: Multiple identity headers detected (Ambiguous Origin)"
        )

    # 1. TON/Telegram Header (ACTIVE)
    if ton_data:
        auth_status = await sentry.verify_request(ton_data)
        if auth_status.get("verified"):
            return auth_status
        raise HTTPException(status_code=403, detail="Nexus Sentry: TON Signature Failed")

    # 2. IoTeX Header (STAGED GATE)
    if iotex_data:
        raise HTTPException(
            status_code=403, 
            detail="Nexus Sentry: IoTeX Integration is currently STAGED (Phase 1.3.1)"
        )

    # 3. Fail-Closed Logic: Reject anything without a Nexus identity
    raise HTTPException(status_code=403, detail="Nexus Sentry: No valid identity header found")

# --- 7. SECURE API ROUTES ---

@app.get("/api/health")
def health():
    """Public health endpoint for system monitoring."""
    return {"status": "ok", "vault": "active", "perimeter": "hardened", "phase": "1.3.1"}

@app.get("/api/ledger", dependencies=[Depends(multichain_guard)])
def get_ledger():
    """Provides an aggregated view of the Vault's economic state."""
    conn = get_db_connection()
    try:
        row = conn.execute("""
            SELECT SUM(creator_share) as c, SUM(user_pool_share) as p, SUM(network_fee) as f 
            FROM transactions
        """).fetchone()
        return {
            "total_earned": round(row['c'] or 0.0, 2),
            "global_user_pool": round(row['p'] or 0.0, 2),
            "protocol_fees": round(row['f'] or 0.0, 2),
            "status": "verified"
        }
    finally:
        conn.close()

@app.get("/api/transactions", dependencies=[Depends(multichain_guard)])
def get_transactions():
    """Returns the last 10 verified vault executions."""
    conn = get_db_connection()
    try:
        rows = conn.execute("SELECT id, amount, timestamp FROM transactions ORDER BY id DESC LIMIT 10").fetchall()
        return [dict(row) for row in rows]
    finally:
        conn.close()

@app.post("/api/execute_split/{amount}")
async def execute_split(amount: float, auth: dict = Depends(multichain_guard)):
    """Executes 60-30-10 split and commits to Vault with Audit Logging."""
    if amount <= 0 or amount > 1_000_000:
        raise HTTPException(status_code=400, detail="Nexus Vault: Invalid execution amount")
    
    uid = auth.get("user_id")
    adapter = auth.get("adapter", "unknown")
    
    # Deterministic Split Calculation
    c, p, f = round(amount * 0.6, 2), round(amount * 0.3, 2), round(amount * 0.1, 2)
    
    conn = get_db_connection()
    try:
        conn.execute(
            "INSERT INTO transactions (user_id, amount, creator_share, user_pool_share, network_fee, timestamp) VALUES (?, ?, ?, ?, ?, ?)",
            (str(uid), amount, c, p, f, datetime.utcnow().isoformat())
        )
        conn.commit()
        
        # Structured Audit Log (Machine Readable)
        audit = {"event": "VAULT_EXEC", "user": uid, "amt": amount, "adapter": adapter, "ts": datetime.utcnow().isoformat()}
        print(f"📄 AUDIT_LOG: {json.dumps(audit)}")
        
        # Async Notification (Non-Critical)
        if uid:
            asyncio.create_task(send_nexus_notification(uid, amount, c, p, f))
        
        return {
            "status": "success", 
            "adapter": adapter,
            "split": {"creator": c, "pool": p, "fee": f}
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()

# --- 8. PROXY GATEWAY (Body Link) ---
@app.api_route("/{path_name:path}", methods=["GET", "POST", "OPTIONS"])
async def gateway_proxy(request: Request, path_name: str):
    """Bridges the Sovereign Brain to the Flutter Body (UI Surface)."""
    flutter_url = f"http://localhost:8080/{path_name}"
    async with httpx.AsyncClient(timeout=10.0) as client:
        try:
            # Identity Strip: Body never sees internal Nexus headers
            proxy_headers = {k: v for k, v in request.headers.items() if not k.lower().startswith("x-nexus-")}
            proxy_headers.pop("host", None)
            
            resp = await client.request(
                request.method, 
                flutter_url, 
                headers=proxy_headers, 
                content=await request.body(), 
                params=request.query_params
            )
            return Response(content=resp.content, status_code=resp.status_code)
        except Exception:
            return Response(f"⏳ Nexus Gateway: Connecting to Body...", status_code=503)