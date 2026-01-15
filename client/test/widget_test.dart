import 'package:flutter_test/flutter_test.dart';
// Matches 'name: nexus_app' in your pubspec.yaml
import 'package:nexus_app/main.dart'; 

void main() {
  testWidgets('Nexus Sovereign Node Smoke Test', (WidgetTester tester) async {
    // 1. Build our app and trigger a frame.
    // This confirms the 'Brain' to 'Body' connection logic doesn't crash on start.
    await tester.pumpWidget(const MyApp());

    // 2. Verify that the app launches successfully.
    // By finding the MyApp widget, we prove the Flutter engine initialized the Nexus UI.
    expect(find.byType(MyApp), findsOneWidget);
  });
}