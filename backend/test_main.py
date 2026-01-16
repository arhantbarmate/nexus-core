from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_read_root():
    """Sanity check: Ensure the Brain is alive."""
    response = client.get("/")
    # In Phase 1.2, root might return 404 or a status JSON. 
    # We accept 200 or 404 just to prove the server booted.
    assert response.status_code in [200, 404]