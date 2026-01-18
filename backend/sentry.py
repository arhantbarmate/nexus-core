import hmac
import hashlib
import json
import os
import urllib.parse
from dotenv import load_dotenv

load_dotenv()

class NexusSentry:
    def __init__(self):
        self.bot_token = os.getenv("TELEGRAM_BOT_TOKEN", "").strip()
        self.node_id = "nexus_sentry_v1.3.1"

    def verify_ton_request(self, auth_data: str) -> dict:
        """
        Validates Telegram initData and extracts User ID.
        Returns: {'verified': bool, 'user_id': int or None}
        """
        if not auth_data:
            return {"verified": False, "user_id": None}

        # --- DEVELOPMENT BYPASS (Local/Ngrok Testing) ---
        if auth_data == "user=%7B%22id%22%3A123%7D&hash=mock_dev_hash":
            print(f"🛡️ {self.node_id}: Development Bypass Authorized")
            return {"verified": True, "user_id": 123} # Standard Dev ID

        if not self.bot_token:
            print(f"⚠️ {self.node_id}: Missing BOT_TOKEN.")
            return {"verified": False, "user_id": None}

        try:
            # 1. Parse and extract hash
            params = dict(urllib.parse.parse_qsl(auth_data))
            if "hash" not in params:
                return {"verified": False, "user_id": None}

            received_hash = params.pop("hash")
            
            # 2. Extract User ID programmatically from the 'user' JSON string
            user_data = json.loads(params.get("user", "{}"))
            extracted_user_id = user_data.get("id")

            # 3. Reconstruct data_check_string for HMAC validation
            data_check_string = "\n".join([f"{k}={v}" for k, v in sorted(params.items())])

            # 4. Generate Secret Key and Expected Hash
            secret_key = hmac.new(
                "WebAppData".encode(), 
                self.bot_token.encode(), 
                hashlib.sha256
            ).digest()

            expected_hash = hmac.new(
                secret_key, 
                data_check_string.encode(), 
                hashlib.sha256
            ).hexdigest()

            # 5. Final Compare
            is_verified = hmac.compare_digest(received_hash, expected_hash)
            return {
                "verified": is_verified, 
                "user_id": extracted_user_id if is_verified else None
            }

        except Exception as e:
            print(f"❌ {self.node_id}: Verification Error: {e}")
            return {"verified": False, "user_id": None}

    def inspect_iotex_request(self, payload: str) -> dict:
        return {
            "present": bool(payload),
            "verified": False, 
            "mode": "staged",
            "network": "iotex",
            "user_id": None
        }

sentry = NexusSentry()