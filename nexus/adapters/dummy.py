from .base import BaseAdapter
from typing import Dict, Any

class DummyAdapter(BaseAdapter):
    """
    A pass-through adapter for local testing.
    Does not connect to any blockchain.
    """

    async def verify_identity(self, payload: Dict[str, Any]) -> bool:
        # Always return True for local dev
        return True

    async def anchor_state(self, merkle_root: str) -> str:
        # Simulate a transaction hash
        return f"0x_simulated_tx_hash_for_{merkle_root[:8]}"

    async def get_latest_checkpoint(self) -> str:
        # Return a genesis root
        return "0x00000000000000000000000000000000"
