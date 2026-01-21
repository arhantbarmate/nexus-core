// STUB: CI/Desktop safety net - Hardened for Phase 1.3.1
class TelegramBridge {
  static bool get isSupported => false;
  static void ready() {}
  static void expand() {}
  static String get initData => "";
  // Added for system symmetry to prevent Desktop crashes
  static String get userId => "LOCAL_HOST"; 
  static void triggerHaptic() {} 
}