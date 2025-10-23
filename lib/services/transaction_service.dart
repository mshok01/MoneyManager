import 'package:money_manager/utils/utils.dart';
import '../database/database_service.dart';
import '../models/transaction.dart';
import '../models/sync_queue_entry.dart';
import '../models/transaction_summary.dart';
import '../models/monthly_summary.dart';
import '../models/daily_summary.dart';
import '../models/user.dart';
import '../utils/user_utils.dart';
import 'user_service.dart';
import 'account_service.dart';
import 'transaction_api_service.dart';
import 'sync_service.dart';

/// Service for managing transactions with business logic and currency conversion
class TransactionService {
  static TransactionService? _instance;
  static TransactionService get instance {
    _instance ??= TransactionService._();
    return _instance!;
  }

  TransactionService._();

  bool _isInitialized = false;

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Ensure database service is initialized
      if (!DatabaseService.instance.isInitialized) {
        await DatabaseService.instance.initialize();
      }

      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  /// Create a new transaction
  Future<Transaction> createTransaction({
    required String accountId,
    required String categoryId,
    required String paymentSourceId,
    required double amount,
    required String type,
    String description = '',
    DateTime? transactionDate,
    String? createdBy,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'TransactionService not initialized. Call initialize() first.',
      );
    }

    // Validate transaction type
    if (!TransactionType.isValid(type)) {
      throw Exception('Invalid transaction type: $type');
    }

    // Validate amount
    if (amount <= 0) {
      throw Exception('Transaction amount must be greater than 0');
    }

    // Get current user ID if not provided
    final currentUserId = createdBy ?? UserService.instance.getUserId();
    if (currentUserId == null || currentUserId.isEmpty) {
      throw Exception(
        'No user found. User must be logged in to create transaction.',
      );
    }

    // Verify account exists and user has access
    final account = await AccountService.instance.getAccountById(accountId);
    if (account == null) {
      throw Exception('Account not found');
    }

    if (!account.isMember(currentUserId)) {
      throw Exception('User does not have access to this account');
    }

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final txnDate = transactionDate?.toUtc().millisecondsSinceEpoch ?? now;

    final transaction = Transaction(
      id: getUniqueId(),
      accountId: accountId,
      categoryId: categoryId,
      paymentSourceId: paymentSourceId,
      amount: amount,
      description: description.trim(),
      type: type,
      transactionDate: txnDate,
      createdAt: now,
      updatedAt: now,
      isActive: 1,
      createdBy: currentUserId,
    );

    // Validate transaction before saving
    if (!transaction.isValid) {
      throw Exception('Invalid transaction data');
    }

    // Save to database
    await DatabaseService.instance.transactionDao.insert(transaction);

    // Call backend API asynchronously (don't wait for response)
    // This allows the UI to respond immediately while the API call happens in the background
    _syncTransactionAsync(
      transactionId: transaction.id,
      operation: SyncOperation.create,
      syncFn: () => TransactionApiService.instance.addTransaction(
        transaction: transaction,
      ),
    );

