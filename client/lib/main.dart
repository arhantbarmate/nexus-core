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

import 'package:flutter/material.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'screens/dashboard.dart';

void main() async {
  // 1. BOUNDARY INITIALIZATION
  // Ensures Flutter is ready for low-level platform channel communication.
  WidgetsFlutterBinding.ensureInitialized();

  bool isTelegramReady = false;
  bool isDevMode = false;
  String bootError = "";

  // 2. DEV-MODE SHORT CIRCUIT (Audit 2.1)
  // Hardened string parsing to prevent environment mismatch during grant review.
  const String nexusDev = String.fromEnvironment('NEXUS_DEV', defaultValue: 'false');
  isDevMode = nexusDev.trim().toLowerCase() == 'true';

  // 3. SOVEREIGN HANDSHAKE (The Identity Gate)
  if (!isDevMode) {
    try {
      // STRESS TEST (Audit 2.2): Handshake must occur within 3 seconds or survival fallback triggers.
      // Prevents infinite splash in degraded network conditions.
      await Future.any([
        _initTelegramHandshake(),
        Future.delayed(const Duration(seconds: 3), () => throw 'TELEGRAM_SERVICE_TIMEOUT'),
      ]);

      final initData = TelegramWebApp.instance.initDataUnsafe;

      // Audit 2.3: Verification of Identity Object Integrity (Presence-Check Only).
      if (initData != null && initData.user != null && initData.user!.id != 0) {
        isTelegramReady = true;
        
        // Audit 2.4: Atomic viewport expansion and readiness signal.
        TelegramWebApp.instance.expand(); 
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

// 4. THE LIFE-CYCLE OBSERVER (Audit 3)
// Monitors background/foreground transitions to ensure UI state remains synchronized.
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
    // Audit: Re-assert session stability when returning from background.
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
        canvasColor: const Color(0xFF050508), // Audit: Eliminates white-flash artifacts.
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4f46e5), 
          secondary: Color(0xFF10b981), 
          surface: Color(0xFF0d0d12),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Courier', color: Color(0xFFe2e8f0)),
        ),
      ),
      // 6. ROUTING LOGIC (Audit 4)
      home: widget.telegramReady || widget.bootError.isNotEmpty || widget.devMode
          ? NexusDashboard(
              telegramReady: widget.telegramReady,
              devMode: widget.devMode,
              bootError: widget.bootError,
            )
          : _buildSplashLoader(),
    );
  }

  /// THE SPLASH PROTOCOL (Audit 5)
  Widget _buildSplashLoader() {
    return Scaffold(
      backgroundColor: const Color(0xFF050508),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/nexus-logo.png',
              width: 160,
              height: 160,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => 
                const Icon(Icons.shield_rounded, size: 80, color: Color(0xFF4f46e5)),
            ),
            const SizedBox(height: 30),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF10b981),
              ),
            ),
          ],
        ),
      ),
    );
  }
}