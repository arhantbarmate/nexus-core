// 🛡️ NATIVE STUB (Phase 1.4.0)
// This file is compiled for Android/iOS builds to prevent "dart:js" crashes.
// It mimics the "tg_bridge_web.dart" API structure but does nothing.
//
// NOTE: This file is intentionally empty of logic.
// The actual fallback logic (e.g., returning "999") happens in the wrapper 'tg_bridge.dart'.

class TelegramWebApp {
  // Return empty string so the wrapper knows we are not in Telegram
  static String get initData => "";
  
  // Return null so the wrapper knows there is no user
  static dynamic get initDataUnsafe => null;
  
  static MainButton get mainButton => MainButton();
  static HapticFeedback get hapticFeedback => HapticFeedback();

  static void ready() {}
  static void expand() {}
  static void close() {}
}

class MainButton {
  bool get isVisible => false;
  bool get isActive => false;
  
  void show() {}
  void hide() {}
  void enable() {}
  void disable() {}
  void setText(String text) {}
  void onClick(void Function() callback) {}
}

class HapticFeedback {
  void impactOccurred(String style) {}
  void notificationOccurred(String type) {}
  void selectionChanged() {}
}