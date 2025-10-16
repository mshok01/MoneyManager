import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../models/category_item.dart';
import '../models/payment_source.dart';
import '../services/transaction_service.dart';
import '../services/category_service.dart';
import '../services/payment_source_service.dart';
import '../services/user_service.dart';
import '../utils/currency_utils.dart';
import '../widgets/highlighted_text.dart';
import '../l10n/app_localizations.dart';

import 'transaction_details_screen.dart';

class HistoryScreen extends StatefulWidget {
  final Account account;

  const HistoryScreen({super.key, required this.account});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Transaction> _transactions = [];
  Map<String, CategoryItem> _categoriesMap = {};
  Map<String, PaymentSource> _paymentSourcesMap = {};

  bool _isLoading = true;
  String _selectedPeriod = 'all'; // 'all', 'week', 'month', 'year'

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchTerm = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load transactions for the account
      final transactions = await TransactionService.instance
          .getAccountTransactions(widget.account.id);

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
        _categoriesMap = categoriesMap;
        _paymentSourcesMap = paymentSourcesMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.failedToLoadHistory(e.toString()),
            ),
          ),
        );
      }
    }
  }

  List<Transaction> get _filteredTransactions {
    final now = DateTime.now();
    List<Transaction> filtered = _transactions;

    // Apply period filter
    switch (_selectedPeriod) {
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        filtered = _transactions
            .where((t) => t.transactionDateTime.isAfter(weekAgo))
            .toList();
        break;
      case 'month':
        final monthAgo = DateTime(now.year, now.month - 1, now.day);
        filtered = _transactions
            .where((t) => t.transactionDateTime.isAfter(monthAgo))
            .toList();
        break;
      case 'year':
        final yearAgo = DateTime(now.year - 1, now.month, now.day);
        filtered = _transactions
            .where((t) => t.transactionDateTime.isAfter(yearAgo))
            .toList();
        break;
      default:
        filtered = _transactions;
    }

    // Apply search filter
    if (_currentSearchTerm.isNotEmpty) {
      final searchTerm = _currentSearchTerm.toLowerCase();
      filtered = filtered.where((transaction) {
        // Search in transaction description
        final description = transaction.description.toLowerCase();
        if (description.contains(searchTerm)) return true;

        // Search in category name
        final category = _categoriesMap[transaction.categoryId];
        if (category != null &&
            category.name.toLowerCase().contains(searchTerm)) {
          return true;
        }

        // Search in payment source name
        final paymentSource = _paymentSourcesMap[transaction.paymentSourceId];
        if (paymentSource != null &&
            paymentSource.name.toLowerCase().contains(searchTerm)) {
          return true;
        }

        return false;
      }).toList();
    }

    // Sort by date (newest first)
    filtered.sort(
      (a, b) => b.transactionDateTime.compareTo(a.transactionDateTime),
    );
    return filtered;
  }

  Map<String, List<Transaction>> get _groupedTransactions {
    final grouped = <String, List<Transaction>>{};

    for (final transaction in _filteredTransactions) {
      final dateKey = _formatDateKey(transaction.transactionDateTime);
      grouped.putIfAbsent(dateKey, () => []).add(transaction);
    }

    return grouped;
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return AppLocalizations.of(context)!.today;
    } else if (transactionDate == yesterday) {
      return AppLocalizations.of(context)!.yesterday;
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatAmount(double amount) {
    final currentUser = UserService.instance.currentUser;
    final userCurrency =
        currentUser?.currencyCode ?? widget.account.baseCurrency;
    final currencySymbol = CurrencyUtils.getCurrencySymbol(userCurrency);

    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  void _performSearch(String query) {
    setState(() {
      _currentSearchTerm = query.trim();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _currentSearchTerm = '';
      _isSearching = false;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _clearSearch();
      }
    });
  }

  double get _totalIncome {
    return _filteredTransactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get _totalExpense {
    return _filteredTransactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Widget _buildPeriodSelector() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildPeriodChip('all', l10n.allTime),
          const SizedBox(width: 8),
          _buildPeriodChip('week', l10n.week),
          const SizedBox(width: 8),
          _buildPeriodChip('month', l10n.month),
          const SizedBox(width: 8),
          _buildPeriodChip('year', l10n.year),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String period, String label) {
    final theme = Theme.of(context);
    final isSelected = _selectedPeriod == period;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.income,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
                Text(
                  '+${_formatAmount(_totalIncome)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.2),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.expensesTab,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
                Text(
                  '-${_formatAmount(_totalExpense)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final groupedTransactions = _groupedTransactions;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchTransactions,
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _performSearch,
              )
            : Text(l10n.accountHistory(widget.account.name)),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (!_isSearching) _buildPeriodSelector(),
                if (!_isSearching) _buildSummaryCard(),
                if (!_isSearching) const SizedBox(height: 16),

                Expanded(
                  child: _filteredTransactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history,
                                size: 64,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noTransactionsFound,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.tryDifferentTimePeriod,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: groupedTransactions.length,
                            itemBuilder: (context, index) {
                              final dateKey = groupedTransactions.keys
                                  .elementAt(index);
                              final dayTransactions =
                                  groupedTransactions[dateKey]!;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      dateKey,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.primary,
                                          ),
                                    ),
                                  ),
                                  ...dayTransactions.map((transaction) {
                                    final category =
                                        _categoriesMap[transaction.categoryId];
                                    final paymentSource =
                                        _paymentSourcesMap[transaction
                                            .paymentSourceId];

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: theme.colorScheme.outline
                                              .withValues(alpha: 0.2),
                                        ),
                                      ),
                                      child: ListTile(
                                        onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TransactionDetailsScreen(
                                                  transaction: transaction,
                                                  account: widget.account,
                                                ),
                                          ),
                                        ),
                                        leading: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color:
                                                category?.color.withValues(
                                                  alpha: 0.2,
                                                ) ??
                                                Colors.grey.withValues(
                                                  alpha: 0.2,
                                                ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            category?.icon ??
                                                Icons.help_outline,
                                            color:
                                                category?.color ?? Colors.grey,
                                            size: 20,
                                          ),
                                        ),
                                        title: HighlightedText(
                                          text:
                                              transaction.description.isNotEmpty
                                              ? transaction.description
                                              : category?.name ??
                                                    l10n.unknownCategory,
                                          searchTerm: _currentSearchTerm,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (category != null)
                                              HighlightedText(
                                                text: category.name,
                                                searchTerm: _currentSearchTerm,
                                                style: TextStyle(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.6),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            HighlightedText(
                                              text:
                                                  paymentSource?.name ??
                                                  l10n.unknownSource,
                                              searchTerm: _currentSearchTerm,
                                              style: TextStyle(
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: Text(
                                          '${transaction.isIncome ? '+' : '-'}${_formatAmount(transaction.amount)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: transaction.isIncome
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
