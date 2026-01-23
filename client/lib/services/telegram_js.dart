@JS()
library telegram_js;

import 'package:js/js.dart';

// --- 🛰️ THE TELEGRAM SDK MAPPING (Dart-JS Interop) ---

@JS('Telegram.WebApp')
class TelegramWebApp {
  external static String get initData;
  external static WebAppInitData get initDataUnsafe;
  
  // Audit Fix: Mapping to camelCase to satisfy Dart linter (non_constant_identifier_names)
  @JS('MainButton')
  external static MainButton get mainButton;

  @JS('HapticFeedback')
  external static HapticFeedback get hapticFeedback;

  external static void ready();
  external static void expand();
}

@JS()
@anonymous
class WebAppInitData {
  external WebAppUser? get user;
  @JS('auth_date') // Maps JS snake_case to Dart camelCase
  external int? get authDate;
  external String? get hash;
}

@JS()
@anonymous
class WebAppUser {
  external int get id;
  @JS('first_name')
  external String? get firstName;
  @JS('username')
  external String? get username;
}

@JS()
@anonymous
class MainButton {
  external bool get isVisible;
  external void show();
  external void hide();
}

@JS()
@anonymous
class HapticFeedback {
  /// NOTE: Staged for Phase 2.0. 
  /// Currently limited by Telegram WebApp version 6.0 compatibility in some environments.
  external void impactOccurred(String style); 
}