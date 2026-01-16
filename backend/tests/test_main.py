from fastapi.testclient import TestClient
import sys
import os

# Add the parent directory to sys.path so we can import 'main'
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from main import app

client = TestClient(app)

def test_api_bootstrap():
    """
    Sovereign Health Check:
    Verifies the Brain (FastAPI) is alive and the Vault is accessible.
    We hit /api/health to bypass the Flutter Proxy (which would 502 in CI).
    """
    response = client.get("/api/health")
    
    # 200 means the FastAPI app is running and the database is linked.
    assert response.status_code == 200
    assert response.json()["status"] == "ok"