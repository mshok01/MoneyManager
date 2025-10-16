import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../models/category_item.dart';
import '../models/payment_source.dart';
import '../models/transaction_summary.dart';
import '../models/monthly_summary.dart';
import '../models/daily_summary.dart';
import '../services/transaction_service.dart';
import '../services/category_service.dart';
import '../services/payment_source_service.dart';
import '../services/user_service.dart';
import '../utils/currency_utils.dart';
import '../l10n/app_localizations.dart';

import 'add_edit_transaction_screen.dart';
import 'transaction_list_screen.dart';
import 'transaction_details_screen.dart';
import 'monthly_transactions_screen.dart';
import 'daily_transactions_screen.dart';
import 'search_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final Account account;
  final String periodType; // 'today', 'month', 'year'
  final String periodTitle; // 'Today', 'This Month', 'This Year'
  final Map<String, int> dateRange; // start and end timestamps

  const TransactionHistoryScreen({
    super.key,
    required this.account,
    required this.periodType,
    required this.periodTitle,
    required this.dateRange,
  });

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  List<MonthlySummary> _monthlySummaries = [];
  List<MonthlySummary> _filteredMonthlySummaries = [];
  List<DailySummary> _dailySummaries = [];
  List<DailySummary> _filteredDailySummaries = [];
  Map<String, CategoryItem> _categoriesMap = {};
  Map<String, PaymentSource> _paymentSourcesMap = {};
  TransactionSummary? _summary;

  bool _isLoading = true;
  String _filterType = 'all'; // 'all', 'income', 'expense'
  bool _hasChanges = false; // Track if any transactions were modified

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      if (widget.periodType == 'year') {
        // For yearly view, load monthly summaries
        final year = DateTime.fromMillisecondsSinceEpoch(
          widget.dateRange['start']!,
        ).year;
        final monthlySummaries = await TransactionService.instance
            .getYearlyMonthlySummaries(widget.account.id, year);

        // Load summary for the year
        final summary = await TransactionService.instance.getTransactionSummary(
          widget.account.id,
          widget.dateRange['start']!,
          widget.dateRange['end']!,
        );

        setState(() {
          _monthlySummaries = monthlySummaries;
          _summary = summary;
          _isLoading = false;
          _applyFilters();
        });
      } else if (widget.periodType == 'month') {
        // For monthly view, load daily summaries
        final startDate = DateTime.fromMillisecondsSinceEpoch(
          widget.dateRange['start']!,
        );
        final dailySummaries = await TransactionService.instance
            .getMonthlyDailySummaries(
              widget.account.id,
              startDate.year,
              startDate.month,
            );

        // Load summary for the month
        final summary = await TransactionService.instance.getTransactionSummary(
          widget.account.id,
          widget.dateRange['start']!,
          widget.dateRange['end']!,
        );

        setState(() {
          _dailySummaries = dailySummaries;
          _summary = summary;
          _isLoading = false;
          _applyFilters();
        });
      } else {
        // For daily/monthly view, load individual transactions
        final transactions = await TransactionService.instance
            .getAccountTransactionsByDateRange(
              widget.account.id,
              widget.dateRange['start']!,
              widget.dateRange['end']!,
            );

        // Load summary for the period
        final summary = await TransactionService.instance.getTransactionSummary(
          widget.account.id,
          widget.dateRange['start']!,
          widget.dateRange['end']!,
        );

        // Load categories and payment sources for display
        final incomeCategories = await CategoryService.instance
            .getIncomeCategories();
        final expenseCategories = await CategoryService.instance
            .getExpenseCategories();
        final paymentSources = await PaymentSourceService.instance
            .getAllPaymentSources();

        // Create lookup maps
        final categoriesMap = <String, CategoryItem>{};
        for (final category in [...incomeCategories, ...expenseCategories]) {
          categoriesMap[category.id] = category;
        }

        final paymentSourcesMap = <String, PaymentSource>{};
        for (final source in paymentSources) {
          paymentSourcesMap[source.id] = source;
        }

        setState(() {
          _transactions = transactions;
          _summary = summary;
          _categoriesMap = categoriesMap;
          _paymentSourcesMap = paymentSourcesMap;
          _isLoading = false;
          _applyFilters();
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToLoadData(e.toString()))),
        );
      }
    }
  }

  void _applyFilters() {
    if (widget.periodType == 'year') {
      // Filter monthly summaries
      List<MonthlySummary> filteredSummaries = _monthlySummaries;

      // Apply type filter for monthly summaries
      if (_filterType == 'income') {
        filteredSummaries = filteredSummaries
            .where((s) => s.totalIncome > 0)
            .toList();
      } else if (_filterType == 'expense') {
        filteredSummaries = filteredSummaries
            .where((s) => s.totalExpenses > 0)
            .toList();
      }

      setState(() {
        _filteredMonthlySummaries = filteredSummaries;
      });
    } else if (widget.periodType == 'month') {
      // Filter daily summaries
      List<DailySummary> filteredSummaries = _dailySummaries;

      // Apply type filter for daily summaries
      if (_filterType == 'income') {
        filteredSummaries = filteredSummaries
            .where((s) => s.totalIncome > 0)
            .toList();
      } else if (_filterType == 'expense') {
        filteredSummaries = filteredSummaries
            .where((s) => s.totalExpenses > 0)
            .toList();
      }

      // Sort by day (newest first)
      filteredSummaries.sort((a, b) => b.day.compareTo(a.day));

      setState(() {
        _filteredDailySummaries = filteredSummaries;
      });
    } else {
      // Filter individual transactions
      List<Transaction> filtered = _transactions;

      // Apply type filter
      if (_filterType != 'all') {
        filtered = filtered.where((t) => t.type == _filterType).toList();
      }

      // Sort by date (newest first)
      filtered.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

      setState(() {
        _filteredTransactions = filtered;
      });
    }
  }

  Future<void> _openSearchScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchScreen(account: widget.account),
      ),
    );
  }

  Future<void> _addTransaction() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddEditTransactionScreen(account: widget.account),
      ),
    );

    if (result == true) {
      _hasChanges = true; // Mark that changes were made
      _loadData(); // Reload data if transaction was added
    }
  }

  Future<void> _navigateToTransactionDetails(Transaction transaction) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => TransactionDetailsScreen(
          transaction: transaction,
          account: widget.account,
        ),
      ),
    );

    // If transaction was edited or deleted, reload the data
    if (result == true) {
      _hasChanges = true; // Mark that changes were made
      _loadData();
    }
  }

  void _showTransactionOptions(Transaction transaction) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.editTransaction),
              onTap: () {
                Navigator.of(context).pop();
                _editTransaction(transaction);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                l10n.deleteTransaction,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _deleteTransaction(transaction);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editTransaction(Transaction transaction) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddEditTransactionScreen(
          account: widget.account,
          transaction: transaction,
        ),
      ),
    );

    if (result == true) {
      _hasChanges = true; // Mark that changes were made
      _loadData(); // Reload data if transaction was updated
    }
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTransaction),
        content: Text(l10n.deleteTransactionConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await TransactionService.instance.deleteTransaction(transaction.id);
        _hasChanges = true; // Mark that changes were made
        _loadData(); // Reload data after deletion
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.transactionDeletedSuccessfully)),
          );
        }
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.failedToDeleteTransaction(e.toString())),
            ),
          );
        }
      }
    }
  }

  void _viewAllTransactions() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransactionListScreen(account: widget.account),
      ),
    );
  }

  String _formatAmount(double amount) {
    final currentUser = UserService.instance.currentUser;
    final userCurrency =
        currentUser?.currencyCode ?? widget.account.baseCurrency;
    final currencySymbol = CurrencyUtils.getCurrencySymbol(userCurrency);

    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDateRangeText() {
    final startDate = DateTime.fromMillisecondsSinceEpoch(
      widget.dateRange['start']!,
      isUtc: true,
    ).toLocal();
    final endDate = DateTime.fromMillisecondsSinceEpoch(
      widget.dateRange['end']!,
      isUtc: true,
    ).toLocal();

    if (widget.periodType == 'today') {
      return _formatDate(startDate);
    } else if (widget.periodType == 'month') {
      return '${startDate.month}/${startDate.year}';
    } else if (widget.periodType == 'year') {
      return '${startDate.year}';
    } else {
      return '${_formatDate(startDate)} - ${_formatDate(endDate)}';
    }
  }

  bool _canNavigateToNext() {
    final now = DateTime.now();
    final currentDate = DateTime.fromMillisecondsSinceEpoch(
      widget.dateRange['start']!,
      isUtc: true,
    ).toLocal();

    if (widget.periodType == 'today') {
      // Can navigate to next day only if current date is before today
      return currentDate.isBefore(DateTime(now.year, now.month, now.day));
    } else if (widget.periodType == 'month') {
      // Can navigate to next month only if current month is before this month
      return currentDate.isBefore(DateTime(now.year, now.month, 1));
    } else if (widget.periodType == 'year') {
      // Can navigate to next year only if current year is before this year
      return currentDate.year < now.year;
    }
    return false;
  }

  void _navigateToPreviousDate() {
    final currentDate = DateTime.fromMillisecondsSinceEpoch(
      widget.dateRange['start']!,
      isUtc: true,
    ).toLocal();

    DateTime newDate;
    if (widget.periodType == 'today') {
      newDate = currentDate.subtract(const Duration(days: 1));
    } else if (widget.periodType == 'month') {
      newDate = DateTime(currentDate.year, currentDate.month - 1, 1);
    } else if (widget.periodType == 'year') {
      newDate = DateTime(currentDate.year - 1, 1, 1);
    } else {
      return;
    }

    _navigateToDate(newDate);
  }

  void _navigateToNextDate() {
    if (!_canNavigateToNext()) return;

    final currentDate = DateTime.fromMillisecondsSinceEpoch(
      widget.dateRange['start']!,
      isUtc: true,
    ).toLocal();

    DateTime newDate;
    if (widget.periodType == 'today') {
      newDate = currentDate.add(const Duration(days: 1));
    } else if (widget.periodType == 'month') {
      newDate = DateTime(currentDate.year, currentDate.month + 1, 1);
    } else if (widget.periodType == 'year') {
      newDate = DateTime(currentDate.year + 1, 1, 1);
    } else {
      return;
    }

    _navigateToDate(newDate);
  }

  void _navigateToDate(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    Map<String, int> newDateRange;
    String newPeriodTitle;

    if (widget.periodType == 'today') {
      newDateRange = _getDateRangeForDate(date);
      newPeriodTitle = l10n.today;
    } else if (widget.periodType == 'month') {
      newDateRange = _getMonthRangeForDate(date);
      newPeriodTitle = l10n.thisMonth;
    } else if (widget.periodType == 'year') {
      newDateRange = _getYearRangeForDate(date);
      newPeriodTitle = l10n.thisYear;
    } else {
      return;
    }

    // Navigate to new TransactionHistoryScreen with the new date range
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => TransactionHistoryScreen(
          account: widget.account,
          periodType: widget.periodType,
          periodTitle: newPeriodTitle,
          dateRange: newDateRange,
        ),
      ),
    );
  }

  Map<String, int> _getDateRangeForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day).toUtc();
    final endOfDay = DateTime(
      date.year,
      date.month,
      date.day,
      23,
      59,
      59,
      999,
    ).toUtc();

    return {
      'start': startOfDay.millisecondsSinceEpoch,
      'end': endOfDay.millisecondsSinceEpoch,
    };
  }

  Map<String, int> _getMonthRangeForDate(DateTime date) {
    final startOfMonth = DateTime(date.year, date.month, 1).toUtc();
    final endOfMonth = DateTime(
      date.year,
      date.month + 1,
      0,
      23,
      59,
      59,
      999,
    ).toUtc();

    return {
      'start': startOfMonth.millisecondsSinceEpoch,
      'end': endOfMonth.millisecondsSinceEpoch,
    };
  }

  Map<String, int> _getYearRangeForDate(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1).toUtc();
    final endOfYear = DateTime(date.year, 12, 31, 23, 59, 59, 999).toUtc();

    return {
      'start': startOfYear.millisecondsSinceEpoch,
      'end': endOfYear.millisecondsSinceEpoch,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Pop with the result indicating if changes were made
          Navigator.of(context).pop(_hasChanges);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.transactions),
              Text(
                widget.account.name,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          backgroundColor: theme.colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _openSearchScreen,
              tooltip: l10n.search,
            ),
            IconButton(
              icon: const Icon(Icons.list_alt),
              onPressed: _viewAllTransactions,
              tooltip: l10n.viewAllTransactions,
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  _filterType = value;
                  _applyFilters();
                });
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'all', child: Text(l10n.allTransactions)),
                PopupMenuItem(value: 'income', child: Text(l10n.incomeOnly)),
                PopupMenuItem(value: 'expense', child: Text(l10n.expensesOnly)),
              ],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.filter_list, color: theme.colorScheme.onSurface),
                    const SizedBox(width: 4),
                    Text(
                      _filterType == 'all'
                          ? l10n.all
                          : _filterType == 'income'
                          ? l10n.income
                          : l10n.expensesTab,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          top: false, // Don't apply to top since AppBar handles it
          child: Column(
            children: [
              // Summary card for the period
              if (_summary != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date header with navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Previous date button
                          IconButton(
                            onPressed: _navigateToPreviousDate,
                            icon: Icon(
                              Icons.chevron_left,
                              color: theme.colorScheme.primary,
                            ),
                            tooltip: l10n.previousPeriod(widget.periodType),
                          ),
                          // Date display
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getDateRangeText(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          // Next date button (only show if not today for 'today' period)
                          IconButton(
                            onPressed: _canNavigateToNext()
                                ? _navigateToNextDate
                                : null,
                            icon: Icon(
                              Icons.chevron_right,
                              color: _canNavigateToNext()
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.3,
                                    ),
                            ),
                            tooltip: _canNavigateToNext()
                                ? l10n.nextPeriod(widget.periodType)
                                : null,
                          ),
                        ],
                      ),
                      // Summary row (only show if there are transactions)
                      if (_summary!.hasTransactions) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // Income
                            Expanded(
                              child: _buildSummaryColumn(
                                context,
                                l10n.income,
                                _summary!.totalIncome,
                                Colors.green,
                                Icons.trending_up,
                              ),
                            ),
                            // Expenses
                            Expanded(
                              child: _buildSummaryColumn(
                                context,
                                l10n.expensesTab,
                                _summary!.totalExpenses,
                                Colors.red,
                                Icons.trending_down,
                              ),
                            ),
                            // Balance
                            Expanded(
                              child: _buildSummaryColumn(
                                context,
                                l10n.balance,
                                _summary!.balance,
                                _summary!.isPositiveBalance
                                    ? Colors.green
                                    : _summary!.isNegativeBalance
                                    ? Colors.red
                                    : theme.colorScheme.onSurface,
                                _summary!.isPositiveBalance
                                    ? Icons.arrow_upward
                                    : _summary!.isNegativeBalance
                                    ? Icons.arrow_downward
                                    : Icons.remove,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

              // Transaction/Monthly list
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : widget.periodType == 'year'
                    ? _buildMonthlyList(theme)
                    : widget.periodType == 'month'
                    ? _buildDailyList(theme)
                    : _buildTransactionList(theme),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addTransaction,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildMonthlyList(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return _filteredMonthlySummaries.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month,
                  size: 64,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  _filterType != 'all'
                      ? l10n.noMonthsFound
                      : l10n.noTransactionsThisYear,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _filterType != 'all'
                      ? l10n.tryAdjustingSearchOrFilters
                      : l10n.addTransactionsToSeeMonthly,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredMonthlySummaries.length,
              itemBuilder: (context, index) {
                final monthlySummary = _filteredMonthlySummaries[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    onTap: monthlySummary.hasTransactions
                        ? () => _navigateToMonthlyTransactions(monthlySummary)
                        : null,
                    leading: CircleAvatar(
                      backgroundColor: monthlySummary.isPositiveBalance
                          ? Colors.green.withValues(alpha: 0.2)
                          : monthlySummary.isNegativeBalance
                          ? Colors.red.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.calendar_month,
                        color: monthlySummary.isPositiveBalance
                            ? Colors.green
                            : monthlySummary.isNegativeBalance
                            ? Colors.red
                            : Colors.grey,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      monthlySummary.monthName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: monthlySummary.hasTransactions
                        ? Text(
                            l10n.transactionsCount(
                              monthlySummary.transactionCount,
                            ),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          )
                        : Text(
                            l10n.noTransactionsText,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                    trailing: monthlySummary.hasTransactions
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatAmount(monthlySummary.balance),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: monthlySummary.isPositiveBalance
                                      ? Colors.green
                                      : monthlySummary.isNegativeBalance
                                      ? Colors.red
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                l10n.balance,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                );
              },
            ),
          );
  }

  Widget _buildDailyList(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return _filteredDailySummaries.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 64,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  _filterType != 'all'
                      ? l10n.noDaysFound
                      : l10n.noTransactionsThisMonth,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _filterType != 'all'
                      ? l10n.tryAdjustingSearchOrFilters
                      : l10n.addTransactionsToSeeDailySummaries,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredDailySummaries.length,
              itemBuilder: (context, index) {
                final dailySummary = _filteredDailySummaries[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    onTap: dailySummary.hasTransactions
                        ? () => _navigateToDailyTransactions(dailySummary)
                        : null,
                    leading: CircleAvatar(
                      backgroundColor: dailySummary.isPositiveBalance
                          ? Colors.green.withValues(alpha: 0.2)
                          : dailySummary.isNegativeBalance
                          ? Colors.red.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.calendar_today,
                        color: dailySummary.isPositiveBalance
                            ? Colors.green
                            : dailySummary.isNegativeBalance
                            ? Colors.red
                            : Colors.grey,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      dailySummary.formattedDayDate,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: dailySummary.hasTransactions
                        ? Text(
                            l10n.transactionsCount(
                              dailySummary.transactionCount,
                            ),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          )
                        : Text(
                            l10n.noTransactionsText,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                    trailing: dailySummary.hasTransactions
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatAmount(dailySummary.balance),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: dailySummary.isPositiveBalance
                                      ? Colors.green
                                      : dailySummary.isNegativeBalance
                                      ? Colors.red
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                l10n.balance,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                );
              },
            ),
          );
  }

  Widget _buildTransactionList(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return _filteredTransactions.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  _filterType != 'all'
                      ? l10n.noTransactionsFound
                      : l10n.noTransactionsForPeriod(
                          widget.periodTitle.toLowerCase(),
                        ),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _filterType != 'all'
                      ? l10n.tryAdjustingSearchOrFilters
                      : l10n.addTransactionToGetStarted,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = _filteredTransactions[index];
                final category = _categoriesMap[transaction.categoryId];
                final paymentSource =
                    _paymentSourcesMap[transaction.paymentSourceId];

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    onTap: () => _navigateToTransactionDetails(transaction),
                    onLongPress: () => _showTransactionOptions(transaction),
                    leading: CircleAvatar(
                      backgroundColor:
                          category?.color.withValues(alpha: 0.2) ??
                          Colors.grey.withValues(alpha: 0.2),
                      child: Icon(
                        category?.icon ?? Icons.help_outline,
                        color: category?.color ?? Colors.grey,
                        size: 20,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            transaction.description.isNotEmpty
                                ? transaction.description
                                : category?.name ?? l10n.unknownCategory,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          '${transaction.isIncome ? '+' : '-'}${_formatAmount(transaction.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: transaction.isIncome
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${category?.name ?? l10n.unknown} • ${paymentSource?.name ?? l10n.unknown}',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        Text(
                          _formatDate(transaction.transactionDateTime),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }

  Future<void> _navigateToMonthlyTransactions(
    MonthlySummary monthlySummary,
  ) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => MonthlyTransactionsScreen(
          account: widget.account,
          year: monthlySummary.year,
          month: monthlySummary.month,
        ),
      ),
    );

    if (result == true) {
      _hasChanges = true;
      _loadData(); // Reload data if transactions were modified
    }
  }

  Future<void> _navigateToDailyTransactions(DailySummary dailySummary) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => DailyTransactionsScreen(
          account: widget.account,
          year: dailySummary.year,
          month: dailySummary.month,
          day: dailySummary.day,
        ),
      ),
    );

    if (result == true) {
      _hasChanges = true;
      _loadData(); // Reload data if transactions were modified
    }
  }

  Widget _buildSummaryColumn(
    BuildContext context,
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _formatAmount(amount),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
