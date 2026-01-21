import 'dart:js_util' as js_util;
import 'package:flutter/foundation.dart';

/// NEXUS_IDENTITY_GUARD v1.3.1
/// High-Level Architectural Bridge for Sovereign Identity Extraction.
class TelegramIdentity {
  
  /// HIGH-LEVEL AUDIT: 
  /// The "IDLE_HUNG" Bug: Raw JS access can hang if the Telegram Object is 
  /// injected but not yet hydrated. We've added a deterministic fallback chain.
  static String getUserId() {
    // 1. Platform Perimeter Check
    if (!kIsWeb) return "LOCAL_HOST";

    try {
      // 2. The Global Reference Chain
      // High-level access via js_util ensures we don't crash if 'window' is restricted
      final dynamic window = js_util.globalThis;
      final dynamic telegram = js_util.getProperty(window, 'Telegram');
      
      if (telegram != null) {
        final dynamic webApp = js_util.getProperty(telegram, 'WebApp');
        if (webApp != null) {
          final dynamic initDataUnsafe = js_util.getProperty(webApp, 'initDataUnsafe');
          final dynamic user = js_util.getProperty(initDataUnsafe, 'user');
          
          if (user != null) {
            final dynamic id = js_util.getProperty(user, 'id');
            if (id != null && id.toString() != "0") {
              return id.toString();
            }
          }
        }
      }
    } catch (e) {
      // STRESS TEST LOGIC: Never let an identity failure crash the UI boot.
      debugPrint("🏛️ [SENTRY_CRITICAL] Identity Bridge Breach: $e");
    }

    // 3. SOVEREIGN FALLBACK
    // Ensuring the return is NEVER null to prevent 'URI.parse' crashes in NexusApi
    return "LOCAL_HOST";
  }

  /// HIGH-LEVEL STRESS TEST: Secure Envelope Extraction
  /// This retrieves the raw 'initData' string required for the Sentry's 
  /// cryptographic signature verification in the Brain.
  static String? getRawAuthData() {
    if (!kIsWeb) return null;
    
    try {
      final dynamic window = js_util.globalThis;
      final dynamic telegram = js_util.getProperty(window, 'Telegram');
      final dynamic webApp = js_util.getProperty(telegram, 'WebApp');
      
      final String? initData = js_util.getProperty(webApp, 'initData');
      return (initData != null && initData.isNotEmpty) ? initData : null;
    } catch (_) {
      return null;
    }
  }
}