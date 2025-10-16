import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../models/category_item.dart';
import '../models/payment_source.dart';
import '../models/daily_summary.dart';
import '../services/transaction_service.dart';
import '../services/category_service.dart';
import '../services/payment_source_service.dart';
import '../services/user_service.dart';
import '../utils/currency_utils.dart';
import 'add_edit_transaction_screen.dart';
import 'transaction_details_screen.dart';

class DailyTransactionsScreen extends StatefulWidget {
  final Account account;
  final int year;
  final int month;
  final int day;

  const DailyTransactionsScreen({
    super.key,
    required this.account,
    required this.year,
    required this.month,
    required this.day,
  });

  @override
  State<DailyTransactionsScreen> createState() =>
      _DailyTransactionsScreenState();
}

class _DailyTransactionsScreenState extends State<DailyTransactionsScreen> {
  final _searchController = TextEditingController();

  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  Map<String, CategoryItem> _categoriesMap = {};
  Map<String, PaymentSource> _paymentSourcesMap = {};
  DailySummary? _dailySummary;

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
      // Load transactions for the specific day
      final transactions = await TransactionService.instance.getDayTransactions(
        widget.account.id,
        widget.year,
        widget.month,
        widget.day,
      );

      // Load daily summary
      final dailySummary = await TransactionService.instance.getDailySummary(
        widget.account.id,
        widget.year,
        widget.month,
        widget.day,
      );

      // Load categories and payment sources
      final incomeCategories = await CategoryService.instance
          .getIncomeCategories();
      final expenseCategories = await CategoryService.instance
          .getExpenseCategories();
      final paymentSources = await PaymentSourceService.instance
          .getAllPaymentSources();

      final categories = [...incomeCategories, ...expenseCategories];

      // Create maps for quick lookup
      final categoriesMap = <String, CategoryItem>{};
      for (final category in categories) {
        categoriesMap[category.id] = category;
      }

      final paymentSourcesMap = <String, PaymentSource>{};
      for (final source in paymentSources) {
        paymentSourcesMap[source.id] = source;
      }

      setState(() {
        _transactions = transactions;
        _dailySummary = dailySummary;
        _categoriesMap = categoriesMap;
        _paymentSourcesMap = paymentSourcesMap;
        _isLoading = false;
        _applyFilters();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading transactions: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    List<Transaction> filteredTransactions = _transactions;

    // Apply type filter
    if (_filterType == 'income') {
      filteredTransactions = filteredTransactions
          .where((t) => t.isIncome)
          .toList();
    } else if (_filterType == 'expense') {
      filteredTransactions = filteredTransactions
          .where((t) => !t.isIncome)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredTransactions = filteredTransactions.where((transaction) {
        final category = _categoriesMap[transaction.categoryId];
        final paymentSource = _paymentSourcesMap[transaction.paymentSourceId];

        final searchableText = [
          transaction.description,
          category?.name ?? '',
          paymentSource?.name ?? '',
        ].join(' ').toLowerCase();

        return searchableText.contains(_searchQuery);
      }).toList();
    }

    // Sort by transaction date (newest first)
    filteredTransactions.sort(
      (a, b) => b.transactionDateTime.compareTo(a.transactionDateTime),
    );

    setState(() {
      _filteredTransactions = filteredTransactions;
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
      _loadData();
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

    if (result == true) {
      _hasChanges = true;
      _loadData();
    }
  }

  String _formatAmount(double amount) {
    final user = UserService.instance.currentUser;
    final currencySymbol = CurrencyUtils.getCurrencySymbol(
      user?.currencyCode ?? 'USD',
    );
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  String get _dayTitle {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${monthNames[widget.month - 1]} ${widget.day}, ${widget.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(_hasChanges);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Daily Transactions'),
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
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              // Daily summary card
              if (_dailySummary != null)
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
                      Text(
                        _dayTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryColumn(
                            context,
                            'Income',
                            _dailySummary!.totalIncome,
                            Colors.green,
                            Icons.arrow_upward,
                          ),
                          _buildSummaryColumn(
                            context,
                            'Expenses',
                            _dailySummary!.totalExpenses,
                            Colors.red,
                            Icons.arrow_downward,
                          ),
                          _buildSummaryColumn(
                            context,
                            'Balance',
                            _dailySummary!.balance,
                            _dailySummary!.balance >= 0
                                ? Colors.green
                                : Colors.red,
                            _dailySummary!.balance >= 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Search and filter section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search transactions...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      initialValue: _filterType,
                      onSelected: (value) {
                        setState(() {
                          _filterType = value;
                          _applyFilters();
                        });
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'all', child: Text('All')),
                        const PopupMenuItem(
                          value: 'income',
                          child: Text('Income'),
                        ),
                        const PopupMenuItem(
                          value: 'expense',
                          child: Text('Expenses'),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.outline),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.filter_list, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              _filterType == 'all'
                                  ? 'All'
                                  : _filterType == 'income'
                                  ? 'Income'
                                  : 'Expenses',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Transactions list
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
                                  : 'No transactions for this day',
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
                            final category =
                                _categoriesMap[transaction.categoryId];
                            final paymentSource =
                                _paymentSourcesMap[transaction.paymentSourceId];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                onTap: () =>
                                    _navigateToTransactionDetails(transaction),
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
                                            : category?.name ??
                                                  'Unknown Category',
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
                                subtitle: Text(
                                  '${category?.name ?? 'Unknown'} • ${paymentSource?.name ?? 'Unknown'}',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
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
