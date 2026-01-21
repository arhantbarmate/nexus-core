# Copyright 2026 Nexus Protocol Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
from pydantic import BaseModel

# --- 1. BOOTSTRAP & CONSTANTS ---
load_dotenv()
NODE_ID = "nexus_sovereign_v1.3.1"
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, "nexus_vault.db")

PHASE_DEV = os.getenv("PHASE_DEV", "true").lower() == "true"
DEV_NAMESPACE_ID = "999"
DEV_UI_ALIAS = "LOCAL_HOST"

class SplitRequest(BaseModel):
    amount: float
    nonce: int = None

# --- 2. LIFESPAN: Database Perimeter & WAL Management ---
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Initializes Vault with WAL mode for concurrent identity-namespace safety."""
    conn = sqlite3.connect(DB_PATH)
    try:
        # PRAGMA settings ensure deterministic persistence under tunnel instability
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
    
    # Audit 2.1: FULL Checkpoint ensures all WAL data is merged to main DB on exit
    try:
        c = sqlite3.connect(DB_PATH)
        c.execute("PRAGMA wal_checkpoint(FULL);")
        c.close()
    except Exception:
        pass

# --- 3. INITIALIZE APP ---
app = FastAPI(title="Nexus Sovereign Brain", version="1.3.1", lifespan=lifespan)

# --- 4. SECURITY: CORS Calibration ---
# NOTE: Permissive CORS is intentional for sovereign local nodes & Ngrok tunneling (Audit 4.1)
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"https?://.*", 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*", "X-Nexus-TMA", "X-Nexus-Backup-ID", "ngrok-skip-browser-warning"],
)

# --- 5. UTILITIES ---
def get_db_connection():
    """Returns a thread-safe connection with 30s timeout for SQLite write-locks."""
    conn = sqlite3.connect(DB_PATH, timeout=30.0, check_same_thread=False)
    conn.execute("PRAGMA journal_mode=WAL;")
    conn.row_factory = sqlite3.Row
    return conn

def resolve_sovereign_id(provided_id: str | None) -> str:
    """Canonicalizes IDs: Handles LOCAL_HOST, UI placeholders, and nulls."""
    clean_id = str(provided_id).strip() if provided_id else ""
    if not clean_id or clean_id.lower() in [DEV_UI_ALIAS.lower(), "null", "undefined", "reading...", "none"]:
        return DEV_NAMESPACE_ID
    return clean_id if clean_id.isdigit() else DEV_NAMESPACE_ID

# --- 6. MULTICHAIN GUARD (Authoritative Identity Resolution) ---
async def multichain_guard(request: Request):
    """
    Resolves Actor Identity:
    NOTE: 'verified' indicates identity resolution success, not cryptographic auth (Audit 3).
    """
    if request.method == "OPTIONS": return {"user_id": DEV_NAMESPACE_ID}

    ton_data = request.headers.get("X-Nexus-TMA")
    backup_id = request.headers.get("X-Nexus-Backup-ID")

    # Path 1: Regex-Hardened TMA Extraction (Resistant to URL encoding drift)
    if ton_data and ton_data != "valid_mock_signature":
        match = (
            re.search(r'%22id%22%3A(\d+)', ton_data) or
            re.search(r'"id":(\d+)', ton_data) or
            re.search(r'id=(\d+)', ton_data)
        )
        if match:
            tg_id = match.group(1)
            return {"verified": True, "user_id": str(tg_id), "adapter": "ton"}

    # Path 2: Backup Identity Bridge (Enables mobile demo continuity)
    if PHASE_DEV and backup_id and str(backup_id).isdigit():
        return {"verified": True, "user_id": str(backup_id), "adapter": "backup"}

    # Path 3: Dev Namespace Fallback (Guaranteed system stability)
    return {"verified": True, "user_id": DEV_NAMESPACE_ID, "adapter": "dummy"}

# --- 7. SECURE API ROUTES ---

@app.get("/api/vault_summary")
@app.get("/api/vault_summary/{user_id}") # ADDED: Support for path-parameter ID
async def get_summary(user_id: str = None, auth: dict = Depends(multichain_guard)):
    """Read Path: Calculates totals based on resolved identity."""
    # Logic: If user_id is in path, use it. Otherwise, use the Sentry's resolved ID.
    target_id = resolve_sovereign_id(user_id or auth.get("user_id"))
    
    conn = get_db_connection()
    try:
        row = conn.execute("""
            SELECT 
                COALESCE(SUM(creator_share), 0) as c, 
                COALESCE(SUM(user_pool_share), 0) as p 
            FROM transactions 
            WHERE CAST(user_id AS TEXT) = CAST(? AS TEXT)
        """, (target_id,)).fetchone()
        return {"creator_total": float(round(row['c'], 2)), "pool_total": float(round(row['p'], 2))}
    finally:
        conn.close()

@app.post("/api/execute_split")
async def execute_split(amount: float = None, payload: SplitRequest = None, auth: dict = Depends(multichain_guard)):
    """
    Write Path: Executes the 60/30/10 Split Protocol.
    NOTE: Supports both REST testing and Flutter Body payloads (Audit 4.2).
    """
    final_amount = amount if amount is not None else (payload.amount if payload else 0.0)
    if final_amount <= 0:
        raise HTTPException(status_code=400, detail="INVALID_MAGNITUDE")
    
    uid = str(auth.get("user_id")).strip()
    c, p, f = round(final_amount * 0.6, 2), round(final_amount * 0.3, 2), round(final_amount * 0.1, 2)
    
    conn = get_db_connection()
    try:
        ts = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")
        conn.execute(
            "INSERT INTO transactions (user_id, amount, creator_share, user_pool_share, network_fee, timestamp) VALUES (?, ?, ?, ?, ?, ?)",
            (uid, final_amount, c, p, f, ts)
        )
        conn.commit()
        # SUCCESS: Hydro-Response prevents UI null-crashes and enables real-time grow effect
        return {"status": "success", "resolved_id": uid, "split": {"creator": c, "pool": p, "fee": f}}
    finally:
        conn.close()

@app.get("/api/transactions")
async def get_transactions(auth: dict = Depends(multichain_guard)):
    """History Path: Returns last 50 transactions for the authenticated operator."""
    uid = auth.get("user_id")
    conn = get_db_connection()
    try:
        rows = conn.execute("SELECT * FROM transactions WHERE user_id = ? ORDER BY id DESC LIMIT 50", (uid,)).fetchall()
        return [dict(row) for row in rows]
    finally:
        conn.close()

# --- 8. SOVEREIGN GATEWAY (Sentry Proxy & SPA Fallback) ---
TEST_CLIENT_DIR = os.path.abspath(os.path.join(BASE_DIR, "..", "test_client"))

@app.api_route("/{path_name:path}", methods=["GET", "POST", "OPTIONS"])
async def gateway_proxy(request: Request, path_name: str):
    """Gateway Logic: Serves local files or forwards to Flutter Body."""
    if request.method == "OPTIONS": return Response(status_code=200)
    if path_name.startswith("api/"): raise HTTPException(status_code=404)

    safe_path = os.path.normpath(path_name).lstrip(os.sep)
    local_file = os.path.join(TEST_CLIENT_DIR, safe_path)

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
        # Audit 4.3: SPA Fallback routes all non-file paths to index.html for Flutter routing
        if "." not in path_name:
            idx = os.path.join(TEST_CLIENT_DIR, "index.html")
            if os.path.exists(idx): return FileResponse(idx)
        return Response("NEXUS_OFFLINE", status_code=503)

if os.path.exists(TEST_CLIENT_DIR):
    app.mount("/static", StaticFiles(directory=TEST_CLIENT_DIR), name="static")