import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/models/user.dart';

void main() {
  group('User Model Tests', () {
    late User testUser;
    final now = DateTime.now().millisecondsSinceEpoch;

    setUp(() {
      testUser = User(
        id: 'test-user-id',
        createdAt: now,
        updatedAt: now,
        isActive: 1,
        email: 'test@example.com',
        name: 'Test User',
        profilePic: 'https://example.com/profile.jpg',
      );
    });

    test('should create user with all required fields', () {
      expect(testUser.id, 'test-user-id');
      expect(testUser.createdAt, now);
      expect(testUser.updatedAt, now);
      expect(testUser.isActive, 1);
      expect(testUser.email, 'test@example.com');
      expect(testUser.name, 'Test User');
      expect(testUser.profilePic, 'https://example.com/profile.jpg');
    });

    test('should convert to JSON correctly', () {
      final json = testUser.toJson();
      
      expect(json['id'], 'test-user-id');
      expect(json['createdAt'], now);
      expect(json['updatedAt'], now);
      expect(json['isActive'], 1);
      expect(json['email'], 'test@example.com');
      expect(json['name'], 'Test User');
      expect(json['profilePic'], 'https://example.com/profile.jpg');
    });

    test('should create from JSON correctly', () {
      final json = {
        'id': 'json-user-id',
        'createdAt': now,
        'updatedAt': now,
        'isActive': 1,
        'email': 'json@example.com',
        'name': 'JSON User',
        'profilePic': 'https://example.com/json.jpg',
      };

      final user = User.fromJson(json);
      
      expect(user.id, 'json-user-id');
      expect(user.createdAt, now);
      expect(user.updatedAt, now);
      expect(user.isActive, 1);
      expect(user.email, 'json@example.com');
      expect(user.name, 'JSON User');
      expect(user.profilePic, 'https://example.com/json.jpg');
    });

    test('should create copy with updated fields', () {
      final updatedUser = testUser.copyWith(
        name: 'Updated Name',
        email: 'updated@example.com',
      );

      expect(updatedUser.id, testUser.id);
      expect(updatedUser.createdAt, testUser.createdAt);
      expect(updatedUser.updatedAt, testUser.updatedAt);
      expect(updatedUser.isActive, testUser.isActive);
      expect(updatedUser.name, 'Updated Name');
      expect(updatedUser.email, 'updated@example.com');
      expect(updatedUser.profilePic, testUser.profilePic);
    });

    test('should update timestamp correctly', () {
      final originalUpdatedAt = testUser.updatedAt;
      
      // Wait a bit to ensure timestamp difference
      Future.delayed(const Duration(milliseconds: 1));
      
      final updatedUser = testUser.updateTimestamp();
      
      expect(updatedUser.updatedAt, greaterThan(originalUpdatedAt));
      expect(updatedUser.id, testUser.id);
      expect(updatedUser.createdAt, testUser.createdAt);
      expect(updatedUser.isActive, testUser.isActive);
      expect(updatedUser.email, testUser.email);
      expect(updatedUser.name, testUser.name);
      expect(updatedUser.profilePic, testUser.profilePic);
    });

    test('should correctly identify active user', () {
      expect(testUser.isUserActive, true);
      
      final inactiveUser = testUser.copyWith(isActive: 0);
      expect(inactiveUser.isUserActive, false);
    });

    test('should validate email correctly', () {
      expect(testUser.hasValidEmail, true);
      
      final userWithoutEmail = testUser.copyWith(email: '');
      expect(userWithoutEmail.hasValidEmail, false);
      
      final userWithInvalidEmail = testUser.copyWith(email: 'invalid-email');
      expect(userWithInvalidEmail.hasValidEmail, false);
    });

    test('should check if user has name', () {
      expect(testUser.hasName, true);
      
      final userWithoutName = testUser.copyWith(name: '');
      expect(userWithoutName.hasName, false);
    });

    test('should check if user has profile picture', () {
      expect(testUser.hasProfilePic, true);
      
      final userWithoutProfilePic = testUser.copyWith(profilePic: '');
      expect(userWithoutProfilePic.hasProfilePic, false);
    });

    test('should validate user data correctly', () {
      expect(testUser.isValid, true);
      
      // Test invalid cases
      final userWithEmptyId = testUser.copyWith(id: '');
      expect(userWithEmptyId.isValid, false);
      
      final userWithInvalidActive = User(
        id: 'test-id',
        createdAt: now,
        updatedAt: now,
        isActive: 2, // Invalid value
        email: 'test@example.com',
        name: 'Test User',
        profilePic: '',
      );
      expect(userWithInvalidActive.isValid, false);
      
      final userWithInvalidEmail = testUser.copyWith(email: 'invalid');
      expect(userWithInvalidEmail.isValid, false);
      
      final userWithoutName = testUser.copyWith(name: '');
      expect(userWithoutName.isValid, false);
    });

    test('should implement toString correctly', () {
      final string = testUser.toString();
      expect(string, contains('test-user-id'));
      expect(string, contains('test@example.com'));
      expect(string, contains('Test User'));
      expect(string, contains('1'));
    });

    test('should implement equality correctly', () {
      final sameUser = User(
        id: 'test-user-id',
        createdAt: now,
        updatedAt: now,
        isActive: 1,
        email: 'test@example.com',
        name: 'Test User',
        profilePic: 'https://example.com/profile.jpg',
      );
      
      expect(testUser, equals(sameUser));
      expect(testUser.hashCode, equals(sameUser.hashCode));
      
      final differentUser = testUser.copyWith(name: 'Different Name');
      expect(testUser, isNot(equals(differentUser)));
      expect(testUser.hashCode, isNot(equals(differentUser.hashCode)));
    });

    test('should handle edge cases in validation', () {
      // Test with zero timestamps
      final userWithZeroTimestamps = testUser.copyWith(
        createdAt: 0,
        updatedAt: 0,
      );
      expect(userWithZeroTimestamps.isValid, false);
      
      // Test with negative timestamps
      final userWithNegativeTimestamps = testUser.copyWith(
        createdAt: -1,
        updatedAt: -1,
      );
      expect(userWithNegativeTimestamps.isValid, false);
    });
  });
}
