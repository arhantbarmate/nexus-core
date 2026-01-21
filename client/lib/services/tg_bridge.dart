// Copyright 2026 Nexus Protocol Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// 🛰️ NEXUS IDENTITY SWITCHBOARD (Phase 1.3.1)
/// This file manages conditional exports to ensure the Sovereign Node remains 
/// platform-agnostic while supporting the Telegram Mini App SDK on Web.

export 'tg_bridge_stub.dart'
    if (dart.library.js_interop) 'tg_bridge_web.dart';