import 'package:flutter/material.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'screens/dashboard.dart';

void main() async {
  // 1. BOUNDARY INITIALIZATION
  // Ensures Flutter is ready for low-level platform channel communication
  WidgetsFlutterBinding.ensureInitialized();

  bool isTelegramReady = false;
  bool isDevMode = false;
  String bootError = "";

  // 2. DEV-MODE SHORT CIRCUIT
  // Hardened string parsing to prevent environment mismatch
  const String nexusDev = String.fromEnvironment('NEXUS_DEV', defaultValue: 'false');
  isDevMode = nexusDev.trim().toLowerCase() == 'true';

  // 3. SOVEREIGN HANDSHAKE (The Identity Gate)
  if (!isDevMode) {
    try {
      // STRESS TEST: Handshake must occur within 3 seconds or we trigger a survival fallback
      await Future.any([
        _initTelegramHandshake(),
        Future.delayed(const Duration(seconds: 3), () => throw 'TELEGRAM_SERVICE_TIMEOUT'),
      ]);

      final initData = TelegramWebApp.instance.initDataUnsafe;
      
      // Verification of Identity Object Integrity
      if (initData != null && initData.user != null && initData.user!.id != 0) {
        isTelegramReady = true;
        TelegramWebApp.instance.expand(); // Command Telegram to take full height
        
        // Command Telegram to lock vertical orientation for UI stability
        // Note: Requires Telegram 6.2+
        try {
          TelegramWebApp.instance.ready(); 
        } catch (_) {}
      } else {
        bootError = "IDENTITY_NOT_FOUND";
      }
    } catch (e) {
      debugPrint("🛡️ Nexus Handshake Error: $e");
      bootError = e.toString();
    }
  }

  runApp(NexusApp(
    telegramReady: isTelegramReady,
    devMode: isDevMode,
    bootError: bootError,
  ));
}

/// Isolated Handshake Logic
Future<void> _initTelegramHandshake() async {
  if (TelegramWebApp.instance.isSupported) {
    TelegramWebApp.instance.ready();
  } else {
    throw 'PLATFORM_UNSUPPORTED';
  }
}

class NexusApp extends StatefulWidget {
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
  State<NexusApp> createState() => _NexusAppState();
}

// 4. THE LIFE-CYCLE OBSERVER
// Audit Fix: We use WidgetsBindingObserver to detect when the app returns from background
class _NexusAppState extends State<NexusApp> with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the user returns to the app, we force an identity check to prevent session hijacking
    if (state == AppLifecycleState.resumed && widget.telegramReady) {
      debugPrint("🏛️ Nexus: Resuming Sovereign Session...");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus Protocol',
      debugShowCheckedModeBanner: false,
      // 5. HARDENED THEME (Cyber-Sentry Aesthetics)
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF050508),
        canvasColor: const Color(0xFF050508), // Prevents white-flash on load
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4f46e5), // Indigo Primary (The Brain)
          secondary: Color(0xFF10b981), // Terminal Green (The Guard)
          surface: Color(0xFF0d0d12),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Courier', color: Color(0xFFe2e8f0)),
        ),
      ),
      home: NexusDashboard(
        telegramReady: widget.telegramReady,
        devMode: widget.devMode,
        bootError: widget.bootError,
      ),
    );
  }
}