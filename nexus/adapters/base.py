from abc import ABC, abstractmethod
from typing import Dict, Any

class BaseAdapter(ABC):
    """
    Universal Adapter Interface (Phase 1.3.1)
    """
    @abstractmethod
    async def verify_identity(self, payload: Any) -> Dict[str, Any]:
        pass
