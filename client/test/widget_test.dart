import 'package:flutter_test/flutter_test.dart';
// Flutter 'maps' your lib folder to this package name automatically
import 'package:nexus_app/main.dart';
import 'package:nexus_app/screens/dashboard.dart';

void main() {
  testWidgets('Nexus Protocol: Sovereign Body Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const NexusApp(
      telegramReady: false, 
      devMode: true,
      bootError: "", 
    ));

    expect(find.byType(NexusApp), findsOneWidget);
    expect(find.byType(NexusDashboard), findsOneWidget);
    expect(find.textContaining('v1.3.1'), findsOneWidget);
  });
}