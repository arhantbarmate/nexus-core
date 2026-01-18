import hmac
import hashlib
import urllib.parse
import os
from fastapi import Request, HTTPException

class Sentry:
    """
    Phase 1.3: Multichain Sentry (v1.3.1)
    
    Perimeter guard enforcing the 'Verify-then-Execute' (VTE) pattern.
    Modularly architected for TON (Social) and IoTeX (DePIN) staging.
    """

    def __init__(self):
        # Explicit Environment Check
        env = os.getenv("NEXUS_ENV", "dev")
        self.bot_token = os.getenv("BOT_TOKEN")

        # Hard-fail in production/non-dev if token is missing
        if env != "dev" and not self.bot_token:
            raise RuntimeError("NEXUS_SENTRY: BOT_TOKEN is required in non-dev environments")

        # Fallback only permitted in explicit 'dev' mode
        if not self.bot_token:
            self.bot_token = "DEV_TOKEN_UNSECURE"

        self._ton_secret_key = self._generate_ton_secret()
        self.iotex_mode = "staged"  # Identity not yet enforced in Phase 1.3

    def _generate_ton_secret(self):
        """Derives a site-specific secret key from the Bot Token per Telegram spec."""
        return hmac.new(
            key=b"WebAppData",
            msg=self.bot_token.encode(),
            digestmod=hashlib.sha256
        ).digest()

    def verify_ton_request(self, init_data: str) -> bool:
        """
        Validates TON/Telegram WebApp initData signatures.
        Logic: Parse -> Sort -> HMAC-SHA256 -> Timing-safe comparison.
        """
        try:
            params = dict(urllib.parse.parse_qsl(init_data, strict_parsing=True))
            received_hash = params.pop("hash", None)
            if not received_hash:
                return False
            
            # Data-check-string must be constructed from alphabetically sorted keys
            data_check_string = "\n".join(
                f"{k}={v}" for k, v in sorted(params.items())
            )
            
            calculated_hash = hmac.new(
                key=self._ton_secret_key,
                msg=data_check_string.encode(),
                digestmod=hashlib.sha256
            ).hexdigest()
            
            return hmac.compare_digest(calculated_hash, received_hash)
        except Exception:
            return False

    def inspect_iotex_request(self, auth_payload: str) -> dict:
        """
        Phase 1.3: IoTeX identity inspection.
        Returns presence metadata but does NOT authorize execution.
        """
        return {
            "present": bool(auth_payload),
            "mode": self.iotex_mode
        }

# Global Instance
sentry = Sentry()

async def multichain_guard(request: Request):
    """
    FastAPI Dependency: Modular Perimeter Gate.
    Enforces network-specific validation with explicit precedence (TON > IoTeX).
    """
    
    # 1. TON/Telegram Perimeter (Active Enforcement)
    ton_data = request.headers.get("X-Nexus-TMA")
    if ton_data:
        if sentry.verify_ton_request(ton_data):
            return {"network": "ton", "verified": True}
        # Explicit rejection for malformed signatures
        raise HTTPException(status_code=403, detail="Invalid TON initData signature")

    # 2. IoTeX DePIN Perimeter (Staged Inspection)
    iotex_data = request.headers.get("X-Nexus-IOTX")
    if iotex_data:
        inspection = sentry.inspect_iotex_request(iotex_data)
        if inspection["present"]:
            # Returns verified: False to signal 'Staged' status to the Brain
            return {
                "network": "iotex", 
                "verified": False, 
                "mode": inspection["mode"]
            }

    # 3. Fail-Closed
    raise HTTPException(
        status_code=403, 
        detail="Nexus Sentry: No valid network perimeter verification found."
    )