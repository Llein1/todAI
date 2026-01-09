// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todai/main.dart';

void main() {
  testWidgets('todAI app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TodAIApp());

    // Verify that todAI title exists
    expect(find.text('todAI'), findsWidgets);
    
    // Verify icon exists
    expect(find.byIcon(Icons.smart_toy_outlined), findsOneWidget);
    
    // Verify Get Started button exists
    expect(find.text('Get Started'), findsOneWidget);
  });
}
