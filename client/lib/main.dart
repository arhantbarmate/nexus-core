// Copyright 2026 Nexus Protocol Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
// FIX 1: Removed direct telegram_web_app import.
// FIX 2: Imported the hardened bridge gateway for cross-platform safety.
import 'services/tg_bridge.dart';
import 'screens/dashboard.dart';

void main() async {
  // 1. BOUNDARY INITIALIZATION
  WidgetsFlutterBinding.ensureInitialized();

  bool isTelegramReady = false;
  bool isDevMode = false;
  String bootError = "";

  // 2. DEV-MODE SHORT CIRCUIT (Audit 2.1)
  const String nexusDev = String.fromEnvironment('NEXUS_DEV', defaultValue: 'false');
  isDevMode = nexusDev.trim().toLowerCase() == 'true';

  // 3. SOVEREIGN HANDSHAKE (The Identity Gate)
  // Replaced direct handshake with bridge-based probing.
  if (!isDevMode) {
    try {
      // STRESS TEST (Audit 2.2): Timeout ensures survival fallback triggers if JS doesn't respond.
      await Future.any([
        _probeSovereignIdentity(),
        Future.delayed(const Duration(seconds: 3), () => throw 'IDENTITY_SERVICE_TIMEOUT'),
      ]);

      // Using the bridge to check for identity presence (Phase 1.3.1 compliant)
      final uid = TelegramBridge.userId;

      // Audit 2.3: Verification of Identity Object Integrity via fallback check.
      if (uid != "999") {
        isTelegramReady = true;
        // The ready() and expand() signals are now handled internally within the web bridge implementation.
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

/// 4. SOVEREIGN PROBE (Audit 2.5)
/// Triggers haptic or ready signals via the bridge to ensure the JS environment is hot.
Future<void> _probeSovereignIdentity() async {
  // Simply calling triggerHaptic or referencing initData ensures the 
  // underlying JS context (if on web) is initialized.
  TelegramBridge.triggerHaptic();
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

// 5. THE LIFE-CYCLE OBSERVER (Audit 3)
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
    if (state == AppLifecycleState.resumed && widget.telegramReady) {
      debugPrint("🏛️ Nexus: Resuming Sovereign Session...");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus Protocol',
      debugShowCheckedModeBanner: false,
      // 6. HARDENED THEME (Cyber-Sentry Aesthetics)
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF050508),
        canvasColor: const Color(0xFF050508),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4f46e5), 
          secondary: Color(0xFF10b981), 
          surface: Color(0xFF0d0d12),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Courier', color: Color(0xFFe2e8f0)),
        ),
      ),
      // 7. ROUTING LOGIC (Audit 4)
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