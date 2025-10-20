import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/models/device.dart';

void main() {
  group('Device Tests', () {
    late Device testDeviceRecord;
    late int testTimestamp;

    setUp(() {
      testTimestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
      testDeviceRecord = Device(
        id: 'test-device-id',
        platformType: 'android',
        os: 'Android',
        osVersion: 'Android 13 (API 33)',
        countryCode: 'US',
        countryName: 'United States',
        createdAt: testTimestamp,
        updatedAt: testTimestamp,
        userId: '',
        lastOpenedAt: testTimestamp,
        appVersion: '1.0.0',
        appBuildNumber: 1,
        deviceManufacturer: 'Google',
        langCode: 'en',
        timezone: 'America/New_York',
        timezoneOffset: -300,
        fcmToken: 'test-fcm-token',
      );
    });

    test('should create Device with all required fields', () {
      expect(testDeviceRecord.id, equals('test-device-id'));
      expect(testDeviceRecord.platformType, equals('android'));
      expect(testDeviceRecord.os, equals('Android'));
      expect(testDeviceRecord.osVersion, equals('Android 13 (API 33)'));
      expect(testDeviceRecord.countryCode, equals('US'));
      expect(testDeviceRecord.countryName, equals('United States'));
      expect(testDeviceRecord.createdAt, equals(testTimestamp));
      expect(testDeviceRecord.updatedAt, equals(testTimestamp));
      expect(testDeviceRecord.userId, equals(''));
      expect(testDeviceRecord.lastOpenedAt, equals(testTimestamp));
      expect(testDeviceRecord.appVersion, equals('1.0.0'));
      expect(testDeviceRecord.appBuildNumber, equals('1'));
      expect(testDeviceRecord.deviceManufacturer, equals('Google'));
      expect(testDeviceRecord.langCode, equals('en'));
      expect(testDeviceRecord.timezone, equals('America/New_York'));
      expect(testDeviceRecord.timezoneOffset, equals(-300));
    });

    test('should convert to JSON correctly', () {
      final json = testDeviceRecord.toJson();

      expect(json['id'], equals('test-device-id'));
      expect(json['platformType'], equals('android'));
      expect(json['os'], equals('Android'));
      expect(json['osVersion'], equals('Android 13 (API 33)'));
      expect(json['countryCode'], equals('US'));
      expect(json['countryName'], equals('United States'));
      expect(json['createdAt'], equals(testTimestamp));
      expect(json['updatedAt'], equals(testTimestamp));
      expect(json['userId'], equals(''));
      expect(json['lastOpenedAt'], equals(testTimestamp));
      expect(json['appVersion'], equals('1.0.0'));
      expect(json['appBuildNumber'], equals('1'));
      expect(json['deviceManufacturer'], equals('Google'));
      expect(json['langCode'], equals('en'));
      expect(json['timezone'], equals('America/New_York'));
      expect(json['timezoneOffset'], equals(-300));
    });

    test('should create from JSON correctly', () {
      final json = testDeviceRecord.toJson();
      final fromJson = Device.fromJson(json);

      expect(fromJson.id, equals(testDeviceRecord.id));
      expect(fromJson.platformType, equals(testDeviceRecord.platformType));
      expect(fromJson.os, equals(testDeviceRecord.os));
      expect(fromJson.osVersion, equals(testDeviceRecord.osVersion));
      expect(fromJson.countryCode, equals(testDeviceRecord.countryCode));
      expect(fromJson.countryName, equals(testDeviceRecord.countryName));
      expect(fromJson.createdAt, equals(testDeviceRecord.createdAt));
      expect(fromJson.updatedAt, equals(testDeviceRecord.updatedAt));
      expect(fromJson.userId, equals(testDeviceRecord.userId));
      expect(fromJson.lastOpenedAt, equals(testDeviceRecord.lastOpenedAt));
      expect(fromJson.appVersion, equals(testDeviceRecord.appVersion));
      expect(fromJson.appBuildNumber, equals(testDeviceRecord.appBuildNumber));
      expect(
        fromJson.deviceManufacturer,
        equals(testDeviceRecord.deviceManufacturer),
      );
      expect(fromJson.langCode, equals(testDeviceRecord.langCode));
      expect(fromJson.timezone, equals(testDeviceRecord.timezone));
      expect(fromJson.timezoneOffset, equals(testDeviceRecord.timezoneOffset));
    });

    test('should handle missing JSON fields with defaults', () {
      final incompleteJson = <String, dynamic>{
        'id': 'test-id',
        'platformType': 'ios',
      };

      final fromJson = Device.fromJson(incompleteJson);

      expect(fromJson.id, equals('test-id'));
      expect(fromJson.platformType, equals('ios'));
      expect(fromJson.os, equals(''));
      expect(fromJson.osVersion, equals(''));
      expect(fromJson.countryCode, equals(''));
      expect(fromJson.countryName, equals(''));
      expect(fromJson.createdAt, equals(0));
      expect(fromJson.updatedAt, equals(0));
      expect(fromJson.userId, equals(''));
      expect(fromJson.lastOpenedAt, equals(0));
      expect(fromJson.appVersion, equals(''));
      expect(fromJson.appBuildNumber, equals(''));
      expect(fromJson.deviceManufacturer, equals(''));
      expect(fromJson.langCode, equals(''));
      expect(fromJson.timezone, equals(''));
      expect(fromJson.timezoneOffset, equals(0));
    });

    test('should copy with updated fields', () {
      final updated = testDeviceRecord.copyWith(
        userId: 'new-user-id',
        appVersion: '2.0.0',
      );

      expect(updated.userId, equals('new-user-id'));
      expect(updated.appVersion, equals('2.0.0'));
      expect(updated.id, equals(testDeviceRecord.id)); // unchanged
      expect(
        updated.platformType,
        equals(testDeviceRecord.platformType),
      ); // unchanged
    });

    test('should update lastOpenedAt timestamp', () async {
      // Add a small delay to ensure timestamp difference
      await Future.delayed(const Duration(milliseconds: 1));
      final updated = testDeviceRecord.updateLastOpenedAt();

      expect(updated.lastOpenedAt, greaterThan(testDeviceRecord.lastOpenedAt));
      expect(updated.updatedAt, greaterThan(testDeviceRecord.updatedAt));
      expect(updated.id, equals(testDeviceRecord.id)); // unchanged
    });

    test('should update userId', () async {
      // Add a small delay to ensure timestamp difference
      await Future.delayed(const Duration(milliseconds: 1));
      final updated = testDeviceRecord.updateUserId('new-user-123');

      expect(updated.userId, equals('new-user-123'));
      expect(updated.updatedAt, greaterThan(testDeviceRecord.updatedAt));
      expect(updated.id, equals(testDeviceRecord.id)); // unchanged
    });

    test('should check if has userId', () {
      expect(testDeviceRecord.hasUserId, isFalse);

      final withUserId = testDeviceRecord.copyWith(userId: 'user-123');
      expect(withUserId.hasUserId, isTrue);
    });

    test('should check if is new device', () {
      // Device created now should be considered new
      expect(testDeviceRecord.isNewDevice, isTrue);

      // Device created 10 minutes ago should not be new
      final oldTimestamp = testTimestamp - (10 * 60 * 1000);
      final oldDevice = testDeviceRecord.copyWith(createdAt: oldTimestamp);
      expect(oldDevice.isNewDevice, isFalse);
    });

    test('should have proper toString representation', () {
      final stringRep = testDeviceRecord.toString();

      expect(stringRep, contains('test-device-id'));
      expect(stringRep, contains('android'));
      expect(stringRep, contains('Android'));
      expect(stringRep, contains('United States'));
      expect(stringRep, contains('US'));
      expect(stringRep, contains('1.0.0'));
      expect(stringRep, contains('Google'));
      expect(stringRep, contains('en'));
      expect(stringRep, contains('America/New_York'));
    });

    test('should check equality based on ID', () {
      final sameId = testDeviceRecord.copyWith(userId: 'different-user');
      final differentId = testDeviceRecord.copyWith(id: 'different-id');

      expect(testDeviceRecord == sameId, isTrue);
      expect(testDeviceRecord == differentId, isFalse);
    });

    test('should have consistent hashCode based on ID', () {
      final sameId = testDeviceRecord.copyWith(userId: 'different-user');

      expect(testDeviceRecord.hashCode, equals(sameId.hashCode));
    });
  });
}
