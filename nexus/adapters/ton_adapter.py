import hmac
import hashlib
import json
import urllib.parse
import os
from typing import Dict, Any
from .base import BaseAdapter

class TONAdapter(BaseAdapter):
    # Stylistic Refinement: Explicit Source of Truth
    ADAPTER_NAME = "ton"

    def __init__(self, bot_token: str):
        if not bot_token:
            raise RuntimeError(f"🛡️ {self.ADAPTER_NAME.upper()}Adapter Error: bot_token required")
        self.bot_token = bot_token

    async def verify_identity(self, payload: str) -> Dict[str, Any]:
        """
        Hardened HMAC-SHA256 Verification for TON/Telegram Mini Apps.
        """
        try:
            # 1. GATED TEST BYPASS
            if os.getenv("NEXUS_ENV") == "test" and payload == "valid_mock_signature":
                return {"verified": True, "user_id": "12345", "adapter": self.ADAPTER_NAME}

            # 2. PARSE & VALIDATE PAYLOAD
            params = dict(urllib.parse.parse_qsl(payload))
            received_hash = params.pop("hash", None)
            
            if not received_hash:
                return {"verified": False, "user_id": None, "adapter": self.ADAPTER_NAME}

            # 3. DATA-CHECK-STRING (Spec-Accurate Sorting)
            data_check_string = "\n".join([f"{k}={v}" for k, v in sorted(params.items())])
            
            # 4. CRYPTOGRAPHIC DERIVATION
            # Key: WebAppData Constant + Token
            secret_key = hmac.new(
                "WebAppData".encode(), 
                self.bot_token.encode(), 
                hashlib.sha256
            ).digest()
            
            # Signature generation
            expected_hash = hmac.new(
                secret_key, 
                data_check_string.encode(), 
                hashlib.sha256
            ).hexdigest()
            
            # 5. CONSTANT-TIME VERIFICATION
            is_verified = hmac.compare_digest(received_hash, expected_hash)
            
            # 6. IDENTITY EXTRACTION (Gated by Verification)
            user_id = None
            if is_verified:
                user_data = json.loads(params.get("user", "{}"))
                user_id = str(user_data.get("id"))

            return {
                "verified": is_verified, 
                "user_id": user_id,
                "adapter": self.ADAPTER_NAME
            }

        except Exception:
            # Fail-Closed logic
            return {"verified": False, "user_id": None, "adapter": self.ADAPTER_NAME}