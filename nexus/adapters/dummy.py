from .base import BaseAdapter
from typing import Dict, Any

class DummyAdapter(BaseAdapter):
    async def verify_identity(self, payload: Any) -> Dict[str, Any]:
        return {"verified": True, "user_id": 999, "adapter": "dummy"}
