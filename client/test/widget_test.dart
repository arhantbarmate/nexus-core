import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_app/main.dart';

void main() {
  testWidgets('Nexus Protocol Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the environment initialized.
    // Replace 'Nexus' with a string actually present in your main.dart UI.
    expect(find.byType(MyApp), findsOneWidget);
  });
}