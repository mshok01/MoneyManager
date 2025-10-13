import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_manager/services/user_service.dart';

void main() {
  group('UserService Tests', () {
    late UserService userService;

    setUp(() async {
      // Clear shared preferences before each test
      SharedPreferences.setMockInitialValues({});
      userService = UserService.instance;
      await userService.initialize();
    });

    tearDown(() async {
      // Clear user data after each test
      await userService.clearUserData();
    });

    test('should initialize correctly', () {
      expect(userService.isInitialized, true);
      expect(userService.hasUser, false);
      expect(userService.currentUser, null);
    });

    test('should create user successfully', () async {
      final user = await userService.createUser(
        email: 'test@example.com',
        name: 'Test User',
        profilePic: 'https://example.com/profile.jpg',
      );

      expect(user.id, isNotEmpty);
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.profilePic, 'https://example.com/profile.jpg');
      expect(user.isActive, 1);
      expect(user.createdAt, greaterThan(0));
      expect(user.updatedAt, greaterThan(0));

      expect(userService.hasUser, true);
      expect(userService.currentUser, equals(user));
    });

    test('should create anonymous user with defaults', () async {
      final user = await userService.createUser();

      expect(user.id, isNotEmpty);
      expect(user.email, '');
      expect(user.name, 'User');
      expect(user.profilePic, '');
      expect(user.isActive, 1);
      expect(user.createdAt, greaterThan(0));
      expect(user.updatedAt, greaterThan(0));
    });

    test('should update user successfully', () async {
      // Create a user first
      await userService.createUser(
        email: 'original@example.com',
        name: 'Original Name',
      );

      final originalUpdatedAt = userService.currentUser!.updatedAt;

      // Wait a bit to ensure timestamp difference
      await Future.delayed(const Duration(milliseconds: 1));

      // Update the user
      final updatedUser = await userService.updateUser(
        email: 'updated@example.com',
        name: 'Updated Name',
        profilePic: 'https://example.com/new-profile.jpg',
      );

      expect(updatedUser.email, 'updated@example.com');
      expect(updatedUser.name, 'Updated Name');
      expect(updatedUser.profilePic, 'https://example.com/new-profile.jpg');
      expect(updatedUser.updatedAt, greaterThan(originalUpdatedAt));

      expect(userService.currentUser, equals(updatedUser));
    });

    test('should update user timestamp', () async {
      // Create a user first
      await userService.createUser();
      final originalUpdatedAt = userService.currentUser!.updatedAt;

      // Wait a bit to ensure timestamp difference
      await Future.delayed(const Duration(milliseconds: 1));

      // Update timestamp
      await userService.updateUserTimestamp();

      expect(
        userService.currentUser!.updatedAt,
        greaterThan(originalUpdatedAt),
      );
    });

    test('should delete user successfully', () async {
      // Create a user first
      await userService.createUser();
      expect(userService.hasUser, true);

      // Delete the user
      await userService.deleteUser();

      expect(userService.hasUser, false);
      expect(userService.currentUser, null);
    });

    test('should get user ID correctly', () async {
      expect(userService.getUserId(), null);

      final user = await userService.createUser();
      expect(userService.getUserId(), user.id);
    });

    test('should check user active status correctly', () async {
      expect(userService.isUserActive(), false);

      await userService.createUser();
      expect(userService.isUserActive(), true);

      await userService.updateUser(isActive: 0);
      expect(userService.isUserActive(), false);
    });

    test('should check valid email correctly', () async {
      expect(userService.hasValidEmail(), false);

      await userService.createUser(email: 'test@example.com');
      expect(userService.hasValidEmail(), true);

      await userService.updateUser(email: '');
      expect(userService.hasValidEmail(), false);
    });

    test('should check user name correctly', () async {
      expect(userService.hasUserName(), false);

      await userService.createUser(name: 'Test User');
      expect(userService.hasUserName(), true);

      await userService.updateUser(name: '');
      expect(userService.hasUserName(), false);
    });

    test('should validate current user correctly', () async {
      expect(userService.isCurrentUserValid(), false);

      await userService.createUser(
        email: 'test@example.com',
        name: 'Test User',
      );
      expect(userService.isCurrentUserValid(), true);
    });

    test('should refresh user data correctly', () async {
      // Create a user
      await userService.createUser(name: 'Original Name');
      final originalName = userService.currentUser!.name;

      // Refresh should reload from preferences (no change expected in this case)
      await userService.refreshUser();

      expect(userService.currentUser!.name, originalName);
    });

    test('should handle errors gracefully', () async {
      // Test updating user when no user exists
      expect(() => userService.updateUser(name: 'Test'), throwsException);
    });

    test('should persist user data across app restarts', () async {
      // Create user with current instance
      await userService.createUser(
        email: 'persist@example.com',
        name: 'Persistent User',
      );

      final userId = userService.getUserId();

      // Simulate app restart by refreshing user data
      await userService.refreshUser();

      // Should still have the same user data
      expect(userService.hasUser, true);
      expect(userService.getUserId(), userId);
      expect(userService.currentUser!.email, 'persist@example.com');
      expect(userService.currentUser!.name, 'Persistent User');
    });

    test('should clear user data completely', () async {
      // Create user
      await userService.createUser();
      expect(userService.hasUser, true);
      expect(userService.isInitialized, true);

      // Clear all data
      await userService.clearUserData();

      expect(userService.hasUser, false);
      expect(userService.currentUser, null);
      expect(userService.isInitialized, false);
    });
  });
}
