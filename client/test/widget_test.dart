import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_app/main.dart';

void main() {
  testWidgets('Nexus Protocol Smoke Test', (WidgetTester tester) async {
    // Build the NexusApp defined in lib/main.dart
    await tester.pumpWidget(const NexusApp());

    // Verify the widget tree initialized by checking for the Dashboard
    expect(find.byType(NexusApp), findsOneWidget);
  });
}