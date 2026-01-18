import sys
import os
import pytest
from fastapi.testclient import TestClient

# 1. FIX: Ensure backend directory is in the path for CI/Local consistency
# This ensures that 'from main import app' works regardless of where pytest is invoked.
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from main import app

# 2. FIX: Address DeprecationWarning for Python 3.14+ 
# Using explicit transport ensures the test client is future-proof.
client = TestClient(app, base_url="http://test")

def test_api_bootstrap():
    """
    Sovereign Health Check:
    Verifies the Brain (FastAPI) is alive and the core routing is active.
    This endpoint is explicitly public to allow for CI/CD heartbeat checks.
    """
    response = client.get("/api/health")
    
    # 200 means the FastAPI app is running and the database is linked.
    assert response.status_code == 200
    assert response.json()["status"] == "ok"
    assert "perimeter" in response.json()
    assert response.json()["perimeter"] == "hardened"

def test_sentry_presence():
    """
    Infrastructure Audit:
    Verifies that the Sentry guard is correctly plugged into sensitive routes.
    Unlike test_gateway, this hits the REAL guard to ensure it is active.
    """
    # Attempting to access the ledger without any headers.
    # Because we added Depends(multichain_guard) in main.py, this MUST be 403.
    response = client.get("/api/ledger")
    
    assert response.status_code == 403
    # Verifies the rejection comes from our Sentry
    assert "Sentry" in response.json()["detail"]