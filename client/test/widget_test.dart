import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Nexus Environment Sanity Check', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Nexus Protocol Active'),
        ),
      ),
    );

    expect(find.text('Nexus Protocol Active'), findsOneWidget);
  });
}