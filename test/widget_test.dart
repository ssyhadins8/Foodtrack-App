// This is a basic Flutter widget test for FoodTrack.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodtrack/pages/onboarding.dart';

void main() {
  testWidgets('OnboardingPage renders premium UI successfully', (WidgetTester tester) async {
    // Build our onboarding page widget inside a MaterialApp.
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingPage(),
      ),
    );

    // Verify that our onboarding screen renders the essential UI texts and buttons
    expect(find.text('Campus Canteen App'), findsOneWidget);
    expect(find.text('Pesan makanan dari kantin kampus\nfavorit kamu dengan mudah & cepat!'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    // Verify presence of chips
    expect(find.text('⚡'), findsOneWidget);
    expect(find.text('Cepat'), findsOneWidget);
    expect(find.text('✅'), findsOneWidget);
    expect(find.text('Terpercaya'), findsOneWidget);
  });
}


