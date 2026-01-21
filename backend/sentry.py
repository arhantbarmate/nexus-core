import os
import asyncio
import logging
from nexus.adapters.ton_adapter import TONAdapter
from nexus.adapters.dummy import DummyAdapter

# Constant: Source of Truth for allowed adapters
ALLOWED_MODES = ("ton", "dummy")

class NexusSentry:
    def __init__(self):
        """
        Nexus Sentry v1.3.1 - Hardened Edition.
        Designed to prevail against environment corruption and transport failure.
        """
        self._logger = logging.getLogger("nexus.sentry")
        
        # 1. HARDENED ENV EXTRACTION
        # Logic: We cast to string immediately to prevent NoneType attribute errors.
        raw_mode = os.getenv("CHAIN_ADAPTER", "ton")
        self.mode = str(raw_mode).strip().strip('"').strip("'").lower()
        
        # 2. THE DEMO OVERRIDE (Stress-Test Fail-safe)
        # Loophole Fix: If user sets an invalid mode, we check PHASE_DEV to prevent a Boot-Loop.
        if self.mode not in ALLOWED_MODES:
            is_dev = os.getenv("PHASE_DEV", "false").lower() == "true"
            if is_dev:
                self._logger.warning(f"🛡️ INVALID_ADAPTER: '{self.mode}' -> RECOVERY: 'dummy'")
                self.mode = "dummy"
            else:
                raise RuntimeError(f"🛡️ SENTRY_CRITICAL: Unsupported Adapter '{self.mode}'")

        # 3. ADAPTER ARMING
        try:
            if self.mode == "ton":
                # Ensure token isn't just whitespace or "None" string
                token = str(os.getenv("TELEGRAM_BOT_TOKEN", "")).strip().strip('"').strip("'")
                if not token or token.lower() == "none":
                    raise ValueError("TELEGRAM_BOT_TOKEN_EMPTY")
                self.adapter = TONAdapter(token)
            else:
                self.adapter = DummyAdapter()
                
            print(f"🛡️  [Sentry] Switchboard Active → {self.adapter.__class__.__name__}")
        
        except Exception as e:
            # Stress-Test Logic: A Sentry must NEVER crash the server process on a failed init.
            # It should instead lock into a safe-fail state.
            self._logger.error(f"🛡️ SENTRY_INIT_FAILED: {e}")
            self.adapter = DummyAdapter()
            self.mode = "dummy"

    async def verify_request(self, auth_data: str) -> dict:
        """
        Authoritative verification gate. 
        Guarantees a dictionary return even if the adapter crashes or times out.
        """
        # Audit Check: Reject empty transport data before wasting CPU cycles
        if not auth_data or not isinstance(auth_data, str):
            return {"verified": False, "user_id": None, "error": "MISSING_TRANSPORT_DATA"}

        try:
            # Stress-Test: Enforce a strict 5-second timeout on the adapter
            # Prevents a slow Telegram API from hanging your local Brain
            result = await asyncio.wait_for(self.adapter.verify_identity(auth_data), timeout=5.0)
            
            # Logic Guard: Ensure the adapter returned the required schema
            if isinstance(result, dict) and "verified" in result:
                return result
            
            self._logger.error(f"🛡️ ADAPTER_SCHEMA_BREACH: Received {type(result)}")
            return {"verified": False, "user_id": None}
            
        except asyncio.TimeoutError:
            self._logger.error("🛡️ SENTRY_TIMEOUT: Adapter unresponsive")
            return {"verified": False, "user_id": None, "error": "ADAPTER_TIMEOUT"}
        except Exception as e:
            self._logger.error(f"🛡️ SENTRY_RUNTIME_ERROR: {e}")
            return {"verified": False, "user_id": None, "error": "INTERNAL_FAILURE"}

# Singleton instance for global Brain orchestration
sentry = NexusSentry()