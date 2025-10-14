import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_manager/utils/user_utils.dart';
import 'package:money_manager/services/user_service.dart';

void main() {
  group('UserUtils Tests', () {
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

    test('should check if user exists correctly', () async {
      expect(UserUtils.userExists(), false);
      expect(UserUtils.isFirstTimeUser(), true);

      await userService.createUser();

      expect(UserUtils.userExists(), true);
      expect(UserUtils.isFirstTimeUser(), false);
    });

    test('should get current user correctly', () async {
      expect(UserUtils.getCurrentUser(), null);
      expect(UserUtils.getCurrentUserId(), null);

      final user = await userService.createUser(
        email: 'test@example.com',
        name: 'Test User',
      );

      expect(UserUtils.getCurrentUser(), equals(user));
      expect(UserUtils.getCurrentUserId(), user.id);
    });

    test('should check user status correctly', () async {
      expect(UserUtils.isCurrentUserActive(), false);
      expect(UserUtils.currentUserHasValidEmail(), false);
      expect(UserUtils.currentUserHasName(), false);
      expect(UserUtils.isCurrentUserValid(), false);

      await userService.createUser(
        email: 'test@example.com',
        name: 'Test User',
      );

      expect(UserUtils.isCurrentUserActive(), true);
      expect(UserUtils.currentUserHasValidEmail(), true);
      expect(UserUtils.currentUserHasName(), true);
      expect(UserUtils.isCurrentUserValid(), true);
    });

    test('should check if user is anonymous', () async {
      expect(UserUtils.isAnonymousUser(), false);

      // Create user without email (anonymous)
      await userService.createUser(name: 'Anonymous User');
      expect(UserUtils.isAnonymousUser(), true);

      // Update with email (no longer anonymous)
      await userService.updateUser(email: 'test@example.com');
      expect(UserUtils.isAnonymousUser(), false);
    });

    test('should get user display name with fallback', () async {
      expect(UserUtils.getUserDisplayName(), 'User');
      expect(UserUtils.getUserDisplayName(fallback: 'Guest'), 'Guest');

      await userService.createUser(name: 'Test User');
      expect(UserUtils.getUserDisplayName(), 'Test User');
      expect(UserUtils.getUserDisplayName(fallback: 'Guest'), 'Test User');

      await userService.updateUser(name: '');
      expect(UserUtils.getUserDisplayName(), 'User');
      expect(UserUtils.getUserDisplayName(fallback: 'Guest'), 'Guest');
    });

    test('should get user email with fallback', () async {
      expect(UserUtils.getUserEmail(), '');
      expect(UserUtils.getUserEmail(fallback: 'no-email'), 'no-email');

      await userService.createUser(email: 'test@example.com');
      expect(UserUtils.getUserEmail(), 'test@example.com');
      expect(UserUtils.getUserEmail(fallback: 'no-email'), 'test@example.com');

      await userService.updateUser(email: '');
      expect(UserUtils.getUserEmail(), '');
      expect(UserUtils.getUserEmail(fallback: 'no-email'), 'no-email');
    });

    test('should get user currency with fallback', () async {
      // No user initially
      expect(UserUtils.getUserCurrencyCode(), '');
      expect(UserUtils.getUserCurrencyName(), '');
      expect(UserUtils.getUserCurrencyCode(fallback: 'USD'), 'USD');
      expect(UserUtils.getUserCurrencyName(fallback: 'US Dollar'), 'US Dollar');
      expect(UserUtils.hasUserCurrency(), false);

      // Create user and set currency
      await userService.createUser();
      await UserUtils.updateUserCurrency(
        currencyCode: 'EUR',
        currencyName: 'Euro',
      );
      expect(UserUtils.getUserCurrencyCode(), 'EUR');
      expect(UserUtils.getUserCurrencyName(), 'Euro');
      expect(UserUtils.hasUserCurrency(), true);

      // Clear currency
      await UserUtils.updateUserInfo(currencyCode: '', currencyName: '');
      expect(UserUtils.getUserCurrencyCode(), '');
      expect(UserUtils.getUserCurrencyName(), '');
      expect(UserUtils.hasUserCurrency(), false);
    });

    test('should create anonymous user', () async {
      expect(UserUtils.userExists(), false);

      final user = await UserUtils.createAnonymousUser();

      expect(user.id, isNotEmpty);
      expect(user.email, '');
      expect(user.name, 'User');
      expect(user.isActive, 1);
      expect(UserUtils.userExists(), true);
    });

    test('should update user info', () async {
      await userService.createUser();

      final updatedUser = await UserUtils.updateUserInfo(
        email: 'updated@example.com',
        name: 'Updated Name',
        profilePic: 'https://example.com/new.jpg',
      );

      expect(updatedUser.email, 'updated@example.com');
      expect(updatedUser.name, 'Updated Name');
      expect(updatedUser.profilePic, 'https://example.com/new.jpg');
      expect(UserUtils.getCurrentUser(), equals(updatedUser));
    });

    test('should deactivate and reactivate user', () async {
      await userService.createUser();
      expect(UserUtils.isCurrentUserActive(), true);

      await UserUtils.deactivateUser();
      expect(UserUtils.isCurrentUserActive(), false);

      await UserUtils.reactivateUser();
      expect(UserUtils.isCurrentUserActive(), true);
    });

    test('should delete current user', () async {
      await userService.createUser();
      expect(UserUtils.userExists(), true);

      await UserUtils.deleteCurrentUser();
      expect(UserUtils.userExists(), false);
      expect(UserUtils.getCurrentUser(), null);
    });

    test('should refresh user data', () async {
      await userService.createUser(name: 'Original Name');
      expect(UserUtils.getCurrentUser()!.name, 'Original Name');

      // Refresh should work without errors
      await UserUtils.refreshUserData();
      expect(UserUtils.getCurrentUser()!.name, 'Original Name');
    });

    test('should get user creation and update dates', () async {
      expect(UserUtils.getUserCreationDate(), null);
      expect(UserUtils.getUserLastUpdateDate(), null);

      await userService.createUser();

      final creationDate = UserUtils.getUserCreationDate();
      final updateDate = UserUtils.getUserLastUpdateDate();

      expect(creationDate, isNotNull);
      expect(updateDate, isNotNull);
      expect(creationDate!.millisecondsSinceEpoch, greaterThan(0));
      expect(updateDate!.millisecondsSinceEpoch, greaterThan(0));
    });

    test('should format creation date', () async {
      expect(UserUtils.getFormattedCreationDate(), '');

      await userService.createUser();

      final formatted = UserUtils.getFormattedCreationDate();
      expect(formatted, matches(r'^\d{4}-\d{2}-\d{2}$'));
    });

    test('should check if user was created today', () async {
      expect(UserUtils.wasUserCreatedToday(), false);

      await userService.createUser();
      expect(UserUtils.wasUserCreatedToday(), true);
    });

    test('should get user age in days', () async {
      expect(UserUtils.getUserAgeInDays(), 0);

      await userService.createUser();
      expect(UserUtils.getUserAgeInDays(), 0); // Created today, so 0 days old
    });

    test('should validate email format', () {
      expect(UserUtils.isValidEmail(''), false);
      expect(UserUtils.isValidEmail('invalid'), false);
      expect(UserUtils.isValidEmail('invalid@'), false);
      expect(UserUtils.isValidEmail('@invalid.com'), false);
      expect(UserUtils.isValidEmail('valid@example.com'), true);
      expect(UserUtils.isValidEmail('user.name+tag@example.co.uk'), true);
    });

    test('should validate user name', () {
      expect(UserUtils.isValidName(''), false);
      expect(UserUtils.isValidName('a'), false);
      expect(UserUtils.isValidName('ab'), true);
      expect(UserUtils.isValidName('  ab  '), true); // Should trim
      expect(UserUtils.isValidName('Valid Name'), true);
    });

    test('should get user summary', () async {
      // No user case
      var summary = UserUtils.getUserSummary();
      expect(summary['exists'], false);
      expect(summary['message'], 'No user found');

      // With user case
      await userService.createUser(
        email: 'test@example.com',
        name: 'Test User',
      );

      summary = UserUtils.getUserSummary();
      expect(summary['exists'], true);
      expect(summary['id'], isNotEmpty);
      expect(summary['name'], 'Test User');
      expect(summary['email'], 'test@example.com');
      expect(summary['isActive'], true);
      expect(summary['hasValidEmail'], true);
      expect(summary['createdAt'], isNotNull);
      expect(summary['updatedAt'], isNotNull);
      expect(summary['ageInDays'], 0);
      expect(summary['isAnonymous'], false);
    });
  });
}
