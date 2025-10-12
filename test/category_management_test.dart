import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Category Management Tests', () {
    setUp(() {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Categories option appears in settings screen', (
      WidgetTester tester,
    ) async {
      // Build the app and navigate to settings screen
      await tester.pumpWidget(const MoneyManagerApp());
      await tester.pumpAndSettle();

      // Skip intro by tapping skip button
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Skip auth choice by tapping "Get Started"
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Skip currency selection
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Skip backup account
      await tester.tap(find.text('Skip for now'));
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();

      // Wait for settings screen to load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Check if Categories option is present
      expect(find.text('Categories'), findsAtLeastNWidgets(1));
      expect(find.text('Manage Categories'), findsOneWidget);
      expect(find.byIcon(Icons.category), findsOneWidget);
    });

    testWidgets('Categories option navigates to category screen', (
      WidgetTester tester,
    ) async {
      // Build the app and navigate to settings screen
      await tester.pumpWidget(const MoneyManagerApp());
      await tester.pumpAndSettle();

      // Skip intro by tapping skip button
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Skip auth choice by tapping "Get Started"
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Skip currency selection
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Skip backup account
      await tester.tap(find.text('Skip for now'));
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();

      // Wait for settings screen to load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap categories option
      await tester.tap(find.byIcon(Icons.category));
      await tester.pumpAndSettle();

      // Should navigate to category screen
      expect(
        find.text('Categories'),
        findsAtLeastNWidgets(1),
      ); // Title in app bar
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
    });

    testWidgets('Category screen shows default categories', (
      WidgetTester tester,
    ) async {
      // Build the app and navigate to category screen
      await tester.pumpWidget(const MoneyManagerApp());
      await tester.pumpAndSettle();

      // Skip intro by tapping skip button
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Skip auth choice by tapping "Get Started"
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Skip currency selection
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Skip backup account
      await tester.tap(find.text('Skip for now'));
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();

      // Wait for settings screen to load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap categories option
      await tester.tap(find.byIcon(Icons.category));
      await tester.pumpAndSettle();

      // Should be on category screen with Income tab active by default
      expect(find.text('Categories'), findsAtLeastNWidgets(1));

      // Check for default income categories
      expect(find.text('Salary'), findsOneWidget);
      expect(find.text('Freelance'), findsOneWidget);
      expect(find.text('Business'), findsOneWidget);
      expect(find.text('Investment Returns'), findsOneWidget);
      expect(find.text('Gifts Received'), findsOneWidget);
      expect(find.text('Other Income'), findsOneWidget);

      // Switch to Expenses tab
      await tester.tap(find.text('Expenses'));
      await tester.pumpAndSettle();

      // Check for default expense categories (some might require scrolling)
      expect(find.text('Food & Dining'), findsOneWidget);
      expect(find.text('Transportation'), findsOneWidget);
      expect(find.text('Utilities'), findsOneWidget);
      expect(find.text('Housing'), findsOneWidget);

      // Scroll down to see more categories
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Check for remaining categories
      expect(find.text('Entertainment'), findsOneWidget);
      expect(find.text('Healthcare'), findsOneWidget);
      expect(find.text('Shopping'), findsOneWidget);
      expect(find.text('Financial'), findsOneWidget);
      expect(find.text('Other Expenses'), findsOneWidget);
    });

    testWidgets('Category screen has add button in app bar', (
      WidgetTester tester,
    ) async {
      // Build the app and navigate to category screen
      await tester.pumpWidget(const MoneyManagerApp());
      await tester.pumpAndSettle();

      // Skip intro by tapping skip button
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Skip auth choice by tapping "Get Started"
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Skip currency selection
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Skip backup account
      await tester.tap(find.text('Skip for now'));
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();

      // Wait for settings screen to load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap categories option
      await tester.tap(find.byIcon(Icons.category));
      await tester.pumpAndSettle();

      // Should have add button in app bar
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Tap the add button to test it opens dialog
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Should show add category dialog
      expect(find.text('Add Category'), findsOneWidget);
      expect(find.text('Category Title'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Category Type'), findsOneWidget);
      expect(find.text('Income'), findsAtLeastNWidgets(1));
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('Can add a new category', (WidgetTester tester) async {
      // Build the app and navigate to category screen
      await tester.pumpWidget(const MoneyManagerApp());
      await tester.pumpAndSettle();

      // Skip intro by tapping skip button
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Skip auth choice by tapping "Get Started"
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Skip currency selection
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Skip backup account
      await tester.tap(find.text('Skip for now'));
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();

      // Wait for settings screen to load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap categories option
      await tester.tap(find.byIcon(Icons.category));
      await tester.pumpAndSettle();

      // Tap the add button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Fill in the form
      await tester.enterText(find.byType(TextFormField).first, 'Test Category');
      await tester.enterText(
        find.byType(TextFormField).last,
        'Test Description',
      );

      // Select Expense type
      await tester.tap(find.text('Expense'));
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Should show success message
      expect(
        find.text("Category 'Test Category' added successfully"),
        findsOneWidget,
      );

      // Switch to Expenses tab to see the new category
      await tester.tap(find.text('Expenses'));
      await tester.pumpAndSettle();

      // Scroll down to find the new category (it's added at the end)
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Should find the new category
      expect(find.text('Test Category'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });
  });
}
