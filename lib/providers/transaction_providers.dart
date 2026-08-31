import 'package:money_manager/models/transaction_summary.dart';
import 'package:riverpod/riverpod.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';

/// Provider for TransactionService singleton
final transactionServiceProvider = Provider<TransactionService>((ref) {
  return TransactionService.instance;
});

/// Provider to fetch all transactions for a specific account
/// Usage: ref.watch(accountTransactionsProvider(accountId))
final accountTransactionsProvider =
    FutureProvider.family<List<Transaction>, String>((ref, accountId) async {
      final transactionService = ref.watch(transactionServiceProvider);
      return transactionService.getAccountTransactions(accountId);
    });

/// Provider to fetch recent transactions for a specific account
/// Usage: ref.watch(recentAccountTransactionsProvider((accountId, limit: 10)))
final recentAccountTransactionsProvider =
    FutureProvider.family<List<Transaction>, ({String accountId, int limit})>((
      ref,
      params,
    ) async {
      final transactionService = ref.watch(transactionServiceProvider);
      return transactionService.getRecentAccountTransactions(
        params.accountId,
        limit: params.limit,
      );
    });

/// Provider to fetch transactions for a specific month
/// Usage: ref.watch(monthTransactionsProvider((accountId: id, year: 2024, month: 10)))
final monthTransactionsProvider =
    FutureProvider.family<
      List<Transaction>,
      ({String accountId, int year, int month})
    >((ref, params) async {
      final transactionService = ref.watch(transactionServiceProvider);
      return transactionService.getMonthTransactions(
        params.accountId,
        params.year,
        params.month,
      );
    });

/// Provider to fetch transactions for a specific day
/// Usage: ref.watch(dayTransactionsProvider((accountId: id, year: 2024, month: 10, day: 22)))
final dayTransactionsProvider =
    FutureProvider.family<
      List<Transaction>,
      ({String accountId, int year, int month, int day})
    >((ref, params) async {
      final transactionService = ref.watch(transactionServiceProvider);
      return transactionService.getDayTransactions(
        params.accountId,
        params.year,
        params.month,
        params.day,
      );
    });

/// Provider to fetch account balance
/// Usage: ref.watch(accountBalanceProvider(accountId))
final accountBalanceProvider = FutureProvider.family<double, String>((
  ref,
  accountId,
) async {
  final transactionService = ref.watch(transactionServiceProvider);
  return transactionService.getAccountBalance(accountId);
});

/// Provider to create a new transaction
/// This is a method provider - call it to create a transaction
final createTransactionProvider =
    FutureProvider.family<
      Transaction,
      ({
        String accountId,
        String categoryId,
        String paymentSourceId,
        double amount,
        String type,
        String description,
        DateTime? transactionDate,
        String? createdBy,
      })
    >((ref, params) async {
      final transactionService = ref.watch(transactionServiceProvider);
      final transaction = await transactionService.createTransaction(
        accountId: params.accountId,
        categoryId: params.categoryId,
        paymentSourceId: params.paymentSourceId,
        amount: params.amount,
        type: params.type,
        description: params.description,
        transactionDate: params.transactionDate,
        createdBy: params.createdBy,
      );

      // Invalidate related providers to refresh data
      ref.invalidate(accountTransactionsProvider(params.accountId));
      ref.invalidate(accountBalanceProvider(params.accountId));

      return transaction;
    });

/// Provider to update an existing transaction
final updateTransactionProvider =
    FutureProvider.family<
      void,
      ({
        String transactionId,
        String accountId,
        String? categoryId,
        String? paymentSourceId,
        double? amount,
        String? type,
        String? description,
        DateTime? transactionDate,
      })
    >((ref, params) async {
      final transactionService = ref.watch(transactionServiceProvider);
      await transactionService.updateTransaction(
        params.transactionId,
        accountId: params.accountId,
        categoryId: params.categoryId,
        paymentSourceId: params.paymentSourceId,
        amount: params.amount,
        type: params.type,
        description: params.description,
        transactionDate: params.transactionDate,
      );

      // Invalidate related providers to refresh data
      ref.invalidate(accountTransactionsProvider(params.accountId));
      ref.invalidate(accountBalanceProvider(params.accountId));
    });

/// Provider to delete a transaction
final deleteTransactionProvider =
    FutureProvider.family<void, ({String transactionId, String accountId})>((
      ref,
      params,
    ) async {
      final transactionService = ref.watch(transactionServiceProvider);
      await transactionService.deleteTransaction(params.transactionId);

      // Invalidate related providers to refresh data
      ref.invalidate(accountTransactionsProvider(params.accountId));
      ref.invalidate(accountBalanceProvider(params.accountId));
    });

/// Provider to get all transactions for an account (for search)
/// Usage: ref.watch(allAccountTransactionsProvider(accountId))
final allAccountTransactionsProvider =
    FutureProvider.family<List<Transaction>, String>((ref, accountId) async {
      final transactionService = ref.watch(transactionServiceProvider);
      return transactionService.getAccountTransactions(accountId);
    });

/// Provider to check if an account has any transactions
/// Usage: ref.watch(accountHasTransactionsProvider(accountId))
final accountHasTransactionsProvider = FutureProvider.family<bool, String>((
  ref,
  accountId,
) async {
  final transactionService = ref.watch(transactionServiceProvider);
  return transactionService.hasTransactions(accountId);
});

/// Provider to get transaction summary for a specific period
/// Usage: ref.watch(transactionSummaryProvider((accountId: id, period: 'today'/'month'/'year')))
final transactionSummaryProvider =
    FutureProvider.family<
      TransactionSummary,
      ({String accountId, String period})
    >((ref, params) async {
      final transactionService = ref.watch(transactionServiceProvider);
      switch (params.period) {
        case 'today':
          return transactionService.getTodaySummary(params.accountId);
        case 'month':
          return transactionService.getThisMonthSummary(params.accountId);
        case 'year':
          return transactionService.getThisYearSummary(params.accountId);
        default:
          throw Exception('Invalid period: ${params.period}');
      }
    });
