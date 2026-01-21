import 'package:telegram_web_app/telegram_web_app.dart' hide HapticFeedback;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class TelegramBridge {
  /// AUTHENTICATION PERIMETER
  static String get initData {
    try {
      // FIXED: Removed redundant '?? ""' (Line 10) 
      // The compiler knows 'raw' is non-nullable here.
      return TelegramWebApp.instance.initData.raw;
    } catch (_) {
      return "";
    }
  }

  /// IDENTITY RESCUE LOGIC
  /// Hardened for Phase 1.3.1 - Resolves the Null-Safety error
  static String get userId {
    try {
      final user = TelegramWebApp.instance.initDataUnsafe.user;
      if (user != null && user.id != 0) {
        return user.id.toString();
      }
    } catch (e) {
      debugPrint("🏛️ [Bridge] Identity_Extraction_Failure: $e");
    }
    return "LOCAL_HOST";
  }

  /// HAPTIC FEEDBACK BRIDGE
  /// Logic: Uses the 0.3.3 compliant enum naming
  static void triggerHaptic() {
    try {
      (TelegramWebApp.instance.hapticFeedback as dynamic).notificationOccurred('success');
    } catch (_) {
      HapticFeedback.mediumImpact();
    }
  }

  /// SYSTEM CONTROLS
  static void ready() {
    try {
      TelegramWebApp.instance.ready();
    } catch (_) {}
  }

  static void expand() {
    try {
      TelegramWebApp.instance.expand();
    } catch (_) {}
  }

  static bool get isSupported {
    if (!kIsWeb) return false;
    try {
      return TelegramWebApp.instance.isSupported;
    } catch (_) {
      return false;
    }
  }
}