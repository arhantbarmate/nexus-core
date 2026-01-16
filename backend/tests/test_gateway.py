import pytest
from fastapi.testclient import TestClient
from main import app, get_db_connection

client = TestClient(app)

def setup_module(module):
    """ Ensure the database table exists before running tests """
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

def test_ledger_access():
    response = client.get("/api/ledger")
    assert response.status_code == 200
    assert "total_earned" in response.json()

def test_health_check():
    response = client.get("/api/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"