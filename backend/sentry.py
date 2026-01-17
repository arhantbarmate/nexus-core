import hmac
import hashlib
import urllib.parse
import os
from fastapi import Request, HTTPException

class Sentry:
    """
    Phase 1.3: The Sentry
    Validates Telegram WebApp initData to establish request legitimacy.
    
    NOTE: This establishes that the request originated from the 
    authorized Telegram Mini App. It does NOT establish high-level 
    identity or cryptographic ownership (reserved for Phase 2.0).
    """
    def __init__(self):
        # Fallback to a placeholder for CI/Dev; Production requires real BOT_TOKEN
        self.bot_token = os.getenv("BOT_TOKEN", "DEV_TOKEN_UNSECURE")
        self._secret_key = self._generate_secret_key()

    def _generate_secret_key(self):
        """Derives a site-specific secret key from the Bot Token per Telegram spec."""
        return hmac.new(
            key=b"WebAppData",
            msg=self.bot_token.encode(),
            digestmod=hashlib.sha256
        ).digest()

    def verify_request(self, init_data: str) -> bool:
        """
        Validates the raw initData string signature.
        Logic: Parse -> Sort -> HMAC-SHA256 -> Timing-safe comparison.
        """
        try:
            params = dict(urllib.parse.parse_qsl(init_data, strict_parsing=True))
            if "hash" not in params:
                return False
            
            received_hash = params.pop("hash")
            
            # Data-check-string must be constructed from alphabetically sorted keys
            data_check_string = "\n".join(
                f"{k}={v}" for k, v in sorted(params.items())
            )
            
            calculated_hash = hmac.new(
                key=self._secret_key,
                msg=data_check_string.encode(),
                digestmod=hashlib.sha256
            ).hexdigest()
            
            return hmac.compare_digest(calculated_hash, received_hash)
        except Exception:
            return False

# Global Instance
sentry = Sentry()

async def telegram_guard(request: Request):
    """
    FastAPI Dependency: X-Nexus-TMA Header Check.
    Ensures the request perimeter is hardened before reaching the Brain.
    """
    auth_data = request.headers.get("X-Nexus-TMA")
    
    if not auth_data or not sentry.verify_request(auth_data):
        raise HTTPException(
            status_code=403, 
            detail="Nexus Sentry: Request legitimacy could not be verified."
        )
    return True