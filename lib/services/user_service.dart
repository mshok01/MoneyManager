import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import 'preferences_service.dart';
import 'account_service.dart';
import '../database/database_service.dart';

class UserService {
  static UserService? _instance;
  static UserService get instance {
    _instance ??= UserService._();
    return _instance!;
  }

  UserService._();

  PreferencesService? _preferencesService;
  User? _currentUser;
  bool _isInitialized = false;
  final Uuid _uuid = const Uuid();

  // Default account constants - these will be replaced with localized strings
  static const String defaultAccountName = 'Main Account';
  static const String defaultAccountDescription =
      'Your primary account for tracking expenses and income';

  /// Get the current user
  User? get currentUser => _currentUser;

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Check if a user exists
  bool get hasUser => _currentUser != null;

  /// Initialize the user service
  /// This should be called when the app starts
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize dependencies
      _preferencesService = await PreferencesService.getInstance();
      await DatabaseService.instance.initialize();

      // Load existing user if available
      await _loadExistingUser();

      _isInitialized = true;
    } catch (e) {
      // Log error but don't throw to prevent app crash
      debugPrint('UserService initialization error: $e');
      _isInitialized = true; // Mark as initialized to prevent retry loops
    }
  }

  /// Load existing user from database
  Future<void> _loadExistingUser() async {
    try {
      // First try to load from database
      final users = await DatabaseService.instance.userDao.getActiveUsers();
      if (users.isNotEmpty) {
        _currentUser = users.first; // Get the first active user

        // Also update SharedPreferences for backward compatibility
        await _preferencesService!.setUserRecord(_currentUser!);
      } else {
        // Fallback to SharedPreferences for migration
        final userFromPrefs = _preferencesService!.getUserRecord();
        if (userFromPrefs != null) {
          // Migrate user from SharedPreferences to database
          await DatabaseService.instance.userDao.insert(userFromPrefs);
          _currentUser = userFromPrefs;
        }
      }
    } catch (e) {
      debugPrint('Error loading existing user: $e');
      _currentUser = null;
    }
  }

  /// Auto-detect currency from device locale
  Map<String, String> _detectCurrencyFromLocale() {
    try {
      // Get device locale
      final locale = Platform.localeName; // e.g., 'en_US'
      final parts = locale.split('_');
      final countryCode = parts.length > 1 ? parts[1].toUpperCase() : 'US';

      // Map common country codes to currencies
      final Map<String, Map<String, String>> countryToCurrency = {
        'US': {'code': 'USD', 'name': 'US Dollar'},
        'CA': {'code': 'CAD', 'name': 'Canadian Dollar'},
        'GB': {'code': 'GBP', 'name': 'British Pound'},
        'AU': {'code': 'AUD', 'name': 'Australian Dollar'},
        'NZ': {'code': 'NZD', 'name': 'New Zealand Dollar'},
        'IN': {'code': 'INR', 'name': 'Indian Rupee'},
        'JP': {'code': 'JPY', 'name': 'Japanese Yen'},
        'KR': {'code': 'KRW', 'name': 'South Korean Won'},
        'CN': {'code': 'CNY', 'name': 'Chinese Yuan'},
        'SG': {'code': 'SGD', 'name': 'Singapore Dollar'},
        'TH': {'code': 'THB', 'name': 'Thai Baht'},
        'ZA': {'code': 'ZAR', 'name': 'South African Rand'},
        'CH': {'code': 'CHF', 'name': 'Swiss Franc'},
        'SE': {'code': 'SEK', 'name': 'Swedish Krona'},
        'NO': {'code': 'NOK', 'name': 'Norwegian Krone'},
        'DK': {'code': 'DKK', 'name': 'Danish Krone'},
        'PL': {'code': 'PLN', 'name': 'Polish Zloty'},
        'CZ': {'code': 'CZK', 'name': 'Czech Koruna'},
        'HU': {'code': 'HUF', 'name': 'Hungarian Forint'},
        'RU': {'code': 'RUB', 'name': 'Russian Ruble'},
        'BR': {'code': 'BRL', 'name': 'Brazilian Real'},
        'MX': {'code': 'MXN', 'name': 'Mexican Peso'},
        'AE': {'code': 'AED', 'name': 'UAE Dirham'},
        'SA': {'code': 'SAR', 'name': 'Saudi Riyal'},
        'EG': {'code': 'EGP', 'name': 'Egyptian Pound'},
        'NG': {'code': 'NGN', 'name': 'Nigerian Naira'},
        'KE': {'code': 'KES', 'name': 'Kenyan Shilling'},
        'GH': {'code': 'GHS', 'name': 'Ghanaian Cedi'},
        'TR': {'code': 'TRY', 'name': 'Turkish Lira'},
        'AR': {'code': 'ARS', 'name': 'Argentine Peso'},
        'CL': {'code': 'CLP', 'name': 'Chilean Peso'},
        'CO': {'code': 'COP', 'name': 'Colombian Peso'},
        'PE': {'code': 'PEN', 'name': 'Peruvian Sol'},
        'HK': {'code': 'HKD', 'name': 'Hong Kong Dollar'},
        'TW': {'code': 'TWD', 'name': 'Taiwan Dollar'},
        'MY': {'code': 'MYR', 'name': 'Malaysian Ringgit'},
        'ID': {'code': 'IDR', 'name': 'Indonesian Rupiah'},
        'PH': {'code': 'PHP', 'name': 'Philippine Peso'},
        'VN': {'code': 'VND', 'name': 'Vietnamese Dong'},
        'PK': {'code': 'PKR', 'name': 'Pakistani Rupee'},
        'BD': {'code': 'BDT', 'name': 'Bangladeshi Taka'},
        'LK': {'code': 'LKR', 'name': 'Sri Lankan Rupee'},
        'NP': {'code': 'NPR', 'name': 'Nepalese Rupee'},
        'IL': {'code': 'ILS', 'name': 'Israeli Shekel'},
        'RO': {'code': 'RON', 'name': 'Romanian Leu'},
        'BG': {'code': 'BGN', 'name': 'Bulgarian Lev'},
        'HR': {'code': 'HRK', 'name': 'Croatian Kuna'},
        'IS': {'code': 'ISK', 'name': 'Icelandic Krona'},
        'UA': {'code': 'UAH', 'name': 'Ukrainian Hryvnia'},
      };

      // For EU countries, default to EUR
      final euCountries = [
        'DE',
        'FR',
        'IT',
        'ES',
        'NL',
        'BE',
        'AT',
        'PT',
        'IE',
        'FI',
        'GR',
        'LU',
        'SI',
        'SK',
        'EE',
        'LV',
        'LT',
        'CY',
        'MT',
      ];

      if (euCountries.contains(countryCode)) {
        return {'code': 'EUR', 'name': 'Euro'};
      }

      return countryToCurrency[countryCode] ??
          {'code': 'USD', 'name': 'US Dollar'};
    } catch (e) {
      // Fallback to USD if detection fails
      return {'code': 'USD', 'name': 'US Dollar'};
    }
  }

  /// Create a new user with default values
  /// Auto-detects currency from device locale
  Future<User> createUser({
    String email = '',
    String name = 'User',
    String profilePic = '',
    String? currencyCode,
    String? currencyName,
  }) async {
    if (!_isInitialized) {
      throw Exception('UserService not initialized. Call initialize() first.');
    }

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    // Auto-detect currency if not provided
    final detectedCurrency = _detectCurrencyFromLocale();
    final finalCurrencyCode = currencyCode ?? detectedCurrency['code']!;
    final finalCurrencyName = currencyName ?? detectedCurrency['name']!;

    final user = User(
      id: _uuid.v4(),
      createdAt: now,
      updatedAt: now,
      isActive: 1,
      email: email,
      name: name,
      profilePic: profilePic,
      currencyCode: finalCurrencyCode,
      currencyName: finalCurrencyName,
    );

    // Save the user
    await _saveUser(user);

    // Auto-create "Main Account" for the user
    try {
      await AccountService.instance.createAccount(
        name: defaultAccountName,
        description: defaultAccountDescription,
        createdBy: user.id,
      );
    } catch (e) {
      // Log error but don't fail user creation if account creation fails
      debugPrint('Failed to create Main Account for user: $e');
    }

    return user;
  }

  /// Save user to database and update current user
  Future<void> _saveUser(User user) async {
    try {
      // Save to database
      await DatabaseService.instance.userDao.upsert(user);

      // Also save to SharedPreferences for backward compatibility
      await _preferencesService!.setUserRecord(user);

      _currentUser = user;
    } catch (e) {
      throw Exception('Failed to save user: $e');
    }
  }

  /// Update the current user
  Future<User> updateUser({
    String? email,
    String? name,
    String? profilePic,
    int? isActive,
    String? currencyCode,
    String? currencyName,
  }) async {
    if (!_isInitialized) {
      throw Exception('UserService not initialized. Call initialize() first.');
    }

    if (_currentUser == null) {
      throw Exception('No user to update. Create a user first.');
    }

    final updatedUser = _currentUser!.copyWith(
      email: email,
      name: name,
      profilePic: profilePic,
      isActive: isActive,
      currencyCode: currencyCode,
      currencyName: currencyName,
      updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
    );

    await _saveUser(updatedUser);
    return updatedUser;
  }

  /// Update user timestamp
  Future<void> updateUserTimestamp() async {
    if (_currentUser != null) {
      final updatedUser = _currentUser!.updateTimestamp();
      await _saveUser(updatedUser);
    }
  }

  /// Delete the current user
  Future<void> deleteUser() async {
    if (!_isInitialized) {
      throw Exception('UserService not initialized. Call initialize() first.');
    }

    if (_currentUser == null) {
      return; // No user to delete
    }

    try {
      // Delete from database
      await DatabaseService.instance.userDao.delete(_currentUser!.id);

      // Also clear from SharedPreferences
      await _preferencesService!.clearUserRecord();

      _currentUser = null;
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Get user ID
  String? getUserId() {
    return _currentUser?.id;
  }

  /// Check if user is active
  bool isUserActive() {
    return _currentUser?.isUserActive ?? false;
  }

  /// Check if user has valid email
  bool hasValidEmail() {
    return _currentUser?.hasValidEmail ?? false;
  }

  /// Check if user has name
  bool hasUserName() {
    return _currentUser?.hasName ?? false;
  }

  /// Validate current user
  bool isCurrentUserValid() {
    return _currentUser?.isValid ?? false;
  }

  /// Get user's currency code
  String getUserCurrencyCode() {
    return _currentUser?.currencyCode ?? '';
  }

  /// Get user's currency name
  String getUserCurrencyName() {
    return _currentUser?.currencyName ?? '';
  }

  /// Check if user has currency set
  bool hasUserCurrency() {
    return _currentUser?.currencyCode.isNotEmpty ?? false;
  }

  /// Clear all user data (useful for testing or reset)
  Future<void> clearUserData() async {
    try {
      // Clear from database
      if (_isInitialized) {
        await DatabaseService.instance.userDao.clear();
      }

      // Clear from SharedPreferences
      await _preferencesService?.clearUserRecord();

      _currentUser = null;
      _isInitialized = false;
    } catch (e) {
      throw Exception('Failed to clear user data: $e');
    }
  }

  /// Refresh user data from database
  Future<void> refreshUser() async {
    if (_isInitialized) {
      await _loadExistingUser();
    }
  }
}
