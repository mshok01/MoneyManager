import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/account.dart';
import '../models/monthly_summary.dart';
import '../models/daily_summary.dart';
import '../services/transaction_service.dart';
import '../services/user_service.dart';
import '../utils/currency_utils.dart';
import 'add_edit_transaction_screen.dart';
import 'daily_transactions_screen.dart';

class MonthlyTransactionsScreen extends StatefulWidget {
  final Account account;
  final int year;
  final int month;

  const MonthlyTransactionsScreen({
    super.key,
    required this.account,
    required this.year,
    required this.month,
  });

  @override
  State<MonthlyTransactionsScreen> createState() =>
      _MonthlyTransactionsScreenState();
}

class _MonthlyTransactionsScreenState extends State<MonthlyTransactionsScreen> {
  final _searchController = TextEditingController();

  List<DailySummary> _dailySummaries = [];
  List<DailySummary> _filteredDailySummaries = [];
  MonthlySummary? _monthlySummary;

  bool _isLoading = true;
  String _searchQuery = '';
  String _filterType = 'all'; // 'all', 'income', 'expense'
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFilters();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load daily summaries for the month
      final dailySummaries = await TransactionService.instance
          .getMonthlyDailySummaries(
            widget.account.id,
            widget.year,
            widget.month,
          );

      // Load monthly summary
      final monthlySummary = await TransactionService.instance
          .getMonthlySummary(widget.account.id, widget.year, widget.month);

      setState(() {
        _dailySummaries = dailySummaries;
        _monthlySummary = monthlySummary;
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<DailySummary> filtered = _dailySummaries;

    // Apply type filter
    if (_filterType == 'income') {
      filtered = filtered.where((d) => d.totalIncome > 0).toList();
    } else if (_filterType == 'expense') {
      filtered = filtered.where((d) => d.totalExpenses > 0).toList();
    }

    // Apply search filter (search by day name or day number)
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((d) {
        final dayName = d.dayName.toLowerCase();
        final dayNumber = d.day.toString();
        final formattedDate = d.formattedDate.toLowerCase();

        return dayName.contains(_searchQuery) ||
            dayNumber.contains(_searchQuery) ||
            formattedDate.contains(_searchQuery);
      }).toList();
    }

    // Sort by day (newest first)
    filtered.sort((a, b) => b.day.compareTo(a.day));

    setState(() {
      _filteredDailySummaries = filtered;
    });
  }

  Future<void> _addTransaction() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddEditTransactionScreen(account: widget.account),
      ),
    );

    if (result == true) {
      _hasChanges = true;
      _loadData(); // Reload data if transaction was added
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
      _loadData(); // Reload data if transaction was modified
    }
  }

  String _formatAmount(double amount) {
    final currentUser = UserService.instance.currentUser;
    final userCurrency =
        currentUser?.currencyCode ?? widget.account.baseCurrency;
    final currencySymbol = CurrencyUtils.getCurrencySymbol(userCurrency);
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  Widget _buildSummaryCard() {
    if (_monthlySummary == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final summary = _monthlySummary!;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary.formattedMonthYear,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    l10n.income,
                    _formatAmount(summary.totalIncome),
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    l10n.expensesTab,
                    _formatAmount(summary.totalExpenses),
                    Icons.trending_down,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    l10n.balance,
                    _formatAmount(summary.balance),
                    summary.isPositiveBalance
                        ? Icons.trending_up
                        : summary.isNegativeBalance
                        ? Icons.trending_down
                        : Icons.remove,
                    summary.isPositiveBalance
                        ? Colors.green
                        : summary.isNegativeBalance
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final monthName = _monthlySummary?.monthName ?? l10n.month;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && _hasChanges) {
          // Return true to indicate changes were made
          Navigator.of(context).pop(true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('$monthName ${widget.year}'),
          backgroundColor: theme.colorScheme.inversePrimary,
          actions: [
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildSummaryCard(),
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: l10n.searchTransactions,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Daily summaries list
                  Expanded(
                    child: _filteredDailySummaries.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 64,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty ||
                                          _filterType != 'all'
                                      ? l10n.noMatchingDays
                                      : l10n.noDaysWithTransactions,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchQuery.isNotEmpty ||
                                          _filterType != 'all'
                                      ? l10n.tryAdjustingSearchOrFilters
                                      : l10n.addTransactionsToSeeDailySummaries,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: _filteredDailySummaries.length,
                              itemBuilder: (context, index) {
                                final dailySummary =
                                    _filteredDailySummaries[index];

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    onTap: dailySummary.hasTransactions
                                        ? () => _navigateToDailyTransactions(
                                            dailySummary,
                                          )
                                        : null,
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          dailySummary.isPositiveBalance
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
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: dailySummary.hasTransactions
                                        ? Text(
                                            l10n.transactionsCount(
                                              dailySummary.transactionCount,
                                            ),
                                            style: TextStyle(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.6),
                                            ),
                                          )
                                        : Text(
                                            l10n.noTransactionsYet,
                                            style: TextStyle(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.5),
                                            ),
                                          ),
                                    trailing: dailySummary.hasTransactions
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                _formatAmount(
                                                  dailySummary.balance,
                                                ),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      dailySummary
                                                          .isPositiveBalance
                                                      ? Colors.green
                                                      : dailySummary
                                                            .isNegativeBalance
                                                      ? Colors.red
                                                      : theme
                                                            .colorScheme
                                                            .onSurface,
                                                ),
                                              ),
                                              Text(
                                                l10n.balance,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.5),
                                                ),
                                              ),
                                            ],
                                          )
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addTransaction,
          tooltip: l10n.addTransaction,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
