from fastapi.testclient import TestClient
import sys
import os

# Add the parent directory to sys.path so we can import 'main'
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from main import app

client = TestClient(app)

def test_api_bootstrap():
    """
    Smoke Test:
    Verifies that the FastAPI application boots correctly
    and can accept incoming HTTP requests without crashing.
    """
    # We attempt to hit the root endpoint.
    # Receiving *any* valid HTTP status (200 OK or 404 Not Found)
    # proves the server is up and handling traffic.
    response = client.get("/")
    assert response.status_code in [200, 404]