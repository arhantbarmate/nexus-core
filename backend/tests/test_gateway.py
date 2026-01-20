import sys
import os
import pytest
import sqlite3
from fastapi.testclient import TestClient

# 1. Path alignment: Ensures pytest sees 'backend' and 'nexus' folders
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

from backend.main import app, DB_PATH

# 2. CI Database Setup
@pytest.fixture(scope="session", autouse=True)
def setup_test_db():
    conn = sqlite3.connect(DB_PATH)
    conn.execute("""
        CREATE TABLE IF NOT EXISTS transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            user_id TEXT, amount REAL, creator_share REAL, 
            user_pool_share REAL, network_fee REAL, timestamp TEXT
        )""")
    conn.commit()
    conn.close()
    yield

client = TestClient(app)

# 3. THE CRITICAL MOCK: Bypassing real crypto for logic testing
@pytest.fixture(autouse=True)
def mock_sentry_behavior(monkeypatch):
    """
    Surgical Monkeypatch:
    Forces the Sentry Switchboard to return 'verified' for our specific test string.
    This allows us to test the Vault without needing a real Telegram bot token.
    """
    async def mock_verify_request(auth_data):
        if auth_data == "valid_mock_signature":
            return {"verified": True, "user_id": "12345", "adapter": "ton"}
        return {"verified": False, "user_id": None}

    # Targets the 'sentry' instance that main.py imported from backend.sentry
    monkeypatch.setattr("backend.main.sentry.verify_request", mock_verify_request)

# --- FINANCIAL LOGIC TESTS ---

def test_execute_split_math():
    """Verifies the 60-30-10 logic in the Sovereign Brain."""
    headers = {"X-Nexus-TMA": "valid_mock_signature"}
    response = client.post("/api/execute_split/100", headers=headers)
    
    assert response.status_code == 200
    res_data = response.json()["split"]
    assert res_data["creator"] == 60.0
    assert res_data["pool"] == 30.0
    assert res_data["fee"] == 10.0

# --- SECURITY BOUNDARY TESTS ---

def test_health_check():
    """Verify public health endpoint is accessible."""
    response = client.get("/api/health")
    assert response.status_code == 200

def test_iotex_staged_denial():
    """
    Verify that IoTeX headers are recognized but rejected during Phase 1.3.1.
    This ensures our multichain routing logic is working as intended.
    """
    headers = {"X-Nexus-IOTX": "io_mock_data"}
    response = client.get("/api/ledger", headers=headers)
    
    assert response.status_code == 403
    assert "staged" in response.json()["detail"].lower()