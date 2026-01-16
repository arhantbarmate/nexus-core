import 'package:telegram_web_app/telegram_web_app.dart' hide HapticFeedback;
import 'package:flutter/services.dart';

// WEB: Implementation using Telegram package while hiding conflicting symbols
class TelegramBridge {
  static bool get isSupported {
    try {
      return TelegramWebApp.instance.isSupported;
    } catch (_) {
      return false;
    }
  }

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

  static String get initData {
    try {
      return TelegramWebApp.instance.initData.raw;
    } catch (_) {
      return "";
    }
  }

  static void triggerHaptic() {
    try {
      // Accessing Flutter's HapticFeedback explicitly
      HapticFeedback.lightImpact();
    } catch (_) {}
  }
}