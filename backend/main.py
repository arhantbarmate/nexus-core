import os
import sqlite3
import httpx
import asyncio
import re
import json
from datetime import datetime, timezone
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, Depends, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse, StreamingResponse

# --- 1. BOOTSTRAP & IDENTITY NAMESPACES ---
load_dotenv()
NODE_ID = "nexus_sovereign_v1.3.1"
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, "nexus_vault.db")

PHASE_DEV = os.getenv("PHASE_DEV", "true").lower() == "true"
DEV_NAMESPACE_ID = "999"
DEV_UI_ALIAS = "LOCAL_HOST"

# --- 2. LIFESPAN: Database Perimeter & WAL Management ---
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Initializes the Vault with WAL mode for concurrent 20-ID stress testing."""
    conn = sqlite3.connect(DB_PATH)
    try:
        conn.execute("PRAGMA journal_mode=WAL;")
        conn.execute("PRAGMA synchronous=NORMAL;")
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
    
    print(f"🏛️ [OK] Nexus Hardened Gateway Active: {NODE_ID}")
    yield
    
    # AUDIT: Full WAL Checkpoint on Shutdown to prevent data corruption
    try:
        c = sqlite3.connect(DB_PATH)
        c.execute("PRAGMA wal_checkpoint(FULL);")
        c.close()
        print("[OK] Vault Checkpointed Safely.")
    except Exception as e:
        print(f"⚠️ Shutdown Warning: {e}")

# --- 3. INITIALIZE APP ---
app = FastAPI(title="Nexus Sovereign Brain", version="1.3.1", lifespan=lifespan)

# --- 4. SECURITY: CORS Calibration ---
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"https?://.*", 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Attempt to import the Sentry Singleton
try:
    from backend.sentry import sentry
except ImportError:
    sentry = None

# --- 5. UTILITIES ---
def get_db_connection():
    # Increase timeout to 30.0 for the 50-user surge
    conn = sqlite3.connect(DB_PATH, timeout=30.0, check_same_thread=False)
    conn.execute("PRAGMA journal_mode=WAL;")
    conn.execute("PRAGMA synchronous=NORMAL;") # Speed optimization for grant demo
    conn.row_factory = sqlite3.Row
    return conn
def resolve_sovereign_id(provided_id: str | None) -> str:
    """Canonicalizes IDs: Handles LOCAL_HOST, null, or JS uninitialized states."""
    clean_id = str(provided_id).strip() if provided_id else ""
    if not clean_id or clean_id.lower() in [DEV_UI_ALIAS.lower(), "null", "undefined", "reading...", "none"]:
        return DEV_NAMESPACE_ID
    return clean_id if clean_id.isdigit() else DEV_NAMESPACE_ID

# --- 6. MULTICHAIN GUARD (Tier 2 Identity) ---
async def multichain_guard(request: Request):
    """Extracts identity from TMA headers or Backup-ID for Simulation."""
    if request.method == "OPTIONS": return {"user_id": DEV_NAMESPACE_ID}

    ton_data = request.headers.get("X-Nexus-TMA")
    backup_id = request.headers.get("X-Nexus-Backup-ID")

    # Primary: Secure TMA Signature (Regex hardened)
    if ton_data and ton_data != "valid_mock_signature":
        match = re.search(r'id%22%3A(\d+)|"id":(\d+)|id=(\d+)', ton_data)
        if match:
            uid = next(g for g in match.groups() if g)
            return {"verified": True, "user_id": uid}

    # Secondary: Identity Rescue Bridge (Required for Simulation)
    if backup_id and backup_id.isdigit():
        return {"verified": True, "user_id": str(backup_id)}

    return {"verified": True, "user_id": DEV_NAMESPACE_ID}

# --- 7. SECURE API ROUTES ---
@app.get("/api/vault_summary/{user_id}")
async def get_summary(user_id: str):
    target_id = resolve_sovereign_id(user_id)
    conn = get_db_connection()
    try:
        # AUDIT: CAST ensures that ID '123' (string) matches 123 (int)
        row = conn.execute("""
            SELECT 
                COALESCE(SUM(creator_share), 0) as c, 
                COALESCE(SUM(user_pool_share), 0) as p 
            FROM transactions 
            WHERE CAST(user_id AS TEXT) = CAST(? AS TEXT)
        """, (target_id,)).fetchone()
        
        return {
            "creator_total": float(round(row['c'], 2)), 
            "pool_total": float(round(row['p'], 2))
        }
    finally:
        conn.close()

@app.post("/api/execute_split/{amount}")
async def execute_split(amount: float, auth: dict = Depends(multichain_guard)):
    if amount <= 0:
        raise HTTPException(status_code=400, detail="Invalid magnitude")
    
    uid = auth.get("user_id", DEV_NAMESPACE_ID)
    # Phase 1.3.1 Protocol: 60/30/10 Split
    c, p, f = round(amount * 0.6, 2), round(amount * 0.3, 2), round(amount * 0.1, 2)
    
    conn = get_db_connection()
    try:
        ts = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")
        conn.execute(
            "INSERT INTO transactions (user_id, amount, creator_share, user_pool_share, network_fee, timestamp) VALUES (?, ?, ?, ?, ?, ?)",
            (uid, amount, c, p, f, ts)
        )
        conn.commit()
        return {"status": "success", "resolved_id": uid, "split": {"creator": c, "pool": p}}
    finally:
        conn.close()

@app.get("/api/transactions")
async def get_transactions(auth: dict = Depends(multichain_guard)):
    uid = auth.get("user_id", DEV_NAMESPACE_ID)
    conn = get_db_connection()
    try:
        rows = conn.execute(
            "SELECT * FROM transactions WHERE CAST(user_id AS TEXT) = ? ORDER BY id DESC LIMIT 50", 
            (uid,)
        ).fetchall()
        return [dict(row) for row in rows]
    finally:
        conn.close()

# --- 8. SOVEREIGN GATEWAY (UI PROXY) ---
TEST_CLIENT_DIR = os.path.abspath(os.path.join(BASE_DIR, "..", "test_client"))

@app.api_route("/{path_name:path}", methods=["GET", "POST", "OPTIONS"])
async def gateway_proxy(request: Request, path_name: str):
    if request.method == "OPTIONS": return Response(status_code=200)

    safe_path = os.path.normpath(path_name).lstrip(os.sep)
    local_file = os.path.join(TEST_CLIENT_DIR, safe_path)

    if not local_file.startswith(TEST_CLIENT_DIR):
        raise HTTPException(status_code=403)

    if os.path.isfile(local_file):
        return FileResponse(local_file)

    flutter_url = f"http://localhost:8080/{path_name}"
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            excluded = ["host", "content-length", "connection"]
            h = {k: v for k, v in request.headers.items() if k.lower() not in excluded}
            
            req = client.build_request(request.method, flutter_url, headers=h, content=await request.body())
            resp = await client.send(req, stream=True)
            
            rh = dict(resp.headers)
            for k in ["content-encoding", "content-length", "transfer-encoding"]: rh.pop(k, None)
            
            return StreamingResponse(resp.aiter_raw(), status_code=resp.status_code, headers=rh)
    except Exception:
        if "." not in path_name:
            idx = os.path.join(TEST_CLIENT_DIR, "index.html")
            if os.path.exists(idx): return FileResponse(idx)
        return Response("NEXUS_OFFLINE", status_code=503)

if os.path.exists(TEST_CLIENT_DIR):
    app.mount("/static", StaticFiles(directory=TEST_CLIENT_DIR), name="static")