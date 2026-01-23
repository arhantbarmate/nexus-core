import 'package:telegram_web_app/telegram_web_app.dart';

class TelegramBridge {
  static String get initData {
    try {
      // FIX: In v0.3.3, initData returns a TelegramInitData object.
      // We call .toString() to get the raw query string for the Brain.
      final data = TelegramWebApp.instance.initData;
      
      final String dataStr = data.toString();
      
      if (dataStr.isNotEmpty && dataStr != "null" && dataStr != "{}") {
        return dataStr;
      }
    } catch (_) {}
    return "valid_mock_signature";
  }

  static String get userId {
    try {
      final user = TelegramWebApp.instance.initDataUnsafe?.user;
      if (user != null) {
        return user.id.toString();
      }
    } catch (_) {}
    return "999";
  }

  static void triggerHaptic() {
    try {
      TelegramWebApp.instance.hapticFeedback.impactOccurred(
        HapticFeedbackImpact.medium,
      );
    } catch (_) {}
  }
}