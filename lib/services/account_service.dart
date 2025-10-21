import 'package:flutter/foundation.dart';
import 'package:money_manager/utils/utils.dart';
import '../models/account.dart';
import 'user_service.dart';
import '../database/database_service.dart';

class AccountService {
  static AccountService? _instance;
  static AccountService get instance {
    _instance ??= AccountService._();
    return _instance!;
  }

  AccountService._();

  bool _isInitialized = false;

  /// Get all accounts
  Future<List<Account>> get accounts async =>
      await DatabaseService.instance.accountDao.getAll();

  /// Get active accounts only
  Future<List<Account>> get activeAccounts async =>
      await DatabaseService.instance.accountDao.getActiveAccounts();

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Check if any accounts exist
  Future<bool> get hasAccounts async =>
      (await DatabaseService.instance.accountDao.count()) > 0;

  /// Get account count
  Future<int> get accountCount async =>
      await DatabaseService.instance.accountDao.count();

  /// Initialize the account service
  /// This should be called when the app starts
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize database service
      await DatabaseService.instance.initialize();

      _isInitialized = true;
    } catch (e) {
      // Log error but don't throw to prevent app crash
      debugPrint('AccountService initialization error: $e');
      _isInitialized = true; // Mark as initialized to prevent retry loops
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
    String? baseCurrency,
    String? baseCurrencyName,
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

    // Get creator's currency as default for account
    final currentUser = UserService.instance.currentUser;
    final accountBaseCurrency =
        baseCurrency ?? currentUser?.currencyCode ?? 'USD';
    final accountBaseCurrencyName =
        baseCurrencyName ?? currentUser?.currencyName ?? 'US Dollar';

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
      id: getUniqueId(),
      name: name.trim(),
      description: description.trim(),
      pic: pic.trim(),
      createdAt: now,
      updatedAt: now,
      isActive: 1,
      createdBy: currentUserId,
      members: accountMembers,
      admins: accountAdmins,
      baseCurrency: accountBaseCurrency,
      baseCurrencyName: accountBaseCurrencyName,
    );

    // Validate account before saving
    if (!account.isValid) {
      throw Exception('Invalid account data');
    }

    // Save to database
    await DatabaseService.instance.accountDao.insert(account);

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
    String? baseCurrency,
    String? baseCurrencyName,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'AccountService not initialized. Call initialize() first.',
      );
    }

    final currentAccount = await DatabaseService.instance.accountDao.getById(
      accountId,
    );
    if (currentAccount == null) {
      throw Exception('Account not found');
    }

    final updatedAccount = currentAccount.copyWith(
      name: name,
      description: description,
      pic: pic,
      isActive: isActive,
      members: members,
      admins: admins,
      baseCurrency: baseCurrency,
      baseCurrencyName: baseCurrencyName,
      updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
    );

    // Validate updated account
    if (!updatedAccount.isValid) {
      throw Exception('Invalid account data');
    }

    // Update in database
    await DatabaseService.instance.accountDao.update(updatedAccount, accountId);

    return updatedAccount;
  }

  /// Save account received from backend API response
  /// Used after successful anonymous auth API call
  Future<void> saveAccountFromResponse(Account account) async {
    if (!_isInitialized) {
      throw Exception(
        'AccountService not initialized. Call initialize() first.',
      );
    }

    try {
      // Validate account before saving
      if (!account.isValid) {
        throw Exception('Invalid account data from API response');
      }

      // Save to database
      await DatabaseService.instance.accountDao.insert(account);
    } catch (e) {
      throw Exception('Failed to save account from API response: $e');
    }
  }

  /// Delete an account (mark as inactive)
  Future<void> deleteAccount(String accountId) async {
    if (!_isInitialized) {
      throw Exception(
        'AccountService not initialized. Call initialize() first.',
      );
    }

    // Mark as inactive instead of removing
    await DatabaseService.instance.accountDao.softDelete(accountId);
  }

  /// Get account by ID
  Future<Account?> getAccountById(String accountId) async {
    return await DatabaseService.instance.accountDao.getById(accountId);
  }

  /// Get accounts where user is a member
  Future<List<Account>> getAccountsForUser(String userId) async {
    return await DatabaseService.instance.accountDao.getAccountsForUser(userId);
  }

  /// Get accounts where user is an admin
  Future<List<Account>> getAccountsWhereUserIsAdmin(String userId) async {
    return await DatabaseService.instance.accountDao
        .getAccountsWhereUserIsAdmin(userId);
  }

  /// Check if user can access account
  Future<bool> canUserAccessAccount(String userId, String accountId) async {
    return await DatabaseService.instance.accountDao.canUserAccessAccount(
      userId,
      accountId,
    );
  }

  /// Check if user can manage account
  Future<bool> canUserManageAccount(String userId, String accountId) async {
    return await DatabaseService.instance.accountDao.isUserAdmin(
      userId,
      accountId,
    );
  }

  /// Add member to account
  Future<Account> addMemberToAccount(String accountId, String userId) async {
    await DatabaseService.instance.accountDao.addMember(accountId, userId);
    final account = await getAccountById(accountId);
    if (account == null) {
      throw Exception('Account not found after update');
    }
    return account;
  }

  /// Remove member from account
  Future<Account> removeMemberFromAccount(
    String accountId,
    String userId,
  ) async {
    await DatabaseService.instance.accountDao.removeMember(accountId, userId);
    final account = await getAccountById(accountId);
    if (account == null) {
      throw Exception('Account not found after update');
    }
    return account;
  }

  /// Clear all account data (useful for testing or reset)
  Future<void> clearAccountData() async {
    try {
      if (_isInitialized) {
        await DatabaseService.instance.accountDao.clear();
      }
      _isInitialized = false;
    } catch (e) {
      throw Exception('Failed to clear account data: $e');
    }
  }

  /// Refresh accounts (no-op since we always fetch from database)
  Future<void> refreshAccounts() async {
    // No-op since we always fetch fresh data from database
  }
}
