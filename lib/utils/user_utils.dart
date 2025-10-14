import '../models/user.dart';
import '../services/user_service.dart';
import '../services/device_record_service.dart';

/// Utility class for common user operations
class UserUtils {
  UserUtils._(); // Private constructor to prevent instantiation

  /// Check if a user exists in the system
  static bool userExists() {
    return UserService.instance.hasUser;
  }

  /// Get the current user
  static User? getCurrentUser() {
    return UserService.instance.currentUser;
  }

  /// Get the current user ID
  static String? getCurrentUserId() {
    return UserService.instance.getUserId();
  }

  /// Check if the current user is active
  static bool isCurrentUserActive() {
    return UserService.instance.isUserActive();
  }

  /// Check if the current user has a valid email
  static bool currentUserHasValidEmail() {
    return UserService.instance.hasValidEmail();
  }

  /// Check if the current user has a name
  static bool currentUserHasName() {
    return UserService.instance.hasUserName();
  }

  /// Validate the current user
  static bool isCurrentUserValid() {
    return UserService.instance.isCurrentUserValid();
  }

  /// Check if this is a first-time user (no user record exists)
  static bool isFirstTimeUser() {
    return !userExists();
  }

  /// Check if user is anonymous (has no email)
  static bool isAnonymousUser() {
    final user = getCurrentUser();
    return user != null && user.email.isEmpty;
  }

  /// Get user display name or fallback
  static String getUserDisplayName({String fallback = 'User'}) {
    final user = getCurrentUser();
    if (user == null || user.name.isEmpty) {
      return fallback;
    }
    return user.name;
  }

  /// Get user email or fallback
  static String getUserEmail({String fallback = ''}) {
    final user = getCurrentUser();
    if (user == null || user.email.isEmpty) {
      return fallback;
    }
    return user.email;
  }

  /// Get user currency code with fallback
  static String getUserCurrencyCode({String fallback = ''}) {
    final user = getCurrentUser();
    if (user == null || user.currencyCode.isEmpty) {
      return fallback;
    }
    return user.currencyCode;
  }

  /// Get user currency name with fallback
  static String getUserCurrencyName({String fallback = ''}) {
    final user = getCurrentUser();
    if (user == null || user.currencyName.isEmpty) {
      return fallback;
    }
    return user.currencyName;
  }

  /// Check if user has currency set
  static bool hasUserCurrency() {
    final user = getCurrentUser();
    return user?.currencyCode.isNotEmpty ?? false;
  }

  /// Create a new anonymous user
  static Future<User> createAnonymousUser() async {
    return await UserService.instance.createUser();
  }

  /// Update user information
  static Future<User> updateUserInfo({
    String? email,
    String? name,
    String? profilePic,
    String? currencyCode,
    String? currencyName,
  }) async {
    return await UserService.instance.updateUser(
      email: email,
      name: name,
      profilePic: profilePic,
      currencyCode: currencyCode,
      currencyName: currencyName,
    );
  }

  /// Update user currency
  static Future<User> updateUserCurrency({
    required String currencyCode,
    required String currencyName,
  }) async {
    return await UserService.instance.updateUser(
      currencyCode: currencyCode,
      currencyName: currencyName,
    );
  }

  /// Deactivate the current user
  static Future<User> deactivateUser() async {
    return await UserService.instance.updateUser(isActive: 0);
  }

  /// Reactivate the current user
  static Future<User> reactivateUser() async {
    return await UserService.instance.updateUser(isActive: 1);
  }

  /// Delete the current user and clear all data
  static Future<void> deleteCurrentUser() async {
    // Clear user data
    await UserService.instance.deleteUser();

    // Clear user ID from device record
    await DeviceRecordService.instance.clearUserId();
  }

  /// Refresh user data from storage
  static Future<void> refreshUserData() async {
    await UserService.instance.refreshUser();
  }

  /// Get user creation date as DateTime (converted from UTC to local)
  static DateTime? getUserCreationDate() {
    final user = getCurrentUser();
    if (user == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(
      user.createdAt,
      isUtc: true,
    ).toLocal();
  }

  /// Get user last update date as DateTime (converted from UTC to local)
  static DateTime? getUserLastUpdateDate() {
    final user = getCurrentUser();
    if (user == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(
      user.updatedAt,
      isUtc: true,
    ).toLocal();
  }

  /// Get user creation date as UTC DateTime (for internal use)
  static DateTime? getUserCreationDateUtc() {
    final user = getCurrentUser();
    if (user == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(user.createdAt, isUtc: true);
  }

  /// Get user last update date as UTC DateTime (for internal use)
  static DateTime? getUserLastUpdateDateUtc() {
    final user = getCurrentUser();
    if (user == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(user.updatedAt, isUtc: true);
  }

  /// Get formatted user creation date (in local timezone)
  static String getFormattedCreationDate({String format = 'yyyy-MM-dd'}) {
    final date = getUserCreationDate(); // Already converted to local
    if (date == null) return '';

    // Simple formatting - you might want to use intl package for better formatting
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get formatted user creation date and time (in local timezone)
  static String getFormattedCreationDateTime({
    String format = 'yyyy-MM-dd HH:mm',
  }) {
    final date = getUserCreationDate(); // Already converted to local
    if (date == null) return '';

    // Simple formatting with time
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted user last update date and time (in local timezone)
  static String getFormattedLastUpdateDateTime({
    String format = 'yyyy-MM-dd HH:mm',
  }) {
    final date = getUserLastUpdateDate(); // Already converted to local
    if (date == null) return '';

    // Simple formatting with time
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Check if user was created today (in local timezone)
  static bool wasUserCreatedToday() {
    final creationDate = getUserCreationDate(); // Already converted to local
    if (creationDate == null) return false;

    final now = DateTime.now();
    return creationDate.year == now.year &&
        creationDate.month == now.month &&
        creationDate.day == now.day;
  }

  /// Get user age in days (calculated using UTC for accuracy)
  static int getUserAgeInDays() {
    final creationDateUtc = getUserCreationDateUtc();
    if (creationDateUtc == null) return 0;

    final nowUtc = DateTime.now().toUtc();
    return nowUtc.difference(creationDateUtc).inDays;
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;

    // Basic email validation
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  /// Validate user name
  static bool isValidName(String name) {
    return name.isNotEmpty && name.trim().length >= 2;
  }

  /// Get user summary for debugging
  static Map<String, dynamic> getUserSummary() {
    final user = getCurrentUser();
    if (user == null) {
      return {'exists': false, 'message': 'No user found'};
    }

    return {
      'exists': true,
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'isActive': user.isUserActive,
      'hasValidEmail': user.hasValidEmail,
      'createdAt': getUserCreationDate()
          ?.toIso8601String(), // Local time for display
      'updatedAt': getUserLastUpdateDate()
          ?.toIso8601String(), // Local time for display
      'createdAtUtc': getUserCreationDateUtc()
          ?.toIso8601String(), // UTC for debugging
      'updatedAtUtc': getUserLastUpdateDateUtc()
          ?.toIso8601String(), // UTC for debugging
      'createdAtFormatted': getFormattedCreationDateTime(),
      'updatedAtFormatted': getFormattedLastUpdateDateTime(),
      'ageInDays': getUserAgeInDays(),
      'isAnonymous': isAnonymousUser(),
      'wasCreatedToday': wasUserCreatedToday(),
      'currencyCode': user.currencyCode,
      'currencyName': user.currencyName,
      'hasCurrency': hasUserCurrency(),
    };
  }
}