    return transaction;
  }

  /// Update an existing transaction
  Future<Transaction> updateTransaction(
    String transactionId, {
    String? accountId,
    String? categoryId,
    String? paymentSourceId,
    double? amount,
    String? type,
    String? description,
    DateTime? transactionDate,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'TransactionService not initialized. Call initialize() first.',
      );
    }

    final currentTransaction = await DatabaseService.instance.transactionDao
        .getById(transactionId);
    if (currentTransaction == null) {
      throw Exception('Transaction not found');
    }

    // Verify user has permission to update
    final currentUserId = UserService.instance.getUserId();
    if (currentUserId == null ||
        currentUserId != currentTransaction.createdBy) {
      throw Exception(
        'User does not have permission to update this transaction',
      );
    }

    // Validate new type if provided
    if (type != null && !TransactionType.isValid(type)) {
      throw Exception('Invalid transaction type: $type');
    }

    // Validate new amount if provided
    if (amount != null && amount <= 0) {
      throw Exception('Transaction amount must be greater than 0');
    }

    final updatedTransaction = currentTransaction
        .copyWith(
          accountId: accountId,
          categoryId: categoryId,
          paymentSourceId: paymentSourceId,
          amount: amount,
          type: type,
          description: description,
          transactionDate: transactionDate?.toUtc().millisecondsSinceEpoch,
        )
        .updateTimestamp();

    // Validate updated transaction
    if (!updatedTransaction.isValid) {
      throw Exception('Invalid transaction data');
    }

    // Update in database
    await DatabaseService.instance.transactionDao.update(
      updatedTransaction,
      transactionId,
    );

    // Call backend API asynchronously (don't wait for response)
    // This allows the UI to respond immediately while the API call happens in the background
    _syncTransactionAsync(
      transactionId: transactionId,
      operation: SyncOperation.update,
      syncFn: () => TransactionApiService.instance.updateTransaction(
        transactionId: transactionId,
        transaction: updatedTransaction,
      ),
    );

    return updatedTransaction;
  }

  /// Delete a transaction (soft delete)
  Future<void> deleteTransaction(String transactionId) async {
    if (!_isInitialized) {
      throw Exception(
        'TransactionService not initialized. Call initialize() first.',
      );
    }

    final transaction = await DatabaseService.instance.transactionDao.getById(
      transactionId,
    );
    if (transaction == null) {
      throw Exception('Transaction not found');
    }

    // Verify user has permission to delete
    final currentUserId = UserService.instance.getUserId();
    if (currentUserId == null || currentUserId != transaction.createdBy) {
      throw Exception(
        'User does not have permission to delete this transaction',
      );
    }

    // Soft delete
    await DatabaseService.instance.transactionDao.softDelete(transactionId);

    // Call backend API asynchronously (don't wait for response)
    // This allows the UI to respond immediately while the API call happens in the background
    _syncTransactionAsync(
      transactionId: transactionId,
      operation: SyncOperation.delete,
      syncFn: () => TransactionApiService.instance.deleteTransaction(
        transactionId: transactionId,
        createdBy: transaction.createdBy,
      ),
    );
  }

  /// Get transaction by ID
  Future<Transaction?> getTransactionById(String transactionId) async {
    return await DatabaseService.instance.transactionDao.getById(transactionId);
  }

  /// Get all transactions for an account
  Future<List<Transaction>> getAccountTransactions(String accountId) async {
    return await DatabaseService.instance.transactionDao.getByAccountId(
      accountId,
    );
  }

  /// Get recent transactions for an account
  Future<List<Transaction>> getRecentAccountTransactions(
    String accountId, {
    int limit = 10,
  }) async {
    return await DatabaseService.instance.transactionDao.getRecentForAccount(
      accountId,
      limit,
    );
  }

  /// Get account balance
  Future<double> getAccountBalance(String accountId) async {
    return await DatabaseService.instance.transactionDao.getAccountBalance(
      accountId,
    );
  }

  /// Get account income total
  Future<double> getAccountIncome(String accountId) async {
    return await DatabaseService.instance.transactionDao.getAccountIncome(
      accountId,
    );
  }

  /// Get account expenses total
  Future<double> getAccountExpenses(String accountId) async {
    return await DatabaseService.instance.transactionDao.getAccountExpenses(
      accountId,
    );
  }

  /// Get transactions by date range
  Future<List<Transaction>> getTransactionsByDateRange(
    int startDate,
    int endDate,
  ) async {
    return await DatabaseService.instance.transactionDao.getByDateRange(
      startDate,
      endDate,
    );
  }

  /// Search transactions by description
  Future<List<Transaction>> searchTransactions(String query) async {
    return await DatabaseService.instance.transactionDao.searchByDescription(
      query,
    );
  }

  /// Convert amount from account currency to user's preferred currency
  /// For now, this is a placeholder - in the future, this would use exchange rates
  Future<double> convertToUserCurrency(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) async {
    // For now, return the same amount since we're storing in account currency
    // In the future, implement actual currency conversion here
    if (fromCurrency == toCurrency) {
      return amount;
    }

    // Placeholder conversion - in real implementation, fetch exchange rates
    // For demo purposes, using some basic conversions
    if (fromCurrency == 'USD' && toCurrency == 'INR') {
      return amount * 83.0; // Approximate USD to INR
    } else if (fromCurrency == 'INR' && toCurrency == 'USD') {
      return amount / 83.0; // Approximate INR to USD
    }

    // Default: return same amount
    return amount;
  }

  /// Format amount for display in user's currency
  Future<String> formatAmountForUser(
    double amount,
    String accountCurrency,
    User? user,
  ) async {
    if (user == null) return amount.toStringAsFixed(2);

    final userCurrency = user.currencyCode;
    if (userCurrency.isEmpty || userCurrency == accountCurrency) {
      return amount.toStringAsFixed(2);
    }

    final convertedAmount = await convertToUserCurrency(
      amount,
      accountCurrency,
      userCurrency,
    );
    return convertedAmount.toStringAsFixed(2);
  }

  /// Get transaction summary for account and date range
  Future<TransactionSummary> getTransactionSummary(
    String accountId,
    int startDate,
    int endDate,
  ) async {
    final transactions = await DatabaseService.instance.transactionDao
        .getByAccountAndDateRange(accountId, startDate, endDate);

    double totalIncome = 0.0;
    double totalExpenses = 0.0;

    for (final transaction in transactions) {
      if (transaction.isIncome) {
        totalIncome += transaction.amount;
      } else if (transaction.isExpense) {
        totalExpenses += transaction.amount;
      }
    }

    final balance = totalIncome - totalExpenses;

    return TransactionSummary(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      balance: balance,
      transactionCount: transactions.length,
    );
  }

  /// Get transaction summary for today
  Future<TransactionSummary> getTodaySummary(String accountId) async {
    final dateRange = UserUtils.getTodayDateRange();
    return await getTransactionSummary(
      accountId,
      dateRange['start']!,
      dateRange['end']!,
    );
  }

  /// Get transaction summary for this week
  Future<TransactionSummary> getThisWeekSummary(String accountId) async {
    final dateRange = UserUtils.getThisWeekDateRange();
    return await getTransactionSummary(
      accountId,
      dateRange['start']!,
      dateRange['end']!,
    );
  }

  /// Get transaction summary for this month
  Future<TransactionSummary> getThisMonthSummary(String accountId) async {
    final dateRange = UserUtils.getThisMonthDateRange();
    return await getTransactionSummary(
      accountId,
      dateRange['start']!,
      dateRange['end']!,
    );
  }

  /// Get transaction summary for this year
  Future<TransactionSummary> getThisYearSummary(String accountId) async {
    final dateRange = UserUtils.getThisYearDateRange();
    return await getTransactionSummary(
      accountId,
      dateRange['start']!,
      dateRange['end']!,
    );
  }

  /// Get transactions by account and date range
  Future<List<Transaction>> getAccountTransactionsByDateRange(
    String accountId,
    int startDate,
    int endDate,
  ) async {
    return await DatabaseService.instance.transactionDao
        .getByAccountAndDateRange(accountId, startDate, endDate);
  }

  /// Check if account has any transactions
  Future<bool> hasTransactions(String accountId) async {
    final transactions = await getRecentAccountTransactions(
      accountId,
      limit: 1,
    );
    return transactions.isNotEmpty;
  }

  /// Get monthly summaries for a specific year
  Future<List<MonthlySummary>> getYearlyMonthlySummaries(
    String accountId,
    int year,
  ) async {
    final monthlySummaries = <MonthlySummary>[];

    // Generate summaries for all 12 months
    for (int month = 1; month <= 12; month++) {
      final monthSummary = await getMonthlySummary(accountId, year, month);
      monthlySummaries.add(monthSummary);
    }

    return monthlySummaries;
  }

  /// Get monthly summary for a specific month and year
  Future<MonthlySummary> getMonthlySummary(
    String accountId,
    int year,
    int month,
  ) async {
    final dateRange = _getMonthDateRange(year, month);
    final transactions = await DatabaseService.instance.transactionDao
        .getByAccountAndDateRange(
          accountId,
          dateRange['start']!,
          dateRange['end']!,
        );

    double totalIncome = 0.0;
    double totalExpenses = 0.0;

    for (final transaction in transactions) {
      if (transaction.isIncome) {
        totalIncome += transaction.amount;
      } else if (transaction.isExpense) {
        totalExpenses += transaction.amount;
      }
    }

    final balance = totalIncome - totalExpenses;

    return MonthlySummary(
      year: year,
      month: month,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      balance: balance,
      transactionCount: transactions.length,
    );
  }

  /// Get date range for a specific month in UTC milliseconds
  Map<String, int> _getMonthDateRange(int year, int month) {
    final startOfMonth = DateTime(year, month, 1).toUtc();
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59, 999).toUtc();

    return {
      'start': startOfMonth.millisecondsSinceEpoch,
      'end': endOfMonth.millisecondsSinceEpoch,
    };
  }

  /// Get transactions for a specific month
  Future<List<Transaction>> getMonthTransactions(
    String accountId,
    int year,
    int month,
  ) async {
    final dateRange = _getMonthDateRange(year, month);
    return await DatabaseService.instance.transactionDao
        .getByAccountAndDateRange(
          accountId,
          dateRange['start']!,
          dateRange['end']!,
        );
  }

  /// Get available years that have transactions for an account
  Future<List<int>> getAvailableYears(String accountId) async {
    final transactions = await getAccountTransactions(accountId);

    if (transactions.isEmpty) {
      return [DateTime.now().year]; // Return current year if no transactions
    }

    final years = <int>{};
    for (final transaction in transactions) {
      final transactionDate = transaction.transactionDateTime;
      years.add(transactionDate.year);
    }

    final sortedYears = years.toList()
      ..sort((a, b) => b.compareTo(a)); // Newest first
    return sortedYears;
  }

  /// Get daily summaries for a specific month
  Future<List<DailySummary>> getMonthlyDailySummaries(
    String accountId,
    int year,
    int month,
  ) async {
    final dailySummaries = <DailySummary>[];

    // Get the number of days in the month
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // Generate summaries for all days in the month
    for (int day = 1; day <= daysInMonth; day++) {
      final dailySummary = await getDailySummary(accountId, year, month, day);
      dailySummaries.add(dailySummary);
    }

    return dailySummaries;
  }

  /// Get daily summary for a specific day
  Future<DailySummary> getDailySummary(
    String accountId,
    int year,
    int month,
    int day,
  ) async {
    final dateRange = _getDayDateRange(year, month, day);

    final transactions = await DatabaseService.instance.transactionDao
        .getByAccountAndDateRange(
          accountId,
          dateRange['start']!,
          dateRange['end']!,
        );

    double totalIncome = 0;
    double totalExpenses = 0;

    for (final transaction in transactions) {
      if (transaction.isIncome) {
        totalIncome += transaction.amount;
      } else {
        totalExpenses += transaction.amount;
      }
    }

    final balance = totalIncome - totalExpenses;

    return DailySummary(
      year: year,
      month: month,
      day: day,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      balance: balance,
      transactionCount: transactions.length,
    );
  }

  /// Helper method to get date range for a specific day
  Map<String, int> _getDayDateRange(int year, int month, int day) {
    final startOfDay = DateTime(year, month, day).toUtc();
    final endOfDay = DateTime(year, month, day, 23, 59, 59, 999).toUtc();

    return {
      'start': startOfDay.millisecondsSinceEpoch,
      'end': endOfDay.millisecondsSinceEpoch,
    };
  }

  /// Get transactions for a specific day
  Future<List<Transaction>> getDayTransactions(
    String accountId,
    int year,
    int month,
    int day,
  ) async {
    final dateRange = _getDayDateRange(year, month, day);
    return await DatabaseService.instance.transactionDao
        .getByAccountAndDateRange(
          accountId,
          dateRange['start']!,
          dateRange['end']!,
        );
  }

  /// Clear all transaction data (useful for logout or reset)
  Future<void> clearAllTransactions() async {
    if (!_isInitialized) {
      throw Exception(
        'TransactionService not initialized. Call initialize() first.',
      );
    }

    try {
      await DatabaseService.instance.transactionDao.clear();
    } catch (e) {
      throw Exception('Failed to clear all transactions: $e');
    }
  }

  /// Helper method to sync transaction asynchronously
  /// Attempts to sync, and adds to queue if it fails
  void _syncTransactionAsync({
    required String transactionId,
    required String operation,
    required Future<void> Function() syncFn,
  }) {
    // Fire and forget - don't block the caller
    Future.microtask(() async {
      try {
        await syncFn();
      } catch (e) {
        // Add to sync queue on failure
        await SyncService.instance.addToSyncQueue(
          transactionId: transactionId,
          operation: operation,
          lastError: e.toString(),
        );
      }
    });
  }
}
