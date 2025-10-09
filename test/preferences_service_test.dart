import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_manager/services/preferences_service.dart';

void main() {
  group('PreferencesService', () {
    late PreferencesService preferencesService;

    setUp(() async {
      // Initialize SharedPreferences with empty values for testing
      SharedPreferences.setMockInitialValues({});
      preferencesService = await PreferencesService.getInstance();
      // Clear all preferences before each test
      await preferencesService.clearAll();
    });

    test('should save and retrieve selected currency', () async {
      // Test saving currency
      await preferencesService.setSelectedCurrency('USD');

      // Test retrieving currency
      final savedCurrency = preferencesService.getSelectedCurrency();
      expect(savedCurrency, equals('USD'));
    });

    test('should return null when no currency is saved', () {
      final savedCurrency = preferencesService.getSelectedCurrency();
      expect(savedCurrency, isNull);
    });

    test('should check if currency is set', () async {
      // Initially no currency should be set
      expect(preferencesService.hasCurrencySet(), isFalse);

      // After setting currency, should return true
      await preferencesService.setSelectedCurrency('EUR');
      expect(preferencesService.hasCurrencySet(), isTrue);
    });

    test('should clear selected currency', () async {
      // Set a currency first
      await preferencesService.setSelectedCurrency('GBP');
      expect(preferencesService.getSelectedCurrency(), equals('GBP'));

      // Clear the currency
      await preferencesService.clearSelectedCurrency();
      expect(preferencesService.getSelectedCurrency(), isNull);
      expect(preferencesService.hasCurrencySet(), isFalse);
    });

    test('should save and retrieve onboarding status', () async {
      // Initially should be false
      expect(preferencesService.isOnboardingComplete(), isFalse);

      // Set onboarding complete
      await preferencesService.setOnboardingComplete(true);
      expect(preferencesService.isOnboardingComplete(), isTrue);

      // Set onboarding incomplete
      await preferencesService.setOnboardingComplete(false);
      expect(preferencesService.isOnboardingComplete(), isFalse);
    });

    test('should clear all preferences', () async {
      // Set some preferences
      await preferencesService.setSelectedCurrency('JPY');
      await preferencesService.setOnboardingComplete(true);

      // Verify they are set
      expect(preferencesService.getSelectedCurrency(), equals('JPY'));
      expect(preferencesService.isOnboardingComplete(), isTrue);

      // Clear all preferences
      await preferencesService.clearAll();

      // Verify they are cleared
      expect(preferencesService.getSelectedCurrency(), isNull);
      expect(preferencesService.isOnboardingComplete(), isFalse);
    });

    test('should get all preferences', () async {
      // Set some preferences
      await preferencesService.setSelectedCurrency('CAD');
      await preferencesService.setOnboardingComplete(true);

      // Get all preferences
      final allPrefs = preferencesService.getAllPreferences();

      expect(allPrefs['selected_currency'], equals('CAD'));
      expect(allPrefs['is_onboarding_complete'], isTrue);
    });
  });
}
