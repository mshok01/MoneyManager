// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:money_manager/main.dart';

void main() {
  testWidgets('App launches with intro screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MoneyManagerApp());
    await tester.pumpAndSettle();

    // Verify that the intro screen is displayed with English strings
    expect(find.text('Welcome to Money Manager'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    // Verify that navigation arrows are not visible on first page (left arrow)
    // but right arrow should be visible
    expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
  });

  testWidgets('Can navigate to second page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MoneyManagerApp());
    await tester.pumpAndSettle();

    // Verify we start on first page
    expect(find.text('Welcome to Money Manager'), findsOneWidget);

    // Navigate to second page
    await tester.tap(find.byIcon(Icons.arrow_forward_ios));
    await tester.pumpAndSettle();

    // Verify we're on second page
    expect(find.text('Track Income & Expenses'), findsOneWidget);

    // Verify left arrow is now visible
    expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
  });

  testWidgets('Skip button visibility changes correctly', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MoneyManagerApp());
    await tester.pumpAndSettle();

    // Verify Skip button is visible on first page
    expect(find.text('Skip'), findsOneWidget);

    // Navigate to second page
    await tester.tap(find.byIcon(Icons.arrow_forward_ios));
    await tester.pumpAndSettle();

    // Skip button should still be visible
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Track Income & Expenses'), findsOneWidget);
  });

  testWidgets('Navigation to last page works correctly', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MoneyManagerApp());
    await tester.pumpAndSettle();

    // Navigate through all pages to the last one
    // Page 1 -> 2
    await tester.tap(find.byIcon(Icons.arrow_forward_ios));
    await tester.pumpAndSettle();

    // Page 2 -> 3
    await tester.tap(find.byIcon(Icons.arrow_forward_ios));
    await tester.pumpAndSettle();

    // Page 3 -> 4 (last page)
    await tester.tap(find.byIcon(Icons.arrow_forward_ios));
    await tester.pumpAndSettle();

    // Verify we're on the last page (check icon instead of Get Started button)
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(
      find.text('Skip'),
      findsNothing,
    ); // Skip should be hidden on last page
    expect(
      find.byIcon(Icons.arrow_back_ios_new),
      findsOneWidget,
    ); // Back arrow should be visible
    expect(
      find.byIcon(Icons.arrow_forward_ios),
      findsNothing,
    ); // Forward arrow should be hidden
  });

  testWidgets('Back navigation from last page works', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MoneyManagerApp());
    await tester.pumpAndSettle();

    // Navigate to the last page
    for (int i = 0; i < 3; i++) {
      await tester.tap(find.byIcon(Icons.arrow_forward_ios));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    // Verify we're on the last page (check icon instead of Get Started button)
    expect(find.byIcon(Icons.check), findsOneWidget);

    // Navigate back from last page
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Verify we're back on page 3
    expect(find.text('Multiple Accounts'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget); // Skip should be visible again
    expect(
      find.byIcon(Icons.arrow_forward_ios),
      findsOneWidget,
    ); // Forward arrow should be visible again
  });
}
