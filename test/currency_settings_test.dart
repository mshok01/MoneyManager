import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/models/user.dart';
import 'package:money_manager/screens/settings_screen.dart';
import 'package:money_manager/services/user_service.dart';
import 'package:money_manager/services/preferences_service.dart';
import 'package:money_manager/services/theme_service.dart';
import 'package:money_manager/database/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Currency Settings Tests', () {
    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      
      // Initialize services
      await ThemeService.instance.initialize();
      await DatabaseService.instance.initialize();
      await UserService.instance.initialize();
    });

    testWidgets('Settings screen shows user currency from user record', (
      WidgetTester tester,
    ) async {
      // Create a test user with specific currency
      final testUser = User(
        id: 'test-user-id',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        isActive: 1,
        email: 'test@example.com',
        name: 'Test User',
        profilePic: '',
        currencyCode: 'EUR',
        currencyName: 'Euro',
      );

      // Create the user in the service
      await UserService.instance.createUser(
        email: testUser.email,
        name: testUser.name,
        currencyCode: testUser.currencyCode,
        currencyName: testUser.currencyName,
      );

      // Build the settings screen
      await tester.pumpWidget(
        MaterialApp(
          home: const SettingsScreen(),
          localizationsDelegates: const [
            // Add minimal localizations for testing
          ],
        ),
      );

      // Wait for the screen to load
      await tester.pumpAndSettle();

      // Verify that the currency name is displayed
      expect(find.textContaining('Euro'), findsAtLeastNWidgets(1));
    });

    testWidgets('Settings screen falls back to preferences if user has no currency', (
      WidgetTester tester,
    ) async {
      // Set currency in preferences
      final prefs = await PreferencesService.getInstance();
      await prefs.setSelectedCurrency('USD');

      // Create a user without currency
      await UserService.instance.createUser(
        email: 'test@example.com',
        name: 'Test User',
        currencyCode: '',
        currencyName: '',
      );

      // Build the settings screen
      await tester.pumpWidget(
        MaterialApp(
          home: const SettingsScreen(),
        ),
      );

      // Wait for the screen to load
      await tester.pumpAndSettle();

      // Verify that USD is displayed (from preferences)
      expect(find.textContaining('USD'), findsAtLeastNWidgets(1));
    });
  });
}
