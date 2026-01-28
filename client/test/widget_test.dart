// 🛡️ SOVEREIGN SMOKE TEST (Phase 1.4.0)
// Scope: Verifies the App boots and renders the Dashboard without crashing.
// Logic assertions belong in unit tests. This is purely for rendering safety.

import 'package:flutter_test/flutter_test.dart';

// GUARDRAIL 1: Ensure this matches the 'name:' in your pubspec.yaml
// If your pubspec name is 'client', change this to 'package:client/main.dart'
import 'package:nexus_app/main.dart';
import 'package:nexus_app/screens/dashboard.dart';

void main() {
  testWidgets('Nexus Protocol: Sovereign Body Smoke Test', (WidgetTester tester) async {
    // 1. BOOTSTRAP INJECTION (v1.4.0)
    // The new architecture self-bootstraps. We do not inject state manually.
    // This simulates a "Cold Boot" of the app.
    await tester.pumpWidget(const NexusApp());

    // 2. WAIT FOR SOVEREIGN HANDSHAKE
    // The app starts in a Splash Screen state while running '_bootstrapSovereignNode'.
    // Since we are in a test environment, the 'tg_bridge_stub' is used.
    // The logic will hit the 3-second timeout or fail immediately, eventually loading the Dashboard.
    
    // pumpAndSettle waits for all animations (Splash Loader) to finish rendering
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // 3. COMPONENT ASSERTIONS (Guardrail 2: Existence Only)
    // Verify we successfully navigated from Splash -> Dashboard
    expect(find.byType(NexusDashboard), findsOneWidget);

    // Verify the static UI frame is intact.
    expect(find.text('NEXUS_PROTOCOL'), findsOneWidget);
    
    // Verify critical interaction points exist
    expect(find.text('EXECUTE_PROTOCOL_SPLIT'), findsOneWidget);
  });
}