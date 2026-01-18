import 'package:telegram_web_app/telegram_web_app.dart' hide HapticFeedback;
import 'package:flutter/services.dart';

/// WEB: Implementation for the Telegram Mini App environment.
/// This version is hardened for Phase 1.3 multichain header sync.
class TelegramBridge {
  
  /// Returns true only if the Telegram JS SDK is present AND initData is available.
  static bool get isSupported {
    try {
      final instance = TelegramWebApp.instance;
      // Hardening: Verify the instance exists and the raw data isn't empty
      return instance.isSupported && instance.initData.raw.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Informs the Telegram parent that the App is ready for interaction.
  static void ready() {
    try {
      TelegramWebApp.instance.ready();
    } catch (_) {}
  }

  /// Requests the Telegram parent to expand the Mini App to full height.
  static void expand() {
    try {
      TelegramWebApp.instance.expand();
    } catch (_) {}
  }

  /// Extracts the RAW initData string.
  /// This string is sent in the 'X-Nexus-TMA' header for HMAC-SHA256 verification.
  static String get initData {
    try {
      final String raw = TelegramWebApp.instance.initData.raw;
      // If we are in a browser but not in Telegram, return empty so main.dart uses the mock.
      return raw;
    } catch (_) {
      return "";
    }
  }

  /// Triggers a haptic response via the Flutter engine.
  static void triggerHaptic() {
    try {
      // Use lightImpact to signal a successful Nexus Split execution.
      HapticFeedback.lightImpact();
    } catch (_) {}
  }
}