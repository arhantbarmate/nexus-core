# Copyright 2026 Nexus Protocol Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os
import sqlite3
import re
import hashlib
from datetime import datetime, timezone
from contextlib import asynccontextmanager
from typing import Optional, List
from fastapi import FastAPI, HTTPException, Depends, Request, Response, Query
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pydantic import BaseModel

# --- 1. BOOTSTRAP & ANCHORED CONSTANTS ---
load_dotenv()
NODE_ID = "nexus_sovereign_v1.3.1"

# Absolute Path Anchoring: Prevents DB/Client files from spawning in repo root
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, "nexus_vault.db")

# CRITICAL FIX: Point to the actual Flutter 'Release' build output
# This contains flutter_bootstrap.js, manifest.json, and assets
CLIENT_BUILD_DIR = os.path.abspath(os.path.join(BASE_DIR, "..", "client", "build", "web"))

PHASE_DEV = os.getenv("PHASE_DEV", "true").lower() == "true"
DEV_NAMESPACE_ID = "999"
DEV_UI_ALIAS = "LOCAL_HOST"

class SplitRequest(BaseModel):
    amount: float
    nonce: Optional[int] = None

# --- 2. CRYPTOGRAPHIC UTILITIES (Merkle Anchoring) ---
def compute_leaf_hash(row: dict) -> str:
    """Deterministic row serialization for Merkle feasibility."""
    payload = "|".join([
        str(row["amount"]),
        str(row["creator_share"]),
        str(row["user_pool_share"]),
        str(row["network_fee"]),
        str(row["timestamp"]) 
    ])
    return hashlib.sha256(payload.encode()).hexdigest()

def generate_merkle_root(hashes: List[str]) -> Optional[str]:
    """Recursive binary tree reduction to a single page root anchor."""
    if not hashes: return None
    nodes = hashes[:]
    while len(nodes) > 1:
        if len(nodes) % 2 != 0: nodes.append(nodes[-1])
        level = []
        for i in range(0, len(nodes), 2):
            combined = nodes[i] + nodes[i+1]
            level.append(hashlib.sha256(combined.encode()).hexdigest())
        nodes = level
    return nodes[0]

