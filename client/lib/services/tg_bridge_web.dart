import 'package:telegram_web_app/telegram_web_app.dart' hide HapticFeedback;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class TelegramBridge {
  /// AUTHENTICATION PERIMETER
  static String get initData {
    try {
      // Logic: Only access raw if it exists, otherwise return empty
      return TelegramWebApp.instance.initData.raw;
    } catch (_) {
      return "";
    }
  }

  /// IDENTITY RESCUE LOGIC
  /// Hardened for Phase 1.3.1 - Resolves the Unconditional Access error
  static String get userId {
    try {
      // 1. Capture the instance in a local variable to help the compiler with type promotion
      final initDataUnsafe = TelegramWebApp.instance.initDataUnsafe;
      
      // 2. Explicit null check before accessing .user
      if (initDataUnsafe != null && initDataUnsafe.user != null) {
        final uid = initDataUnsafe.user!.id;
        if (uid != 0) {
          return uid.toString();
        }
      }
    } catch (e) {
      debugPrint("🏛️ [Bridge] Identity_Extraction_Failure: $e");
    }
    return "LOCAL_HOST";
  }

  /// HAPTIC FEEDBACK BRIDGE
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