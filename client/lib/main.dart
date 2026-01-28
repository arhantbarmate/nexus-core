// Copyright 2026 Coreframe Systems (Nexus Protocol)
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
import 'dart:async';
import 'services/tg_bridge.dart';
import 'screens/dashboard.dart';

// 1. NON-BLOCKING ENTRY (Stress Test Optimization)
// We avoid 'await' in main() to ensure the Splash Screen paints immediately.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NexusApp());
}

class NexusApp extends StatefulWidget {
  const NexusApp({super.key});

  @override
  State<NexusApp> createState() => _NexusAppState();
}

// 2. REACTIVE BOOTSTRAPPER (Phase 1.4.0)
// Manages the transition from "Cold Boot" to "Sovereign Session".
class _NexusAppState extends State<NexusApp> with WidgetsBindingObserver {
  bool _isTelegramReady = false;
  bool _isDevMode = false;
  String _bootError = "";
  bool _isLoading = true; // Tracks the handshake status

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrapSovereignNode();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 3. THE HANDSHAKE PROTOCOL (Async execution)
  Future<void> _bootstrapSovereignNode() async {
    // NOTE: Frontend identity is advisory only in Phase 1.x.
    // Backend remains authoritative for all execution and policy decisions.
    // The client strictly acts as a "View" for the Sovereign Brain.

    // A. Env Extraction
    const String nexusDev = String.fromEnvironment('NEXUS_DEV', defaultValue: 'false');
    final bool devMode = nexusDev.trim().toLowerCase() == 'true';

    bool telegramReady = false;
    String error = "";

    if (!devMode) {
      try {
        // B. Identity Probe (With 3s Timeout Fail-Safe)
        // Ensures the app doesn't hang if the JS Bridge is unresponsive.
        await Future.any([
          _probeIdentityBridge(),
          Future.delayed(const Duration(seconds: 3), () => throw 'IDENTITY_TIMEOUT'),
        ]);

        final uid = TelegramBridge.userId;
        
        // C. Sovereign Validation (Audit 2.4 - Hardened)
      // Logic: Ensure identity is anchored. User 999 is blocked in Production.
      if (uid.isNotEmpty && uid != "999") {
        telegramReady = true;
      } else {
        error = "SOVEREIGN_ID_MISMATCH";
        debugPrint("🛡️ Access Denied: Unverified or Reserved UID detected.");
      }
    } catch (e) {
      debugPrint("🛡️ Handshake Failed: $e");
      error = e.toString().replaceAll("Exception:", "").trim();
    }
  } else {
    debugPrint("🛡️ Dev Mode Active: Bypassing Handshake");
    telegramReady = true; // Ensure UI proceeds in dev mode
  }

    // D. Safe State Update
    if (mounted) {
      setState(() {
        _isDevMode = devMode;
        _isTelegramReady = telegramReady;
        _bootError = error;
        _isLoading = false; // Release the Splash Screen
      });
    }
  }

  Future<void> _probeIdentityBridge() async {
    // Triggers haptics to ensure JS Bridge is alive and listening
    TelegramBridge.triggerHaptic();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isTelegramReady) {
      debugPrint("🏛️ Nexus: Resuming Sovereign Session...");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus Protocol',
      debugShowCheckedModeBanner: false,
      
      // 4. HARDENED THEME (Cyber-Sentry Aesthetics)
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF050508),
        canvasColor: const Color(0xFF050508), // Fixes Drawer/Sheet colors
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4f46e5), // Indigo
          secondary: Color(0xFF10b981), // Emerald
          surface: Color(0xFF0d0d12),
          error: Color(0xFFef4444),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Courier', color: Color(0xFFe2e8f0)),
        ),
      ),

      // 5. ROUTING SWITCHBOARD
      // If Loading: Show Splash
      // If Ready/Error/Dev: Show Dashboard (Dashboard handles error display)
      home: _isLoading
          ? _buildSplashLoader()
          : NexusDashboard(
              telegramReady: _isTelegramReady,
              devMode: _isDevMode,
              bootError: _bootError,
            ),
    );
  }

  /// THE SPLASH PROTOCOL (Audit 5)
  /// Optimized for minimal paint cost during startup (Frame 1).
  Widget _buildSplashLoader() {
    return Scaffold(
      backgroundColor: const Color(0xFF050508),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ErrorBuilder ensures no crash if asset is missing during dev
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