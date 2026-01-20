import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'tg_bridge.dart';
import 'screens/dashboard.dart';

// --- 1. ENVIRONMENT AUTHORITY ---
// Use this to toggle between local mock logic and production Sentry logic
// Command: flutter run --dart-define=NEXUS_DEV=true
const bool isDevMode = bool.fromEnvironment('NEXUS_DEV', defaultValue: false);

void main() {
  bool isTelegramReady = false;

  // --- 2. SOVEREIGN BOOT SEQUENCE ---
  if (kIsWeb) {
    try {
      if (TelegramBridge.isSupported) {
        TelegramBridge.ready();
        TelegramBridge.expand();
        isTelegramReady = true;
      }
    } catch (e) {
      if (isDevMode) {
        debugPrint("🛡️ Nexus: Sovereign Mock Mode active (Dev Only)");
      }
    }
  }
  
  runApp(NexusApp(telegramReady: isTelegramReady));
}

class NexusApp extends StatelessWidget {
  final bool telegramReady;

  const NexusApp({super.key, required this.telegramReady});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nexus Protocol',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00D1FF),
        scaffoldBackgroundColor: const Color(0xFF0A0E14),
        fontFamily: 'monospace',
      ),
      // --- 3. IDENTITY-AWARE ENTRY ---
      // We pass the flag to the dashboard so it can show appropriate states
      home: NexusDashboard(
        telegramReady: telegramReady,
        devMode: isDevMode,
      ),
    );
  }
}