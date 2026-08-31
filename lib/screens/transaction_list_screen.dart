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
import '../l10n/app_localizations.dart';
import 'add_edit_transaction_screen.dart';
import 'transaction_details_screen.dart';

class TransactionListScreen extends StatefulWidget {
  final Account account;

  const TransactionListScreen({super.key, required this.account});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final _searchController = TextEditingController();

  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  Map<String, CategoryItem> _categoriesMap = {};
  Map<String, PaymentSource> _paymentSourcesMap = {};

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
        _applyFilters();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorLoadingTransactions(e.toString()))),
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
    final result = await AddEditTransactionScreen.push(context, account: widget.account);

    if (result == true) {
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
    final result = await AddEditTransactionScreen.push(
      context,
      account: widget.account,
      transaction: transaction,
    );

    if (result == true) {
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

  String _formatAmount(double amount) {
    final currentUser = UserService.instance.currentUser;
    final userCurrency =
        currentUser?.currencyCode ?? widget.account.baseCurrency;
    final currencySymbol = CurrencyUtils.getCurrencySymbol(userCurrency);

    // For now, we're storing amounts in account currency, so we show them as-is
    // In the future, this would convert from account currency to user currency
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountTransactions(widget.account.name)),
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
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchTransactions,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

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
                              ? l10n.noTransactionsFound
                              : l10n.noTransactionsYet,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty || _filterType != 'all'
                              ? l10n.tryAdjustingSearchOrFilters
                              : l10n.addFirstTransactionToGetStarted,
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
                            onTap: () =>
                                _navigateToTransactionDetails(transaction),
                            onLongPress: () =>
                                _showTransactionOptions(transaction),
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
                                              l10n.unknownCategory,
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
                                  '${category?.name ?? l10n.unknown} • ${paymentSource?.name ?? l10n.unknown}',
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
}
