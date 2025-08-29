// FoodLoop PH Widget Tests
//
// This file contains comprehensive widget tests for the FoodLoop PH food sharing app.
// Tests cover the landing page functionality, UI elements, and user interactions.
//
// Test Coverage:
// - Landing page displays all required text and branding elements
// - UI components render correctly (icons, buttons, containers)
// - Animations and transitions work properly
// - Button interactions are functional
// - App layout and styling elements are present
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foodloopph/screens/landing_page.dart';

void main() {
  group('FoodLoop PH App Tests', () {
    testWidgets('Landing page displays correctly', (WidgetTester tester) async {
      // Build just the landing page directly for isolated testing
      await tester.pumpWidget(
        MaterialApp(
          home: LandingPage(),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Verify that the landing page elements are displayed
      expect(find.text('FoodLoop PH'), findsOneWidget);
      expect(find.text('Share Food. Fight Waste.\nFeed Communities.'),
          findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);
      expect(find.byIcon(Icons.restaurant), findsOneWidget);
      expect(find.text('Post surplus food and\nhelp others nearby'),
          findsOneWidget);
    });

    testWidgets('Landing page has correct styling elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LandingPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify restaurant icon is present
      expect(find.byIcon(Icons.restaurant), findsOneWidget);

      // Verify get started button exists
      expect(find.text('Get started'), findsOneWidget);

      // Find the ElevatedButton and verify it exists
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Landing page app title and tagline are visible',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LandingPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify app branding
      expect(find.text('FoodLoop PH'), findsOneWidget);
      expect(find.text('Share Food. Fight Waste.\nFeed Communities.'),
          findsOneWidget);
      expect(find.text('Post surplus food and\nhelp others nearby'),
          findsOneWidget);
    });

    testWidgets('Landing page button is tappable', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LandingPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find the get started button
      final getStartedButton = find.text('Get started');
      expect(getStartedButton, findsOneWidget);

      // Verify the button can be tapped (this will trigger navigation,
      // but since we're not providing the full app context,
      // we just verify the button responds to taps)
      await tester.tap(getStartedButton);
      await tester.pump();

      // Test passes if no exceptions are thrown during tap
    });

    testWidgets('Landing page contains required UI elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LandingPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Check for key UI components
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(FadeTransition), findsAtLeastNWidgets(1));
      expect(find.byType(SlideTransition), findsAtLeastNWidgets(1));
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Verify the main container elements
      expect(find.byType(Container), findsAtLeastNWidgets(1));
      expect(find.byType(Column), findsAtLeastNWidgets(1));
    });
  });
}