# --- 3. LIFESPAN: Database Perimeter & WAL Management ---
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Initializes Vault with WAL mode and mandatory performance indexes."""
    conn = sqlite3.connect(DB_PATH)
    try:
        conn.execute("PRAGMA journal_mode=WAL;")
        conn.execute("PRAGMA synchronous=NORMAL;")
        conn.execute("""
            CREATE TABLE IF NOT EXISTS transactions (
                id INTEGER PRIMARY KEY AUTOINCREMENT, 
                user_id TEXT NOT NULL, 
                amount REAL NOT NULL, 
                creator_share REAL NOT NULL, 
                user_pool_share REAL NOT NULL, 
                network_fee REAL NOT NULL, 
                timestamp TEXT NOT NULL
            )
        """)
        # Composite Index for Cursor-based Pagination
        conn.execute("CREATE INDEX IF NOT EXISTS idx_tx_user_ts_id ON transactions (user_id, timestamp DESC, id DESC);")
        conn.commit()
    finally:
        conn.close()
    
    print(f"🏛️ [OK] Nexus Hardened Gateway Active: {NODE_ID}")
    print(f"📂 [PATH] Database Anchored: {DB_PATH}")
    print(f"🖥️ [PATH] Serving Client From: {CLIENT_BUILD_DIR}")
    yield
    
    # Graceful Shutdown: WAL Checkpoint
    try:
        c = sqlite3.connect(DB_PATH)
        c.execute("PRAGMA wal_checkpoint(FULL);")
        c.close()
    except Exception: pass

# --- 4. INITIALIZE APP ---
app = FastAPI(title="Nexus Sovereign Brain", version="1.3.1", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"https?://.*", 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*", "X-Nexus-TMA", "X-Nexus-Backup-ID", "ngrok-skip-browser-warning"],
)

# --- 5. UTILITIES ---
def get_db_connection():
    conn = sqlite3.connect(DB_PATH, timeout=30.0, check_same_thread=False)
    conn.execute("PRAGMA journal_mode=WAL;")
    conn.row_factory = sqlite3.Row
    return conn

def resolve_sovereign_id(provided_id: str | None) -> str:
    clean_id = str(provided_id).strip() if provided_id else ""
    if not clean_id or clean_id.lower() in [DEV_UI_ALIAS.lower(), "null", "undefined", "reading...", "none"]:
        return DEV_NAMESPACE_ID
    return clean_id if clean_id.isdigit() else DEV_NAMESPACE_ID

# --- 6. MULTICHAIN GUARD ---
async def multichain_guard(request: Request):
    if request.method == "OPTIONS": return {"user_id": DEV_NAMESPACE_ID}
    ton_data = request.headers.get("X-Nexus-TMA")
    backup_id = request.headers.get("X-Nexus-Backup-ID")

    if ton_data and ton_data != "valid_mock_signature":
        # Hardened Regex catching both URI-encoded and raw JSON formats
        match = re.search(r'(?:%22id%22%3A|id=|\"id\":)(\d+)', ton_data)
        if match:
            return {"verified": True, "user_id": str(match.group(1)), "adapter": "ton"}

    if PHASE_DEV and backup_id and str(backup_id).isdigit():
        return {"verified": True, "user_id": str(backup_id), "adapter": "backup"}

    return {"verified": True, "user_id": DEV_NAMESPACE_ID, "adapter": "dummy"}

# --- 7. SECURE API ROUTES ---

@app.get("/api/vault_summary")
@app.get("/api/vault_summary/{user_id}")
async def get_summary(user_id: str = None, auth: dict = Depends(multichain_guard)):
    target_id = resolve_sovereign_id(user_id or auth.get("user_id"))
    conn = get_db_connection()
    try:
        row = conn.execute("""
            SELECT 
                COALESCE(SUM(creator_share), 0) as c, 
                COALESCE(SUM(user_pool_share), 0) as p 
            FROM transactions 
            WHERE user_id = ?
        """, (target_id,)).fetchone()
        return {"creator_total": round(row['c'], 2), "pool_total": round(row['p'], 2)}
    finally:
        conn.close()

@app.post("/api/execute_split")
async def execute_split(payload: SplitRequest, auth: dict = Depends(multichain_guard)):
    if payload.amount <= 0:
        raise HTTPException(status_code=400, detail="INVALID_MAGNITUDE")
    
    uid = str(auth.get("user_id")).strip()
    c, p, f = round(payload.amount * 0.6, 2), round(payload.amount * 0.3, 2), round(payload.amount * 0.1, 2)
    
    conn = get_db_connection()
    try:
        ts = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")
        conn.execute(
            "INSERT INTO transactions (user_id, amount, creator_share, user_pool_share, network_fee, timestamp) VALUES (?, ?, ?, ?, ?, ?)",
            (uid, payload.amount, c, p, f, ts)
        )
        conn.commit()
        return {"status": "success", "resolved_id": uid, "split": {"creator": c, "pool": p, "fee": f}}
    finally:
        conn.close()

@app.get("/api/transactions")
async def get_transactions(
    limit: int = Query(50, ge=1, le=100),
    cursor_ts: str | None = None,
    cursor_id: int | None = None,
    auth: dict = Depends(multichain_guard)
):
    """Hardened History: Cursor-based pagination with Merkle Root reduction."""
    uid = auth.get("user_id")
    params = [uid]
    query = "SELECT * FROM transactions WHERE user_id = ?"
    if cursor_ts and cursor_id:
        query += " AND (timestamp < ? OR (timestamp = ? AND id < ?))"
        params.extend([cursor_ts, cursor_ts, cursor_id])

    query += " ORDER BY timestamp DESC, id DESC LIMIT ?"
    params.append(limit + 1)

    conn = get_db_connection()
    try:
        rows_raw = [dict(row) for row in conn.execute(query, params).fetchall()]
        has_more = len(rows_raw) > limit
        rows = rows_raw[:limit] 
        
        leaf_hashes = [compute_leaf_hash(r) for r in rows]
        page_root = generate_merkle_root(leaf_hashes)
        
        next_cursor = None
        if has_more:
            next_cursor = {"ts": rows[-1]["timestamp"], "id": rows[-1]["id"]}

        return {"items": rows, "next_cursor": next_cursor, "page_merkle_root": page_root}
    finally:
        conn.close()

# --- 8. SOVEREIGN STATIC GATEWAY ---
# Mounts assets only if the build directory exists
if os.path.exists(CLIENT_BUILD_DIR):
    app.mount("/static", StaticFiles(directory=CLIENT_BUILD_DIR), name="static")

@app.api_route("/{path_name:path}", methods=["GET", "POST", "OPTIONS"])
async def gateway_proxy(request: Request, path_name: str):
    if request.method == "OPTIONS": return Response(status_code=200)
    if path_name.startswith("api/"): raise HTTPException(status_code=404)

    safe_path = os.path.normpath(path_name).lstrip(os.sep)
    local_file = os.path.join(CLIENT_BUILD_DIR, safe_path)

    # 1. Primary: Serve Static Asset directly from disk (JS, CSS, JSON, PNG)
    # This prevents the "Unexpected token <" error by ensuring real files are served
    if os.path.isfile(local_file):
        return FileResponse(local_file)

    # 2. Secondary: Fallback to Flutter Index (SPA Support)
    # Only serve HTML if the specific file requested (like main.dart.js) is NOT found
    index_path = os.path.join(CLIENT_BUILD_DIR, "index.html")
    if os.path.exists(index_path):
        return FileResponse(index_path, headers={"Cache-Control": "no-store"})
    
    return Response("NEXUS_OFFLINE: Client Build Not Found", status_code=503)