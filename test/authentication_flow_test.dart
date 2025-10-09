import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/main.dart';

void main() {
  group('Authentication Flow Tests', () {
    testWidgets('Complete authentication flow - Get Started path', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MoneyManagerApp());
      await tester.pumpAndSettle();

      // Verify intro screen is displayed
      expect(find.text('Welcome to Money Manager'), findsOneWidget);

      // Navigate through intro pages to the end
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byIcon(Icons.arrow_forward_ios));
        await tester.pumpAndSettle();
      }

      // Tap the check button on the last intro page
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      // Should now be on auth choice screen
      expect(find.text('Take control of your finances today'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('I have an account'), findsOneWidget);

      // Tap "Get Started"
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Should now be on currency selection screen
      expect(find.text('Choose Your Currency'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
      expect(find.text('EUR'), findsOneWidget);

      // Select USD currency
      await tester.tap(find.text('USD').first);
      await tester.pumpAndSettle();

      // Tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Should now be on backup account screen
      expect(find.text('Secure Your Data'), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.text('Sign in with Apple'), findsOneWidget);
      expect(find.text('Skip for now'), findsOneWidget);

      // Tap "Skip for now"
      await tester.tap(find.text('Skip for now'));
      await tester.pumpAndSettle();

      // Should now be on home screen
      expect(find.text('Welcome to Money Manager!'), findsOneWidget);
      expect(find.text('Your financial tracking journey starts here.'), findsOneWidget);
    });

    testWidgets('Authentication flow - I have an account path', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MoneyManagerApp());
      await tester.pumpAndSettle();

      // Skip intro by tapping skip button
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Should be on auth choice screen
      expect(find.text('I have an account'), findsOneWidget);

      // Tap "I have an account"
      await tester.tap(find.text('I have an account'));
      await tester.pumpAndSettle();

      // Should now be on sign-in screen
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.text('Sign in with Apple'), findsOneWidget);
      expect(find.text('Start Fresh'), findsOneWidget);

      // Test "Start Fresh" option
      await tester.tap(find.text('Start Fresh'));
      await tester.pumpAndSettle();

      // Should be back on currency selection screen
      expect(find.text('Choose Your Currency'), findsOneWidget);
    });

    testWidgets('Currency search functionality', (WidgetTester tester) async {
      // Build the app and navigate to currency selection
      await tester.pumpWidget(const MoneyManagerApp());
      await tester.pumpAndSettle();

      // Skip intro
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Go to currency selection via Get Started
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Test search functionality
      await tester.enterText(find.byType(TextField), 'EUR');
      await tester.pumpAndSettle();

      // Should show filtered results
      expect(find.text('EUR'), findsOneWidget);
      // USD should not be visible when searching for EUR
      expect(find.text('USD'), findsNothing);

      // Clear search
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      // All currencies should be visible again
      expect(find.text('USD'), findsOneWidget);
      expect(find.text('EUR'), findsOneWidget);
    });

    testWidgets('Back navigation works correctly', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MoneyManagerApp());
      await tester.pumpAndSettle();

      // Skip intro
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Go to currency selection
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Test back navigation
      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pumpAndSettle();

      // Should be back on auth choice screen
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('I have an account'), findsOneWidget);

      // Go to sign-in screen
      await tester.tap(find.text('I have an account'));
      await tester.pumpAndSettle();

      // Test back navigation from sign-in
      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pumpAndSettle();

      // Should be back on auth choice screen
      expect(find.text('Get Started'), findsOneWidget);
    });
  });
}
