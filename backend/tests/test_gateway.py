import sys
import os
import pytest
from fastapi.testclient import TestClient

# 1. FIX: Ensure backend directory is in the path for CI/Local consistency
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from main import app

# FIX: Address DeprecationWarning for Python 3.14+ 
# Using explicit transport ensures stability in high-version Python environments.
client = TestClient(app, base_url="http://test")

@pytest.fixture(autouse=True)
def mock_sentry_behavior(monkeypatch):
    """
    Deterministically control Sentry behavior for integration tests.
    Targets the sentry module specifically to override the instance used by Depends.
    """
    # Mock TON: Forces the Sentry to return True, letting the guard proceed to 'authorized'
    monkeypatch.setattr("sentry.sentry.verify_ton_request", lambda _: True)
    
    # Mock IoTeX: Simulates presence but ensures it stays in 'staged' mode.
    # Note: The guard in main.py will see the header and raise the 403.
    def mock_inspect(payload):
        return {
            "present": bool(payload), 
            "verified": False, 
            "mode": "staged"
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
    CRITICAL SECURITY TEST:
    Ensures that a request with NO headers is rejected by the Fail-Closed logic.
    """
    response = client.get("/api/ledger")
    assert response.status_code == 403
    assert "Sentry" in response.json()["detail"]

def test_ledger_access_authorized_ton():
    """
    Verify that a valid TON signature header allows access to the Brain.
    """
    headers = {"X-Nexus-TMA": "valid_mock_signature"}
    response = client.get("/api/ledger", headers=headers)
    
    assert response.status_code == 200
    assert "total_earned" in response.json()

def test_iotex_staging_denies_execution():
    """
    Verify the IoTeX 'Staged' gate is recognized but NOT authorized.
    This proves that Phase 1.3 handles multichain headers without over-authorizing.
    """
    headers = {"X-Nexus-IOTX": "ioID_mock_data"}
    response = client.get("/api/ledger", headers=headers)
    
    # This must be 403 because main.py explicitly raises an exception for IoTeX headers
    assert response.status_code == 403
    assert "staged" in response.json()["detail"].lower()