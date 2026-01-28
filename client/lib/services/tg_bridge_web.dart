@JS()
library telegram_web;

import 'package:js/js.dart';

// ==========================================================
// 🛡️ NEXUS PROTOCOL: TELEGRAM JS BINDINGS (v1.4.0)
// ==========================================================
// STATUS: RAW BINDINGS (Dependency-Free)
// NOTE: This file is purely a definition layer. 
// Logic and safety checks exist in 'tg_bridge.dart'.
// ==========================================================

@JS('Telegram.WebApp')
class TelegramWebApp {
  /// The raw signature string used for backend HMAC validation.
  external static String get initData;

  /// Unsafe data object for UI extraction.
  external static WebAppInitData get initDataUnsafe;
  
  // UI Components
  @JS('MainButton')
  external static MainButton get mainButton;

  @JS('HapticFeedback')
  external static HapticFeedback get hapticFeedback;

  // Lifecycle
  external static void ready();
  external static void expand();
  external static void close();
}

// ----------------------------------------------------------
// DATA STRUCTURES (Zero-Overhead Anonymous Classes)
// ----------------------------------------------------------

@JS()
@anonymous
class WebAppInitData {
  external WebAppUser? get user;
  
  @JS('auth_date')
  external int? get authDate; 
  
  external String? get hash;
  
  @JS('query_id')
  external String? get queryId;
}

@JS()
@anonymous
class WebAppUser {
  external int get id;
  
  @JS('first_name')
  external String? get firstName;
  
  @JS('last_name')
  external String? get lastName;
  
  @JS('username')
  external String? get username;
  
  @JS('language_code')
  external String? get languageCode;
  
  @JS('is_premium')
  external bool? get isPremium;
}

@JS()
@anonymous
class MainButton {
  external bool get isVisible;
  external bool get isActive;
  
  external void show();
  external void hide();
  external void enable();
  external void disable();
  
  @JS('setText')
  external void setText(String text);
  
  @JS('onClick')
  external void onClick(void Function() callback);
}

@JS()
@anonymous
class HapticFeedback {
  external void impactOccurred(String style);
  external void notificationOccurred(String type);
  external void selectionChanged();
}