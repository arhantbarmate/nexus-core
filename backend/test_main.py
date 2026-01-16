from fastapi.testclient import TestClient
from main import app

# Create the test client using the FastAPI app
client = TestClient(app)

def test_health_check():
    """Verify that the Gateway Health endpoint is reachable."""
    response = client.get("/api/health")
    # In Phase 1.2, a 200 OK means the Brain is healthy
    assert response.status_code == 200

def test_ledger_access():
    """Verify that the Vault (Ledger) can be read."""
    response = client.get("/api/ledger")
    assert response.status_code == 200
    assert "total_earned" in response.json()