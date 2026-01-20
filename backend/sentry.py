import os
from nexus.adapters.ton_adapter import TONAdapter
from nexus.adapters.dummy import DummyAdapter

# Constant: Source of Truth for allowed adapters
ALLOWED_MODES = ("ton", "dummy")

class NexusSentry:
    def __init__(self):
        # 1. Sanitize and Load Mode
        raw_mode = os.getenv("CHAIN_ADAPTER", "ton")
        self.mode = raw_mode.strip().strip('"').strip("'").lower()
        
        # 2. Validation Check
        if self.mode not in ALLOWED_MODES:
            raise RuntimeError(f"🛡️ Sentry Error: Unsupported Adapter '{self.mode}'. Allowed: {ALLOWED_MODES}")

        # 3. Arm the specific adapter with credentials
        if self.mode == "ton":
            token = os.getenv("TELEGRAM_BOT_TOKEN", "").strip().strip('"').strip("'")
            if not token:
                raise RuntimeError("🛡️ Sentry Error: TELEGRAM_BOT_TOKEN missing for TON mode")
            self.adapter = TONAdapter(token)
        else:
            self.adapter = DummyAdapter()

        print(f"🛡️  [Sentry] Switchboard Active → {self.adapter.__class__.__name__}")

    async def verify_request(self, auth_data: str):
        """Delegates verification to the armed adapter."""
        return await self.adapter.verify_identity(auth_data)

# Singleton instance
sentry = NexusSentry()