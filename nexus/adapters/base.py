from abc import ABC, abstractmethod
from typing import Dict, Any

class BaseAdapter(ABC):
    """
    The Universal Adapter Interface.
    All chain integrations (peaq, IoTeX, TON, Solana) must inherit from this.
    
    WARNING:
    Adapters MUST be deterministic and side-effect free
    except for explicit 'anchor_state' calls.
    Do not mix business logic with adapter logic.
    """

    @abstractmethod
    async def verify_identity(self, payload: Dict[str, Any]) -> bool:
        """
        Verify an incoming identity claim (e.g., verify peaq ID signature).
        """
        pass

    @abstractmethod
    async def anchor_state(self, merkle_root: str) -> str:
        """
        Send the local Vault's Merkle Root to the target chain.
        Returns the Transaction Hash (tx_hash).
        """
        pass

    @abstractmethod
    async def get_latest_checkpoint(self) -> str:
        """
        Retrieve the last anchored state root from the chain.
        """
        pass
