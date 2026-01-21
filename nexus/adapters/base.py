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

from abc import ABC, abstractmethod
from typing import Dict, Any

class BaseAdapter(ABC):
    """
    Universal Adapter Interface (Phase 1.3.1)
    
    All Nexus Protocol adapters must implement this interface to ensure 
    identity consistency between the Brain (Backend) and Body (Frontend).
    This abstraction allows for 'Hot-Swapping' adapters without ledger mutation.
    """

    @abstractmethod
    async def verify_identity(self, payload: Any) -> Dict[str, Any]:
        """
        Verifies the authenticity of the transport payload.
        
        REQUIRED RETURN SCHEMA:
        {
            "verified": bool,       # Absolute truth of identity resolution
            "user_id": str | None,  # Canonical String ID (Sovereign Namespace)
            "adapter": str,         # Name of the verifying adapter (e.g., 'ton')
            "error": str | None      # Internal error code for Sentry logging
        }

        NOTE: This schema is contractually enforced by convention in Phase 1.3.1. (Audit 3)
        Runtime validation may be introduced in later phases.
        """
        pass