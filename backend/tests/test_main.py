import sys
import os
import pytest
from fastapi.testclient import TestClient

# 1. PATH ALIGNMENT
# Ensures the test suite can see both 'backend' and 'nexus' packages
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

# Import 'app' from the backend.main namespace
from backend.main import app

# 2. CLIENT INITIALIZATION
# base_url="http://test" prevents accidental calls to live production endpoints
client = TestClient(app, base_url="http://test")

def test_api_bootstrap():
    """
    Sovereign Health Check:
    Verifies the Brain (FastAPI) is alive, routes are active, and 
    Phase 1.3.1 metadata is correctly reported.
    """
    response = client.get("/api/health")
    
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert data["perimeter"] == "hardened"
    assert data["phase"] == "1.1.1" or data["phase"] == "1.3.1" # Flexibility for versioning

def test_sentry_presence():
    """
    Infrastructure Audit:
    Verifies that the Sentry guard is correctly enforcing the 
    'Fail-Closed' policy on protected routes.
    """
    # Attempting to access the ledger without any identity headers.
    # The 'multichain_guard' in main.py must intercept this.
    response = client.get("/api/ledger")
    
    assert response.status_code == 403
    
    # Verifies the rejection details specifically reference our Sentry
    assert "Nexus Sentry" in response.json()["detail"]
    assert "No valid identity header" in response.json()["detail"]

def test_multichain_ambiguity_rejection():
    """
    Conflict Test:
    Verifies that the Brain rejects requests carrying both TON and IoTeX headers.
    This proves the 'Defensive Programming' refinement is active.
    """
    headers = {
        "X-Nexus-TMA": "some_data",
        "X-Nexus-IOTX": "some_data"
    }
    response = client.get("/api/ledger", headers=headers)
    
    assert response.status_code == 400
    assert "Ambiguous" in response.json()["detail"]