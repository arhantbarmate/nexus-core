import 'package:telegram_web_app/telegram_web_app.dart';

/// 🛰️ TELEGRAM BRIDGE (Web-Only)
/// This service handles the handshake between the Flutter 'Body' and 
/// the Telegram Mini App (TMA) environment.
class TelegramBridge {
  
  /// 🛡️ IDENTITY PROTOCOL: initData
  /// Extracts the URL-encoded initialization string.
  /// Used by the Brain's 'multichain_guard' for HMAC-SHA256 verification.
  static String get initData {
    try {
      // Logic: Version 0.1.6 returns a TelegramInitData object; 
      // toString() ensures it is formatted for the Python Regex gate.
      return TelegramWebApp.instance.initData.toString();
    } catch (_) {
      // Fallback: Allows Dashboard to function in standard browser/dev mode.
      return "valid_mock_signature"; 
    }
  }

  /// 🛡️ IDENTITY PROTOCOL: userId
  /// Extracts the unique Telegram User ID from the unsafe data object.
  static String get userId {
    try {
      final initDataUnsafe = TelegramWebApp.instance.initDataUnsafe;
      final user = initDataUnsafe?.user;
      
      if (user != null) {
        return user.id.toString();
      }
    } catch (_) {
      // Exception suppressed to allow fallback below
    }
    
    // Fallback: Maps to Brain's 'DEV_NAMESPACE_ID' for local simulation.
    return "999"; 
  }

  /// ⚡ OPERATIONAL FEEDBACK: triggerHaptic
  /// Provides tactile confirmation when the Split Protocol is executed.
  static void triggerHaptic() {
    try {
      // AUDIT FIX: Using HapticFeedbackImpact.medium (Enum) instead of raw String.
      // This resolves the compilation error in telegram_web_app v0.1.6.
      TelegramWebApp.instance.hapticFeedback.impactOccurred(HapticFeedbackImpact.medium);
    } catch (e) {
      // Silent fail: Prevents crash when testing on Desktop Chrome where 
      // haptic hardware is unavailable.
    }
  }
}