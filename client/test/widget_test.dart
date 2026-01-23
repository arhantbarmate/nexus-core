import 'package:flutter_test/flutter_test.dart';
// Note: Ensure 'nexus_app' matches the name field in your pubspec.yaml
import 'package:nexus_app/main.dart';
import 'package:nexus_app/screens/dashboard.dart';

void main() {
  testWidgets('Nexus Protocol: Sovereign Body Smoke Test', (WidgetTester tester) async {
    // 1. BOOTSTRAP INJECTION
    // We simulate a local operator environment (devMode: true) without Telegram presence.
    await tester.pumpWidget(const NexusApp(
      telegramReady: false, 
      devMode: true,
      bootError: "", 
    ));

    // 2. COMPONENT ASSERTIONS
    // Verify the root boundary exists.
    expect(find.byType(NexusApp), findsOneWidget);

    // Verify the routing logic correctly navigated to the Dashboard.
    expect(find.byType(NexusDashboard), findsOneWidget);

    // 3. SOVEREIGN UI ELEMENTS
    // Verify core UI anchors are rendered, ensuring the theme and layout loaded.
    expect(find.text('NEXUS_PROTOCOL'), findsOneWidget);
    expect(find.text('EXECUTE_PROTOCOL_SPLIT'), findsOneWidget);
  });
}