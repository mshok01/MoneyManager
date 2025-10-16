import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../models/category_item.dart';
import '../models/payment_source.dart';
import '../services/transaction_service.dart';
import '../services/category_service.dart';
import '../services/payment_source_service.dart';
import '../services/user_service.dart';
import '../utils/currency_utils.dart';
import '../screens/transaction_details_screen.dart';
import '../l10n/app_localizations.dart';
import 'highlighted_text.dart';

/// Search bar widget for the home screen that searches transactions
class HomeSearchBar extends StatefulWidget {
  final Account account;

  const HomeSearchBar({super.key, required this.account});

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<Transaction> _searchResults = [];
  Map<String, CategoryItem> _categoriesMap = {};
  Map<String, PaymentSource> _paymentSourcesMap = {};
  bool _isLoading = false;
  bool _isExpanded = false;
  String _currentSearchTerm = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
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
      // Handle error silently
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults.clear();
        _currentSearchTerm = '';
        _isExpanded = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _currentSearchTerm = query.trim();
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

        final searchQuery = query.toLowerCase();

        return description.contains(searchQuery) ||
            category.contains(searchQuery) ||
            paymentSource.contains(searchQuery);
      }).toList();

      // Sort by date (newest first)
      filteredTransactions.sort(
        (a, b) => b.transactionDate.compareTo(a.transactionDate),
      );

      setState(() {
        _searchResults = filteredTransactions
            .take(5)
            .toList(); // Limit to 5 results
        _isLoading = false;
        _isExpanded = _searchResults.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _searchResults.clear();
        _isExpanded = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults.clear();
      _currentSearchTerm = '';
      _isExpanded = false;
    });
    _focusNode.unfocus();
  }

  void _navigateToTransactionDetails(Transaction transaction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransactionDetailsScreen(
          transaction: transaction,
          account: widget.account,
        ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Search bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: l10n.searchTransactions,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {}); // Rebuild to show/hide clear button
              _performSearch(value);
            },
            onTap: () {
              if (_searchResults.isNotEmpty) {
                setState(() {
                  _isExpanded = true;
                });
              }
            },
          ),
        ),

        // Search results
        if (_isExpanded) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : _searchResults.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.noTransactionsFound,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Column(
                    children: [
                      ...List.generate(_searchResults.length, (index) {
                        final transaction = _searchResults[index];
                        final category = _categoriesMap[transaction.categoryId];
                        final paymentSource =
                            _paymentSourcesMap[transaction.paymentSourceId];

                        return _buildSearchResultItem(
                          transaction,
                          category,
                          paymentSource,
                          theme,
                          l10n,
                        );
                      }),
                      if (_searchResults.length >= 5)
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            l10n.showingTopResults,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchResultItem(
    Transaction transaction,
    CategoryItem? category,
    PaymentSource? paymentSource,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return InkWell(
      onTap: () => _navigateToTransactionDetails(transaction),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
        ),
        child: Row(
          children: [
            // Category icon
            CircleAvatar(
              radius: 16,
              backgroundColor:
                  category?.color.withValues(alpha: 0.2) ??
                  Colors.grey.withValues(alpha: 0.2),
              child: Icon(
                category?.icon ?? Icons.help_outline,
                color: category?.color ?? Colors.grey,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),

            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description with highlighting
                  HighlightedText(
                    text: transaction.description.isNotEmpty
                        ? transaction.description
                        : category?.name ?? l10n.unknown,
                    searchTerm: _currentSearchTerm,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Category and payment source with highlighting
                  Row(
                    children: [
                      Expanded(
                        child: HighlightedText(
                          text: category?.name ?? l10n.unknownCategory,
                          searchTerm: _currentSearchTerm,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ),
                      if (paymentSource != null) ...[
                        Text(
                          ' • ',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                        HighlightedText(
                          text: paymentSource.name,
                          searchTerm: _currentSearchTerm,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              '${transaction.isIncome ? '+' : '-'}${_formatAmount(transaction.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: transaction.isIncome ? Colors.green : Colors.red,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
