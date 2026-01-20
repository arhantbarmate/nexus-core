import 'package:flutter/material.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'screens/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isTelegramReady = false;
  bool isDevMode = false;
  String bootError = "";

  // 1. Capture Dev Intent First (Short-Circuit Logic)
  const String nexusDev = String.fromEnvironment('NEXUS_DEV', defaultValue: 'false');
  isDevMode = nexusDev.toLowerCase() == 'true';

  // 2. Identity Initialization Gate
  if (!isDevMode) {
    if (TelegramWebApp.instance.isSupported) {
      try {
        TelegramWebApp.instance.ready();
        
        // 🛡️ Double-Guard Null Safety:
        // 1. Capture the nullable object
        final initData = TelegramWebApp.instance.initDataUnsafe;
        
        // 2. Check if the object and the nested user exist
        if (initData != null && initData.user != null) {
          final userId = initData.user!.id; // ! tells Dart we are sure it's not null now
          
          if (userId != 0) {
            isTelegramReady = true;
            TelegramWebApp.instance.expand();
          }
        }
      } catch (e) {
        print("Nexus Sentry: Telegram Handshake failed -> $e");
        bootError = e.toString();
      }
    }
  } else {
    print("🛡️ Nexus: Dev Mode Active - Bypassing Identity Handshake.");
  }

  runApp(NexusApp(
    telegramReady: isTelegramReady,
    devMode: isDevMode,
    bootError: bootError,
  ));
}

class NexusApp extends StatelessWidget {
  final bool telegramReady;
  final bool devMode;
  final String bootError;

  const NexusApp({
    super.key, 
    required this.telegramReady, 
    required this.devMode,
    required this.bootError,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus Protocol',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF111111),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FF9D), // Cyber Green
          surface: Color(0xFF222222),
        ),
      ),
      // Improvement 2: Passing diagnostics downstream
      home: NexusDashboard(
        telegramReady: telegramReady,
        devMode: devMode,
        bootError: bootError,
      ),
    );
  }
}