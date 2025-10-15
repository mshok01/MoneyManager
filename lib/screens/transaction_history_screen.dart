import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../models/category_item.dart';
import '../models/payment_source.dart';
import '../models/transaction_summary.dart';
import '../services/transaction_service.dart';
import '../services/category_service.dart';
import '../services/payment_source_service.dart';
import '../services/user_service.dart';
import '../utils/currency_utils.dart';

import 'add_edit_transaction_screen.dart';
import 'transaction_list_screen.dart';

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
  final _searchController = TextEditingController();

  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  Map<String, CategoryItem> _categoriesMap = {};
  Map<String, PaymentSource> _paymentSourcesMap = {};
  TransactionSummary? _summary;

  bool _isLoading = true;
  String _searchQuery = '';
  String _filterType = 'all'; // 'all', 'income', 'expense'

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
    setState(() => _isLoading = true);

    try {
      // Load transactions for the date range
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
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load transactions: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    List<Transaction> filtered = _transactions;

    // Apply type filter
    if (_filterType != 'all') {
      filtered = filtered.where((t) => t.type == _filterType).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) {
        final description = t.description.toLowerCase();
        final category = _categoriesMap[t.categoryId]?.name.toLowerCase() ?? '';
        final paymentSource =
            _paymentSourcesMap[t.paymentSourceId]?.name.toLowerCase() ?? '';

        return description.contains(_searchQuery) ||
            category.contains(_searchQuery) ||
            paymentSource.contains(_searchQuery);
      }).toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    setState(() {
      _filteredTransactions = filtered;
    });
  }

  Future<void> _addTransaction() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddEditTransactionScreen(account: widget.account),
      ),
    );

    if (result == true) {
      _loadData(); // Reload data if transaction was added
    }
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
      _loadData(); // Reload data if transaction was updated
    }
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await TransactionService.instance.deleteTransaction(transaction.id);
        _loadData(); // Reload data after deletion
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete transaction: $e')),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.periodTitle} Transactions'),
            Text(
              _getDateRangeText(),
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
            icon: const Icon(Icons.list_alt),
            onPressed: _viewAllTransactions,
            tooltip: 'View All Transactions',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filterType = value;
                _applyFilters();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Transactions'),
              ),
              const PopupMenuItem(value: 'income', child: Text('Income Only')),
              const PopupMenuItem(
                value: 'expense',
                child: Text('Expenses Only'),
              ),
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
                        ? 'All'
                        : _filterType == 'income'
                        ? 'Income'
                        : 'Expenses',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary card for the period
          if (_summary != null && _summary!.hasTransactions)
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
              child: Row(
                children: [
                  // Income
                  Expanded(
                    child: _buildSummaryColumn(
                      context,
                      'Income',
                      _summary!.totalIncome,
                      Colors.green,
                      Icons.trending_up,
                    ),
                  ),
                  // Expenses
                  Expanded(
                    child: _buildSummaryColumn(
                      context,
                      'Expenses',
                      _summary!.totalExpenses,
                      Colors.red,
                      Icons.trending_down,
                    ),
                  ),
                  // Balance
                  Expanded(
                    child: _buildSummaryColumn(
                      context,
                      'Balance',
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
            ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Transaction list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _filterType != 'all'
                              ? 'No transactions found'
                              : 'No transactions for ${widget.periodTitle.toLowerCase()}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty || _filterType != 'all'
                              ? 'Try adjusting your search or filters'
                              : 'Add a transaction to get started',
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
                      itemCount: _filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _filteredTransactions[index];
                        final category = _categoriesMap[transaction.categoryId];
                        final paymentSource =
                            _paymentSourcesMap[transaction.paymentSourceId];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
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
                                        : category?.name ?? 'Unknown Category',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
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
                                  '${category?.name ?? 'Unknown'} • ${paymentSource?.name ?? 'Unknown'}',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                                Text(
                                  _formatDate(transaction.transactionDateTime),
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editTransaction(transaction);
                                } else if (value == 'delete') {
                                  _deleteTransaction(transaction);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
        child: const Icon(Icons.add),
      ),
    );
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
