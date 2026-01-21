import 'package:flutter_test/flutter_test.dart';
// 1. RELATIVE IMPORTS (Bypasses package name errors)
import '../lib/main.dart';
import '../lib/screens/dashboard.dart';

void main() {
  testWidgets('Nexus Protocol: Sovereign Body Smoke Test', (WidgetTester tester) async {
    // 1. Setup the test environment
    // We simulate a 'Dev Mode' environment where Telegram is not yet ready.
    await tester.pumpWidget(const NexusApp(
      telegramReady: false, 
      devMode: true,
      bootError: "", 
    ));

    // 2. Verify the App Root exists and initialized
    expect(find.byType(NexusApp), findsOneWidget);

    // 3. Verify the Dashboard is correctly injected as the Home Surface
    expect(find.byType(NexusDashboard), findsOneWidget);

    // 4. Verify Brand Integrity
    expect(find.textContaining('v1.3.1'), findsOneWidget);
  });
}