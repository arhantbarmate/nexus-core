import 'package:telegram_web_app/telegram_web_app.dart' hide HapticFeedback;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class TelegramBridge {
  /// AUTHENTICATION PERIMETER
  static String get initData {
    try {
      // Use ?. and ?? to handle null-safety according to 0.3.3 specs
      return TelegramWebApp.instance.initData.raw ?? "";
    } catch (_) {
      return "";
    }
  }

  /// IDENTITY RESCUE LOGIC
  /// Hardened for Phase 1.3.1 - Resolves the Null-Safety error
  static String get userId {
    try {
      // FIX: Added ?. before .user to satisfy the compiler
      final user = TelegramWebApp.instance.initDataUnsafe?.user;
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
      // Logic: Use dynamic invocation to bypass package version naming conflicts
      (TelegramWebApp.instance.hapticFeedback as dynamic).notificationOccurred('success');
    } catch (_) {
      // Fallback: This ensures the app doesn't crash if the TMA SDK fails
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