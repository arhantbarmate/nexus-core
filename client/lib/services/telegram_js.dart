// Copyright 2026 Nexus Protocol Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

@JS()
library telegram_js;

import 'package:js/js.dart';

// --- 🛰️ THE TELEGRAM SDK MAPPING (Dart-JS Interop) ---
// NOTE: All bindings assume Telegram WebApp SDK is injected by the host. (Audit 3)
// Callers MUST guard access via runtime support checks (e.g., TelegramBridge.isSupported).

@JS('Telegram.WebApp')
class TelegramWebApp {
  external static String get initData;
  external static WebAppInitData get initDataUnsafe;
  external static String get colorScheme;
  external static String get themeParams;
  external static bool get isExpanded;
  external static double get viewportHeight;
  external static double get viewportStableHeight;
  external static MainButton get MainButton;
  external static HapticFeedback get HapticFeedback;

  external static void ready();
  external static void expand();
  external static void close();
}

@JS()
@anonymous
class WebAppInitData {
  external WebAppUser? get user;
  external String? get auth_date;
  external String? get hash;
  external String? get query_id;
}

@JS()
@anonymous
class WebAppUser {
  /// 🛡️ ID PERSISTENCE & NUMERIC SAFETY (Audit 2.3): 
  /// Telegram User IDs often exceed the 32-bit integer range.
  /// We map to 'int' to ensure Dart/Web treats this as a JS Number/BigInt,
  /// preventing the precision loss or truncation common with 'double' or 'num'.
  external int get id;
  external String? get first_name;
  external String? get last_name;
  external String? get username;
  external String? get language_code;
  external bool? get is_premium;
}

@JS()
@anonymous
class MainButton {
  external String get text;
  external String get color;
  external String get textColor;
  external bool get isVisible;
  external bool get isActive;
  external bool get isProgressVisible;

  external void setText(String text);
  external void onClick(void Function() callback);
  external void show();
  external void hide();
  external void enable();
  external void disable();
}

@JS()
@anonymous
class HapticFeedback {
  /// ⚡ HAPTIC HANDSHAKE (Audit 2.5):
  /// Signatures strictly follow the Telegram Bot API v7.x JS specification.
  external void notificationOccurred(String type);
  external void impactOccurred(String style);
  external void selectionChanged();
}