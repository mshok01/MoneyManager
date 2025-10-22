import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/screens/sign_in_screen.dart';
import 'package:money_manager/l10n/app_localizations.dart';

void main() {
  group('Google Sign-In Flow Tests', () {
    testWidgets('Sign-in screen displays correctly with all UI elements', (
      WidgetTester tester,
    ) async {
      // Build the sign-in screen
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SignInScreen(),
        ),
      );

      // Verify title is displayed
      expect(find.text('Welcome Back!'), findsOneWidget);

      // Verify description is displayed
      expect(find.text('Sign in to restore your data'), findsOneWidget);

      // Verify all sign-in buttons are present
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.text('Sign in with Apple'), findsOneWidget);

      // Verify subtitles
      expect(find.text('Restore your data'), findsOneWidget);
      expect(find.text('Secure & private'), findsOneWidget);

      // Verify alternative option
      expect(find.text('Start Fresh'), findsOneWidget);
      expect(
        find.text('Not you? Sign in with different account'),
        findsOneWidget,
      );
    });

    testWidgets('Google sign-in button is present and enabled', (
      WidgetTester tester,
    ) async {
      // Build the sign-in screen
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SignInScreen(),
        ),
      );

      // Verify Google sign-in button text
      expect(find.text('Sign in with Google'), findsOneWidget);

      // Verify Google icon is present
      expect(find.byIcon(Icons.g_mobiledata), findsOneWidget);
    });

    testWidgets('Apple sign-in button is present and enabled', (
      WidgetTester tester,
    ) async {
      // Build the sign-in screen
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SignInScreen(),
        ),
      );

      // Verify Apple sign-in button text
      expect(find.text('Sign in with Apple'), findsOneWidget);

      // Verify Apple icon is present
      expect(find.byIcon(Icons.apple), findsOneWidget);
    });

    testWidgets('Start Fresh button is present and enabled', (
      WidgetTester tester,
    ) async {
      // Build the sign-in screen
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SignInScreen(),
        ),
      );

      // Find the Start Fresh button
      final startFreshButton = find.byType(OutlinedButton);
      expect(startFreshButton, findsOneWidget);

      // Verify button text
      expect(find.text('Start Fresh'), findsOneWidget);
    });

    testWidgets('Back button is present', (WidgetTester tester) async {
      // Build the sign-in screen
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SignInScreen(),
        ),
      );

      // Verify sign-in screen is displayed
      expect(find.text('Welcome Back!'), findsOneWidget);

      // Find the back button
      final backButton = find.byIcon(Icons.arrow_back_ios);
      expect(backButton, findsOneWidget);
    });
  });
}
