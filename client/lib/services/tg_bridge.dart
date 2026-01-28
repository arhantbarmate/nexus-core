import 'package:flutter/foundation.dart';

// 1. THE PLATFORM SWITCHER (Audit 3.0)
// This is the magic line.
// - On Mobile: It imports 'tg_bridge_stub.dart' (The Empty Mock).
// - On Web:    It imports 'tg_bridge_web.dart' (The Real JS).
// We alias it as 'impl' so we can call it uniformly.
import 'tg_bridge_stub.dart'
    if (dart.library.html) 'tg_bridge_web.dart' as impl;

/// 🛡️ TELEGRAM BRIDGE (Service Layer)
/// The single source of truth for all platform interactions.
/// It wraps the raw platform calls in Safety & Caching logic.
class TelegramBridge {
  
  // 2. CACHING STRATEGY (Stress Test Optimization)
  // Accessing JS-Interop is expensive. We cache the ID after the first successful read.
  static String? _cachedUserId;
  static String? _cachedInitData;

  /// Returns the raw InitData string for Backend Authentication.
  /// Returns empty string if not in Telegram (Localhost/Mobile).
  static String get initData {
    // Return cached value if we have it (Fast Path)
    if (_cachedInitData != null) return _cachedInitData!;
    
    try {
      // Safe boundary crossing
      final rawData = impl.TelegramWebApp.initData;
      
      // Validation: Ensure it's not a weird JS "null" string or empty
      if (rawData.isNotEmpty && rawData != "null") {
        _cachedInitData = rawData;
        return _cachedInitData!;
      }
    } catch (e) {
      // Catches "TypeError" if window.Telegram is undefined (Localhost)
      // Catches "UnimplementedError" on Mobile
    }
    
    // Fallback: Return empty string (Backend will treat as Guest)
    return "";
  }

  /// Returns the User ID (String) for UI logic.
  /// Returns "999" (The Sovereign Guest) if not found.
  static String get userId {
    if (_cachedUserId != null) return _cachedUserId!;
    
    try {
      final user = impl.TelegramWebApp.initDataUnsafe?.user;
      if (user != null) {
        _cachedUserId = user.id.toString();
        return _cachedUserId!;
      }
    } catch (e) {
      // Ignore errors in Dev/Browser mode
    }
    
    return "999"; // Fallback to Guest
  }

  /// 3. HAPTIC GUARD
  /// Safely triggers haptics. Ignores errors on old devices.
  static void triggerHaptic() {
    try {
      // Impact 'light' is the most subtle/performant haptic
      impl.TelegramWebApp.hapticFeedback.impactOccurred('light');
    } catch (e) {
      // Old Telegram version or Non-Mobile device -> No-op is safe.
    }
  }

  /// 4. LIFECYCLE SIGNALS
  /// Tells Telegram "We are ready".
  static void ready() {
    try {
      impl.TelegramWebApp.ready();
      impl.TelegramWebApp.expand(); // Auto-expand for immersive feel
    } catch (e) {
      debugPrint("⚠️ Telegram Bridge: Not in TMA Environment (Safe Mode)");
    }
  }
}