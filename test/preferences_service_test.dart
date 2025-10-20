import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_manager/services/preferences_service.dart';
import 'package:money_manager/models/device.dart';

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

    // Device Record Tests
    group('Device Record', () {
      late Device testDeviceRecord;

      setUp(() {
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        testDeviceRecord = Device(
          id: 'test-device-id',
          platformType: 'android',
          os: 'Android',
          osVersion: 'Android 13',
          countryCode: 'US',
          countryName: 'United States',
          createdAt: now,
          updatedAt: now,
          userId: 'test-user-123',
          lastOpenedAt: now,
          appVersion: '1.0.0',
          appBuildNumber: 1,
          deviceManufacturer: 'Google',
          langCode: 'en',
          timezone: 'UTC',
          timezoneOffset: 0,
          fcmToken: 'test-fcm-token',
        );
      });

      test('should save and retrieve device record', () async {
        // Save device record
        await preferencesService.setDeviceRecord(testDeviceRecord);

        // Retrieve device record
        final retrievedRecord = preferencesService.getDeviceRecord();

        expect(retrievedRecord, isNotNull);
        expect(retrievedRecord!.id, equals(testDeviceRecord.id));
        expect(
          retrievedRecord.platformType,
          equals(testDeviceRecord.platformType),
        );
        expect(retrievedRecord.userId, equals(testDeviceRecord.userId));
        expect(retrievedRecord.appVersion, equals(testDeviceRecord.appVersion));
      });

      test('should return null when no device record exists', () {
        final retrievedRecord = preferencesService.getDeviceRecord();
        expect(retrievedRecord, isNull);
      });

      test('should check if device record exists', () async {
        // Initially no device record
        expect(preferencesService.hasDeviceRecord(), isFalse);

        // Save device record
        await preferencesService.setDeviceRecord(testDeviceRecord);

        // Now should exist
        expect(preferencesService.hasDeviceRecord(), isTrue);
      });

      test('should clear device record', () async {
        // Save device record
        await preferencesService.setDeviceRecord(testDeviceRecord);
        expect(preferencesService.hasDeviceRecord(), isTrue);

        // Clear device record
        await preferencesService.clearDeviceRecord();
        expect(preferencesService.hasDeviceRecord(), isFalse);
        expect(preferencesService.getDeviceRecord(), isNull);
      });

      test('should update device record userId', () async {
        // Save initial device record
        await preferencesService.setDeviceRecord(testDeviceRecord);

        // Update userId
        await preferencesService.updateDeviceRecordUserId('new-user-456');

        // Retrieve and verify
        final updatedRecord = preferencesService.getDeviceRecord();
        expect(updatedRecord, isNotNull);
        expect(updatedRecord!.userId, equals('new-user-456'));
        expect(
          updatedRecord.id,
          equals(testDeviceRecord.id),
        ); // ID should remain same
      });

      test('should update device record lastOpenedAt', () async {
        // Save initial device record
        await preferencesService.setDeviceRecord(testDeviceRecord);

        // Wait a bit to ensure timestamp difference
        await Future.delayed(const Duration(milliseconds: 10));

        // Update lastOpenedAt
        await preferencesService.updateDeviceRecordLastOpenedAt();

        // Retrieve and verify
        final updatedRecord = preferencesService.getDeviceRecord();
        expect(updatedRecord, isNotNull);
        expect(
          updatedRecord!.lastOpenedAt,
          greaterThan(testDeviceRecord.lastOpenedAt),
        );
        expect(
          updatedRecord.id,
          equals(testDeviceRecord.id),
        ); // ID should remain same
      });

      test('should handle corrupted device record data', () async {
        // Manually set corrupted JSON data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('device_record', 'invalid-json-data');

        // Should return null and clear corrupted data
        final retrievedRecord = preferencesService.getDeviceRecord();
        expect(retrievedRecord, isNull);
        expect(preferencesService.hasDeviceRecord(), isFalse);
      });
    });
  });
}
