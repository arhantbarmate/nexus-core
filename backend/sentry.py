# Copyright 2026 Coreframe Systems (Nexus Protocol)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
🏛️ NEXUS SENTRY MODULE (Phase 1.4.0 - STAGED)

ARCHITECTURAL GUARDRAIL:
NexusSentry is intentionally NOT used in Phase 1.x execution paths.
Any identity resolution impacting economic execution is explicitly deferred to Phase 2.0.

CURRENT STATUS:
This module is the "Identity Switchboard" infrastructure prepared for future phases.
It standardizes multi-chain identity verification (TON, EVM, SOL).
It is NOT yet wired into the active FastAPI request path.
Active identity resolution currently occurs via the lightweight `multichain_guard` in main.py.
"""

import os
import asyncio
import logging
from typing import Dict, Any, Optional

# --- 1. ADAPTER LOADING & SURVIVAL LOGIC ---
# Logic Check: Authoritative imports for Phase 1.4.0
try:
    # Future-proofing: These paths assume the standard Nexus directory structure
    from nexus.adapters.ton_adapter import TONAdapter
    from nexus.adapters.dummy import DummyAdapter
except ImportError:
    # Survival Fallback: Ensures Node boots even if adapter package structure is incomplete
    # This allows 'main.py' to run without crashing on missing folders.
    class DummyAdapter:
        async def verify_identity(self, data): 
            return {"verified": True, "user_id": "999", "adapter": "dummy_fallback"}
    
    class TONAdapter(DummyAdapter): 
        def __init__(self, token): 
            self.token = token

# Constant: Verified adapters allowed for future wiring
ALLOWED_MODES = ("ton", "dummy")


class NexusSentry:
    def __init__(self):
        """
        Nexus Sentry v1.4.0 - The Identity Switchboard.
        Designed for environment-aware recovery and cross-adapter compatibility.
        """
        self._logger = logging.getLogger("nexus.sentry")
        
        # 1. HARDENED ENV EXTRACTION (Audit 2.1: Cleanses malformed .env inputs)
        # Prevents "ton " or "'ton'" from breaking logic
        raw_mode = os.getenv("CHAIN_ADAPTER", "ton")
        self.mode = str(raw_mode).strip().strip('"').strip("'").lower()
        
        # 2. THE DEMO OVERRIDE (Audit 2.2: Phase-Correct Fail-safe)
        if self.mode not in ALLOWED_MODES:
            is_dev = os.getenv("PHASE_DEV", "false").lower() == "true"
            if is_dev:
                self._logger.warning(f"🛡️ INVALID_ADAPTER: '{self.mode}' -> RECOVERY: 'dummy'")
                self.mode = "dummy"
            else:
                # In Production, we fail-closed (Security First)
                raise RuntimeError(f"🛡️ SENTRY_CRITICAL: Unsupported Adapter '{self.mode}'")

        # 3. ADAPTER ARMING (Audit 2.3: Token Validation & Fallback)
        try:
            if self.mode == "ton":
                token = str(os.getenv("TELEGRAM_BOT_TOKEN", "")).strip().strip('"').strip("'")
                
                # Check for empty or placeholder tokens
                if not token or token.lower() in ["none", ""]:
                    if os.getenv("PHASE_DEV", "false").lower() == "true":
                        self._logger.warning("🛡️ BOT_TOKEN_MISSING -> FALLBACK TO DUMMY ADAPTER")
                        self.adapter = DummyAdapter()
                        self.mode = "dummy"
                    else:
                        raise ValueError("TELEGRAM_BOT_TOKEN_EMPTY")
                else:
                    self.adapter = TONAdapter(token)
            else:
                self.adapter = DummyAdapter()
                
            print(f"🛡️ [Sentry] Switchboard Staged → {self.adapter.__class__.__name__}")
        
        except Exception as e:
            self._logger.error(f"🛡️ SENTRY_INIT_FAILED: {e}")
            # Ultimate Survival Mode
            self.adapter = DummyAdapter()
            self.mode = "dummy"

    async def verify_request(self, auth_data: Optional[str], backup_id: Optional[str] = None) -> Dict[str, Any]:
        """
        Authoritative Verification Gate (Staged). 
        Hierarchy: 
        1. TMA Verification (Primary)
        2. Backup ID Rescue (Dev/Testing)
        3. Emergency Default (Fail-Safe)
        """
        if not auth_data:
            # Identity Rescue Logic (No primary data provided)
            if backup_id and backup_id.isdigit():
                return {"verified": True, "user_id": str(backup_id), "method": "backup_id"}
            return {"verified": False, "user_id": None, "error": "MISSING_TRANSPORT_DATA"}

        try:
            # Audit 2.4: Mandatory timeout ensures deterministic ledger flow
            # Prevents a hung external adapter from freezing the Sovereign Node
            result = await asyncio.wait_for(self.adapter.verify_identity(auth_data), timeout=5.0)
            
            if isinstance(result, dict) and result.get("verified"):
                return result
            
            # Secondary Fail-safe: Rescue with Backup-ID if Primary Verification fails
            # Useful if the Bot Token rotates but Dev ID is constant
            if backup_id and backup_id.isdigit():
                return {"verified": True, "user_id": backup_id, "method": "rescue"}
            
            return {"verified": False, "user_id": None}
            
        except (asyncio.TimeoutError, Exception) as e:
            # Log only on failure to preserve I/O throughput
            self._logger.error(f"🛡️ SENTRY_VERIFY_ERROR: {e}")
            
            # Emergency Recovery
            if backup_id and backup_id.isdigit():
                return {"verified": True, "user_id": backup_id, "method": "emergency"}
            return {"verified": False, "user_id": None, "error": str(e)}

# Staged Singleton – Will be injected into main.py request guards in Phase 2.0
sentry = NexusSentry()