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

class SearchScreen extends StatefulWidget {
  final Account account;

  const SearchScreen({super.key, required this.account});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  List<Transaction> _searchResults = [];
  Map<String, CategoryItem> _categoriesMap = {};
  Map<String, PaymentSource> _paymentSourcesMap = {};

  bool _isLoading = false;
  bool _hasSearched = false;
  String _filterType = 'all'; // 'all', 'income', 'expense'
  String _currentSearchTerm = '';

  @override
  void initState() {
    super.initState();
    _loadCategoriesAndSources();
    // Auto-focus the search field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadCategoriesAndSources() async {
    try {
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
        _categoriesMap = categoriesMap;
        _paymentSourcesMap = paymentSourcesMap;
      });
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _currentSearchTerm = query;
    });

    try {
      // Get all transactions for the account
      final allTransactions = await TransactionService.instance
          .getAccountTransactions(widget.account.id);

      // Filter transactions based on search query
      final filteredTransactions = allTransactions.where((transaction) {
        final description = transaction.description.toLowerCase();
        final category =
            _categoriesMap[transaction.categoryId]?.name.toLowerCase() ?? '';
        final paymentSource =
            _paymentSourcesMap[transaction.paymentSourceId]?.name
                .toLowerCase() ??
            '';
        final amount = transaction.amount.toString();

        final searchQuery = query.toLowerCase();

        return description.contains(searchQuery) ||
            category.contains(searchQuery) ||
            paymentSource.contains(searchQuery) ||
            amount.contains(searchQuery);
      }).toList();

      // Apply type filter
      List<Transaction> finalResults = filteredTransactions;
      if (_filterType != 'all') {
        finalResults = filteredTransactions
            .where((t) => t.type == _filterType)
            .toList();
      }

      // Sort by date (newest first)
      finalResults.sort(
        (a, b) => b.transactionDate.compareTo(a.transactionDate),
      );

      setState(() {
        _searchResults = finalResults;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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

    // If transaction was edited or deleted, refresh search results
    if (result == true) {
      _performSearch();
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.searchTransactionsTitle),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filterType = value;
              });
              if (_hasSearched) {
                _performSearch();
              }
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
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: l10n.searchTransactionsHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults.clear();
                            _hasSearched = false;
                            _currentSearchTerm = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _performSearch(),
              onChanged: (value) {
                setState(() {}); // Rebuild to show/hide clear button
              },
            ),
          ),

          // Search button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _searchController.text.trim().isNotEmpty
                    ? _performSearch
                    : null,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.search),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Results
          Expanded(child: _buildSearchResults(theme, l10n)),
        ],
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme, AppLocalizations l10n) {
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.searchYourTransactions,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.searchInstructions,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noTransactionsFound,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tryDifferentKeywords,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final transaction = _searchResults[index];
        final category = _categoriesMap[transaction.categoryId];

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            onTap: () => _navigateToTransactionDetails(transaction),
            leading: CircleAvatar(
              backgroundColor: transaction.isIncome
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.red.withValues(alpha: 0.2),
              child: Icon(
                transaction.isIncome
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color: transaction.isIncome ? Colors.green : Colors.red,
                size: 20,
              ),
            ),
            title: HighlightedText(
              text: transaction.description.isNotEmpty
                  ? transaction.description
                  : category?.name ?? l10n.unknown,
              searchTerm: _currentSearchTerm,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HighlightedText(
                  text: category?.name ?? l10n.unknownCategory,
                  searchTerm: _currentSearchTerm,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: HighlightedText(
                        text:
                            _paymentSourcesMap[transaction.paymentSourceId]
                                ?.name ??
                            l10n.unknownSource,
                        searchTerm: _currentSearchTerm,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      ' • ${_formatDate(transaction.transactionDateTime)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Text(
              '${transaction.isIncome ? '+' : '-'}${_formatAmount(transaction.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: transaction.isIncome ? Colors.green : Colors.red,
              ),
            ),
          ),
        );
      },
    );
  }
}
