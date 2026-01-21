# Copyright 2026 Nexus Protocol Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from .base import BaseAdapter
from typing import Dict, Any
import asyncio

class DummyAdapter(BaseAdapter):
    async def verify_identity(self, payload: Any) -> Dict[str, Any]:
        """
        Nexus Dummy Adapter v1.3.1
        Non-authoritative identity adapter used ONLY in dev, demo, and CI modes.
        Never active in production authority paths. (Audit 3)
        
        Simulates the Sovereign Handshake to verify UI responsiveness and 
        ledger determinism under simulated network conditions.
        """
        
        # ⚡ STRESS TEST: Artificial Latency (200ms) (Audit 2.2)
        # Critical for testing Flutter shimmers, loading states, and 
        # ensuring the 'SYNCING_WITH_BRAIN' status is observable during demos.
        await asyncio.sleep(0.2)

        # 🛡️ IDENTITY DETERMINISM (Audit 2.1)
        # userId is hardcoded to "999" to match the Brain's DEV_NAMESPACE_ID.
        # This ensures numeric continuity across the simulation ledger.
        return {
            "verified": True, 
            "user_id": "999", 
            "adapter": "dummy",
            "mock_mode": True,      # Signal for logging/auditing
            "status": "simulation_active"
        }