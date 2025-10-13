import 'package:uuid/uuid.dart';
import '../models/user.dart';
import 'preferences_service.dart';

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

      // Load existing user if available
      await _loadExistingUser();

      _isInitialized = true;
    } catch (e) {
      // Log error but don't throw to prevent app crash
      print('UserService initialization error: $e');
      _isInitialized = true; // Mark as initialized to prevent retry loops
    }
  }

  /// Load existing user from preferences
  Future<void> _loadExistingUser() async {
    try {
      _currentUser = _preferencesService!.getUserRecord();
    } catch (e) {
      print('Error loading existing user: $e');
      _currentUser = null;
    }
  }

  /// Create a new user with default values
  /// For now, we create an anonymous user that can be updated later
  Future<User> createUser({
    String email = '',
    String name = 'User',
    String profilePic = '',
  }) async {
    if (!_isInitialized) {
      throw Exception('UserService not initialized. Call initialize() first.');
    }

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    final user = User(
      id: _uuid.v4(),
      createdAt: now,
      updatedAt: now,
      isActive: 1,
      email: email,
      name: name,
      profilePic: profilePic,
    );

    // Save the user
    await _saveUser(user);

    return user;
  }

  /// Save user to preferences and update current user
  Future<void> _saveUser(User user) async {
    try {
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

    try {
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

  /// Clear all user data (useful for testing or reset)
  Future<void> clearUserData() async {
    try {
      await _preferencesService?.clearUserRecord();
      _currentUser = null;
      _isInitialized = false;
    } catch (e) {
      throw Exception('Failed to clear user data: $e');
    }
  }

  /// Refresh user data from preferences
  Future<void> refreshUser() async {
    if (_isInitialized) {
      await _loadExistingUser();
    }
  }
}
