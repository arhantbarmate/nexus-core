import sys
import os
import pytest
import sqlite3
from fastapi.testclient import TestClient

# 1. FIX: Ensure backend directory is in the path for CI/Local consistency
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from main import app, DB_PATH

# --- CI DATABASE INITIALIZER ---
@pytest.fixture(scope="session", autouse=True)
def setup_test_db():
    """
    Ensures the database and required tables exist before any tests run.
    This fixes the 'no such table: transactions' error in clean CI environments.
    """
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
    yield
    # Cleanup is optional; for CI, the runner is destroyed anyway.

# Using explicit transport ensures stability in high-version Python environments.
client = TestClient(app, base_url="http://test")

@pytest.fixture(autouse=True)
def mock_sentry_behavior(monkeypatch):
    """
    Deterministically control Sentry behavior for integration tests.
    Updates the mock to return a DICT instead of a BOOL to match v1.3.1 requirements.
    """
    # Mock TON: Now returns the dict required by the multichain_guard
    def mock_verify_ton(auth_data):
        return {"verified": True, "user_id": 123}
    
    monkeypatch.setattr("sentry.sentry.verify_ton_request", mock_verify_ton)
    
    # Mock IoTeX: Simulates presence but ensures it stays in 'staged' mode.
    def mock_inspect(payload):
        return {
            "present": bool(payload), 
            "verified": False, 
            "mode": "staged",
            "network": "iotex",
            "user_id": None
        }
    
    monkeypatch.setattr("sentry.sentry.inspect_iotex_request", mock_inspect)

def test_health_check():
    """Verify that public endpoints remain open and correctly report status."""
    response = client.get("/api/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"
    assert "perimeter" in response.json()

def test_ledger_access_unauthorized():
    """
    Ensures that a request with NO headers is rejected by the Fail-Closed logic.
    """
    response = client.get("/api/ledger")
    assert response.status_code == 403
    assert "Sentry" in response.json()["detail"]

def test_ledger_access_authorized_ton():
    """
    Verify that a valid TON signature header allows access to the Brain.
    Now that setup_test_db exists, this will no longer throw an OperationalError.
    """
    headers = {"X-Nexus-TMA": "valid_mock_signature"}
    response = client.get("/api/ledger", headers=headers)
    
    assert response.status_code == 200
    assert "total_earned" in response.json()

def test_iotex_staging_denies_execution():
    """
    Verify the IoTeX 'Staged' gate is recognized but NOT authorized.
    """
    headers = {"X-Nexus-IOTX": "ioID_mock_data"}
    response = client.get("/api/ledger", headers=headers)
    
    assert response.status_code == 403
    assert "staged" in response.json()["detail"].lower()