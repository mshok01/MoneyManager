import 'package:uuid/uuid.dart';
import '../models/account.dart';
import 'user_service.dart';

class AccountService {
  static AccountService? _instance;
  static AccountService get instance {
    _instance ??= AccountService._();
    return _instance!;
  }

  AccountService._();

  List<Account> _accounts = [];
  bool _isInitialized = false;
  final Uuid _uuid = const Uuid();

  /// Get all accounts
  List<Account> get accounts => List.unmodifiable(_accounts);

  /// Get active accounts only
  List<Account> get activeAccounts =>
      _accounts.where((account) => account.isAccountActive).toList();

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Check if any accounts exist
  bool get hasAccounts => _accounts.isNotEmpty;

  /// Get account count
  int get accountCount => _accounts.length;

  /// Initialize the account service
  /// This should be called when the app starts
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load existing accounts if available
      await _loadExistingAccounts();

      _isInitialized = true;
    } catch (e) {
      // Log error but don't throw to prevent app crash
      print('AccountService initialization error: $e');
      _isInitialized = true; // Mark as initialized to prevent retry loops
    }
  }

  /// Load existing accounts from preferences
  Future<void> _loadExistingAccounts() async {
    try {
      // TODO: Implement loading accounts from preferences
      // This will be implemented when we add persistence
      _accounts = [];
    } catch (e) {
      print('Error loading existing accounts: $e');
      _accounts = [];
    }
  }

  /// Create a new account
  Future<Account> createAccount({
    required String name,
    String description = '',
    String pic = '',
    String? createdBy,
    List<String>? members,
    List<String>? admins,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'AccountService not initialized. Call initialize() first.',
      );
    }

    // Get current user ID if not provided
    final currentUserId = createdBy ?? UserService.instance.getUserId();
    if (currentUserId == null || currentUserId.isEmpty) {
      throw Exception(
        'No user found. User must be logged in to create account.',
      );
    }

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    // Ensure creator is in members list
    final accountMembers = List<String>.from(members ?? []);
    if (!accountMembers.contains(currentUserId)) {
      accountMembers.add(currentUserId);
    }

    // Ensure creator is in admins list
    final accountAdmins = List<String>.from(admins ?? []);
    if (!accountAdmins.contains(currentUserId)) {
      accountAdmins.add(currentUserId);
    }

    final account = Account(
      id: _uuid.v4(),
      name: name.trim(),
      description: description.trim(),
      pic: pic.trim(),
      createdAt: now,
      updatedAt: now,
      isActive: 1,
      createdBy: currentUserId,
      members: accountMembers,
      admins: accountAdmins,
    );

    // Validate account before saving
    if (!account.isValid) {
      throw Exception('Invalid account data');
    }

    // Add to local list
    _accounts.add(account);

    // TODO: Save to preferences
    await _saveAccounts();

    return account;
  }

  /// Update an existing account
  Future<Account> updateAccount(
    String accountId, {
    String? name,
    String? description,
    String? pic,
    int? isActive,
    List<String>? members,
    List<String>? admins,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'AccountService not initialized. Call initialize() first.',
      );
    }

    final accountIndex = _accounts.indexWhere(
      (account) => account.id == accountId,
    );
    if (accountIndex == -1) {
      throw Exception('Account not found');
    }

    final currentAccount = _accounts[accountIndex];
    final updatedAccount = currentAccount.copyWith(
      name: name,
      description: description,
      pic: pic,
      isActive: isActive,
      members: members,
      admins: admins,
      updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
    );

    // Validate updated account
    if (!updatedAccount.isValid) {
      throw Exception('Invalid account data');
    }

    // Update in local list
    _accounts[accountIndex] = updatedAccount;

    // TODO: Save to preferences
    await _saveAccounts();

    return updatedAccount;
  }

  /// Delete an account (mark as inactive)
  Future<void> deleteAccount(String accountId) async {
    if (!_isInitialized) {
      throw Exception(
        'AccountService not initialized. Call initialize() first.',
      );
    }

    final accountIndex = _accounts.indexWhere(
      (account) => account.id == accountId,
    );
    if (accountIndex == -1) {
      throw Exception('Account not found');
    }

    // Mark as inactive instead of removing
    _accounts[accountIndex] = _accounts[accountIndex].copyWith(
      isActive: 0,
      updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
    );

    // TODO: Save to preferences
    await _saveAccounts();
  }

  /// Get account by ID
  Account? getAccountById(String accountId) {
    try {
      return _accounts.firstWhere((account) => account.id == accountId);
    } catch (e) {
      return null;
    }
  }

  /// Get accounts where user is a member
  List<Account> getAccountsForUser(String userId) {
    return _accounts
        .where((account) => account.isMember(userId) && account.isAccountActive)
        .toList();
  }

  /// Get accounts where user is an admin
  List<Account> getAccountsWhereUserIsAdmin(String userId) {
    return _accounts
        .where((account) => account.isAdmin(userId) && account.isAccountActive)
        .toList();
  }

  /// Check if user can access account
  bool canUserAccessAccount(String userId, String accountId) {
    final account = getAccountById(accountId);
    return account?.isMember(userId) ?? false;
  }

  /// Check if user can manage account
  bool canUserManageAccount(String userId, String accountId) {
    final account = getAccountById(accountId);
    return account?.hasAdminPrivileges(userId) ?? false;
  }

  /// Add member to account
  Future<Account> addMemberToAccount(String accountId, String userId) async {
    final account = getAccountById(accountId);
    if (account == null) {
      throw Exception('Account not found');
    }

    final updatedAccount = account.addMember(userId);
    return await updateAccount(accountId, members: updatedAccount.members);
  }

  /// Remove member from account
  Future<Account> removeMemberFromAccount(
    String accountId,
    String userId,
  ) async {
    final account = getAccountById(accountId);
    if (account == null) {
      throw Exception('Account not found');
    }

    final updatedAccount = account.removeMember(userId);
    return await updateAccount(
      accountId,
      members: updatedAccount.members,
      admins: updatedAccount.admins,
    );
  }

  /// Save accounts to preferences (placeholder)
  Future<void> _saveAccounts() async {
    try {
      // TODO: Implement saving accounts to preferences
      // This will be implemented when we add persistence
    } catch (e) {
      throw Exception('Failed to save accounts: $e');
    }
  }

  /// Clear all account data (useful for testing or reset)
  Future<void> clearAccountData() async {
    try {
      // TODO: Clear accounts from preferences
      _accounts.clear();
      _isInitialized = false;
    } catch (e) {
      throw Exception('Failed to clear account data: $e');
    }
  }

  /// Refresh accounts from preferences
  Future<void> refreshAccounts() async {
    if (_isInitialized) {
      await _loadExistingAccounts();
    }
  }
}
