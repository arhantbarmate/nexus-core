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

import 'package:flutter/foundation.dart';

/// 🛡️ CI/DESKTOP SAFETY NET (Hardened for Phase 1.3.1)
/// NOTE: This stub intentionally collapses all non-web execution into the dev namespace.
/// It guarantees deterministic behavior across CI, Desktop, and local testing.
class TelegramBridge {
  
  /// 🔍 ENVIRONMENT VALIDATION
  /// Always false on Desktop/CI to trigger Sovereign fallbacks.
  static bool get isSupported => false;

  /// 🛠️ SYSTEM COMMANDS (NO-OP)
  /// Call symmetry preserved to allow platform-agnostic UI code.
  static void ready() {}
  static void expand() {}

  /// 🛡️ IDENTITY EXTRACTION (STUB)
  /// Always empty; triggers the Brain's backup identity resolution path.
  static String get initData => "";

  /// 🛰️ IDENTITY RESCUE (STUB)
  /// Returns "LOCAL_HOST" to match the Sentry and Brain's canonicalization.
  /// This ensures Desktop/CI always maps to the '999' dev namespace.
  static String get userId => "LOCAL_HOST"; 

  /// ⚡ HAPTIC SENTRY (NO-OP)
  /// Safe degradation on platforms without the Telegram SDK injection.
  static void triggerHaptic() {
    debugPrint("🏛️ [Stub] Haptic_Trigger_Ignored: Platform Not Supported");
  } 
}