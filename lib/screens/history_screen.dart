import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
import 'transaction_details_screen.dart';

// ── Figma Design Theme Tokens ────────────────────────────────────────────────
class _HistoryTheme {
  final bool isDark;
  final Color bg;
  final Color sheet;
  final Color surface;
  final Color surfaceBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color searchBg;
  final Color searchBorder;
  final Color pillInactiveBg;
  final Color pillInactiveText;
  final Color expenseAccent;
  final Color incomeAccent;
  final Color cyanAccent;
  final Color purpleAccent;
  final Color amberAccent;

  _HistoryTheme._({
    required this.isDark,
    required this.bg,
    required this.sheet,
    required this.surface,
    required this.surfaceBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.searchBg,
    required this.searchBorder,
    required this.pillInactiveBg,
    required this.pillInactiveText,
    required this.expenseAccent,
    required this.incomeAccent,
    required this.cyanAccent,
    required this.purpleAccent,
    required this.amberAccent,
  });

  factory _HistoryTheme.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return _HistoryTheme._(
        isDark: true,
        bg: const Color(0xFF121212),
        sheet: const Color(0xFF181818),
        surface: const Color(0x0AFFFFFF), // rgba(255,255,255,0.04)
        surfaceBorder: const Color(0x12FFFFFF), // rgba(255,255,255,0.07)
        textPrimary: const Color(0xFFF0F0F0),
        textSecondary: const Color(0xFFA0A0A0),
        textMuted: const Color(0xFF6B6B6B),
        searchBg: const Color(0x0DFFFFFF), // rgba(255,255,255,0.05)
        searchBorder: const Color(0x17FFFFFF), // rgba(255,255,255,0.09)
        pillInactiveBg: const Color(0x12FFFFFF), // rgba(255,255,255,0.07)
        pillInactiveText: const Color(0xFF6B6B6B),
        expenseAccent: const Color(0xFFFF4D6D),
        incomeAccent: const Color(0xFF00E5A0),
        cyanAccent: const Color(0xFF00B4D8),
        purpleAccent: const Color(0xFFA78BFA),
        amberAccent: const Color(0xFFF59E0B),
      );
    } else {
      return _HistoryTheme._(
        isDark: false,
        bg: const Color(0xFFF5F5F7),
        sheet: const Color(0xFFFFFFFF),
        surface: const Color(0xFFFFFFFF),
        surfaceBorder: const Color(0x10000000), // rgba(0,0,0,0.06)
        textPrimary: const Color(0xFF111111),
        textSecondary: const Color(0xFF6B6B70),
        textMuted: const Color(0xFF8E8E93),
        searchBg: const Color(0xFFEBEBED),
        searchBorder: const Color(0x14000000),
        pillInactiveBg: const Color(0xFFEBEBED),
        pillInactiveText: const Color(0xFF6B6B70),
        expenseAccent: const Color(0xFFE8294A),
        incomeAccent: const Color(0xFF009E76),
        cyanAccent: const Color(0xFF0096B4),
        purpleAccent: const Color(0xFF8B6EB8),
        amberAccent: const Color(0xFFD97706),
      );
    }
  }
}

// ── Filter State Model ───────────────────────────────────────────────────────
class _HistoryFilters {
  String type; // 'all', 'income', 'expense'
  int? year;
  int? month; // 1-12
  Set<String> categories;
  Set<String> sources;

  _HistoryFilters({
    this.type = 'all',
    this.year,
    this.month,
    Set<String>? categories,
    Set<String>? sources,
  })  : categories = categories ?? {},
        sources = sources ?? {};

  _HistoryFilters clone() {
    return _HistoryFilters(
      type: type,
      year: year,
      month: month,
      categories: Set<String>.from(categories),
      sources: Set<String>.from(sources),
    );
  }

  int get activeCount {
    int count = 0;
    if (year != null) count++;
    if (month != null) count++;
    count += categories.length;
    count += sources.length;
    return count;
  }
}

// ── History Screen ───────────────────────────────────────────────────────────
class HistoryScreen extends StatefulWidget {
  final Account account;
  final int? initialYear;
  final int? initialMonth;
  final String? initialType;
  final bool isEmbedded;

  const HistoryScreen({
    super.key,
    required this.account,
    this.initialYear,
    this.initialMonth,
    this.initialType,
    this.isEmbedded = false,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Transaction> _transactions = [];
  Map<String, CategoryItem> _categoriesMap = {};
  Map<String, PaymentSource> _paymentSourcesMap = {};
  bool _isLoading = true;

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late final _HistoryFilters _filters;

  static const List<String> _monthsOrder = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _filters = _HistoryFilters(
      type: widget.initialType ?? 'all',
      year: widget.initialYear,
      month: widget.initialMonth,
    );
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
      final transactions = await TransactionService.instance
          .getAccountTransactions(widget.account.id);
      final incomeCategories = await CategoryService.instance
          .getIncomeCategories();
      final expenseCategories = await CategoryService.instance
          .getExpenseCategories();
      final paymentSources = await PaymentSourceService.instance
          .getAllPaymentSources();

      final categoriesMap = <String, CategoryItem>{};
      for (final category in [...incomeCategories, ...expenseCategories]) {
        categoriesMap[category.id] = category;
      }

      final paymentSourcesMap = <String, PaymentSource>{};
      for (final source in paymentSources) {
        paymentSourcesMap[source.id] = source;
      }

      if (mounted) {
        setState(() {
          _transactions = transactions;
          _categoriesMap = categoriesMap;
          _paymentSourcesMap = paymentSourcesMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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

  String _formatCurrency(double amount) {
    final currentUser = UserService.instance.currentUser;
    final userCurrency =
        currentUser?.currencyCode ?? widget.account.baseCurrency;
    final currencySymbol = CurrencyUtils.getCurrencySymbol(userCurrency);
    final formatter = NumberFormat('#,##0.00');
    return '$currencySymbol${formatter.format(amount)}';
  }

  List<Transaction> get _filteredTransactions {
    return _transactions.where((tx) {
      // Type Filter
      if (_filters.type == 'income' && !tx.isIncome) return false;
      if (_filters.type == 'expense' && tx.isIncome) return false;

      // Year Filter
      if (_filters.year != null && tx.transactionDateTime.year != _filters.year) {
        return false;
      }

      // Month Filter
      if (_filters.month != null &&
          tx.transactionDateTime.month != _filters.month) {
        return false;
      }

      // Category Filter
      if (_filters.categories.isNotEmpty &&
          !_filters.categories.contains(tx.categoryId)) {
        return false;
      }

      // Source Filter
      if (_filters.sources.isNotEmpty &&
          !_filters.sources.contains(tx.paymentSourceId)) {
        return false;
      }

      // Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final desc = tx.description.toLowerCase();
        final catName =
            _categoriesMap[tx.categoryId]?.name.toLowerCase() ?? '';
        final srcName =
            _paymentSourcesMap[tx.paymentSourceId]?.name.toLowerCase() ?? '';

        if (!desc.contains(query) &&
            !catName.contains(query) &&
            !srcName.contains(query)) {
          return false;
        }
      }

      return true;
    }).toList()
      ..sort((a, b) => b.transactionDateTime.compareTo(a.transactionDateTime));
  }

  /// Groups transactions by "MONTH YYYY" (e.g. "AUGUST 2026")
  Map<String, List<Transaction>> get _groupedSections {
    final Map<String, List<Transaction>> groups = {};
    for (final tx in _filteredTransactions) {
      final monthName = _monthsOrder[tx.transactionDateTime.month - 1];
      final key = '$monthName ${tx.transactionDateTime.year}';
      groups.putIfAbsent(key, () => []).add(tx);
    }
    return groups;
  }

  void _openFilterSheet(_HistoryTheme theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _HistoryFilterSheetWidget(
        filters: _filters,
        transactions: _transactions,
        categoriesMap: _categoriesMap,
        paymentSourcesMap: _paymentSourcesMap,
        theme: theme,
        onApply: (newFilters) {
          setState(() {
            _filters.type = newFilters.type;
            _filters.year = newFilters.year;
            _filters.month = newFilters.month;
            _filters.categories = newFilters.categories;
            _filters.sources = newFilters.sources;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _HistoryTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final activeCount = _filters.activeCount;
    final sections = _groupedSections;

    return Scaffold(
      backgroundColor: theme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Fixed Top Header ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Title Row
                  Row(
                    children: [
                      if (Navigator.of(context).canPop() && !widget.isEmbedded)
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 36,
                            height: 36,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: theme.pillInactiveBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: theme.textPrimary,
                            ),
                          ),
                        ),
                      Text(
                        l10n.history,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: theme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Search Bar
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: theme.searchBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.searchBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, size: 18, color: theme.textMuted),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val.trim();
                              });
                            },
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search transactions…',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: theme.textMuted,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: theme.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Pills Row (All / Income / Expense + Filter Button)
                  Row(
                    children: [
                      _buildTypePill('all', 'All', theme),
                      const SizedBox(width: 8),
                      _buildTypePill('income', l10n.income, theme),
                      const SizedBox(width: 8),
                      _buildTypePill('expense', l10n.expensesTab, theme),
                      const Spacer(),

                      // Filter Icon Button
                      GestureDetector(
                        onTap: () => _openFilterSheet(theme),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: activeCount > 0
                                    ? theme.incomeAccent.withValues(alpha: 0.12)
                                    : theme.pillInactiveBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: activeCount > 0
                                      ? theme.incomeAccent.withValues(alpha: 0.35)
                                      : theme.surfaceBorder,
                                ),
                              ),
                              child: Icon(
                                Icons.tune_rounded,
                                size: 18,
                                color: activeCount > 0
                                    ? theme.incomeAccent
                                    : theme.textSecondary,
                              ),
                            ),
                            if (activeCount > 0)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: theme.incomeAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$activeCount',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0A1A14),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Active Filter Tags Row
                  if (activeCount > 0) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (_filters.year != null)
                          _buildRemovableTag(
                            label: '${_filters.year}',
                            color: theme.cyanAccent,
                            onRemove: () => setState(() => _filters.year = null),
                          ),
                        if (_filters.month != null)
                          _buildRemovableTag(
                            label: _monthsOrder[_filters.month! - 1],
                            color: theme.cyanAccent,
                            onRemove: () => setState(() => _filters.month = null),
                          ),
                        ..._filters.categories.map((catId) {
                          final cat = _categoriesMap[catId];
                          return _buildRemovableTag(
                            label: cat?.name ?? catId,
                            color: theme.purpleAccent,
                            onRemove: () => setState(
                              () => _filters.categories.remove(catId),
                            ),
                          );
                        }),
                        ..._filters.sources.map((srcId) {
                          final src = _paymentSourcesMap[srcId];
                          return _buildRemovableTag(
                            label: src?.name ?? srcId,
                            color: theme.amberAccent,
                            onRemove: () => setState(
                              () => _filters.sources.remove(srcId),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // ── Scrollable Transaction List ────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : sections.isEmpty
                      ? Center(
                          child: Text(
                            l10n.noTransactionsFound,
                            style: TextStyle(
                              fontSize: 15,
                              color: theme.textMuted,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
                          itemCount: sections.length,
                          itemBuilder: (context, sectionIndex) {
                            final sectionKey =
                                sections.keys.elementAt(sectionIndex);
                            final txList = sections[sectionKey]!;

                            // Calculate section net total
                            final double monthTotal = txList.fold(
                              0.0,
                              (sum, t) => sum + (t.isIncome ? t.amount : -t.amount),
                            );

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Month Year Section Header
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 10,
                                      left: 2,
                                      right: 2,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          sectionKey.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.8,
                                            color: theme.textMuted,
                                          ),
                                        ),
                                        Text(
                                          '${monthTotal >= 0 ? '+' : ''}${_formatCurrency(monthTotal.abs())}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: monthTotal >= 0
                                                ? theme.incomeAccent
                                                : theme.expenseAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Month Card Container
                                  Container(
                                    decoration: BoxDecoration(
                                      color: theme.surface,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: theme.surfaceBorder,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Column(
                                        children: [
                                          for (int i = 0; i < txList.length; i++) ...[
                                            _buildTransactionTile(
                                              txList[i],
                                              theme,
                                            ),
                                            if (i < txList.length - 1)
                                              Divider(
                                                height: 1,
                                                indent: 66,
                                                color: theme.surfaceBorder,
                                              ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  /// Quick Type Pill (All / Income / Expense)
  Widget _buildTypePill(String key, String label, _HistoryTheme theme) {
    final isSelected = _filters.type == key;
    Color activeBg = theme.isDark ? const Color(0xFFF0F0F0) : const Color(0xFF111111);
    Color activeText = theme.isDark ? const Color(0xFF111111) : const Color(0xFFFFFFFF);

    if (key == 'income') {
      activeBg = theme.incomeAccent;
      activeText = const Color(0xFF0A1A14);
    } else if (key == 'expense') {
      activeBg = theme.expenseAccent;
      activeText = Colors.white;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _filters.type = key;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : theme.pillInactiveBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? activeText : theme.pillInactiveText,
          ),
        ),
      ),
    );
  }

  /// Active Removable Tag Chip
  Widget _buildRemovableTag({
    required String label,
    required Color color,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 12, color: color),
          ),
        ],
      ),
    );
  }

  /// Transaction List Tile
  Widget _buildTransactionTile(Transaction tx, _HistoryTheme theme) {
    final category = _categoriesMap[tx.categoryId];
    final paymentSource = _paymentSourcesMap[tx.paymentSourceId];
    final dateFormatted = DateFormat('MMM d').format(tx.transactionDateTime);

    return InkWell(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TransactionDetailsScreen(
              transaction: tx,
              account: widget.account,
            ),
          ),
        );
        _loadData();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            // Category Icon Badge (38x38)
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: theme.pillInactiveBg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                category?.icon ?? Icons.receipt_long_rounded,
                size: 18,
                color: category?.color ?? theme.textSecondary,
              ),
            ),
            const SizedBox(width: 12),

            // Middle Description & Subline
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.description.isNotEmpty
                        ? tx.description
                        : (category?.name ?? 'Transaction'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: theme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        dateFormatted,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.textMuted,
                        ),
                      ),
                      if (category != null) ...[
                        _buildDot(theme),
                        Flexible(
                          child: Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      if (paymentSource != null) ...[
                        _buildDot(theme),
                        Flexible(
                          child: Text(
                            paymentSource.name,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Amount
            Text(
              '${tx.isIncome ? '+' : '-'}${_formatCurrency(tx.amount)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: tx.isIncome ? theme.incomeAccent : theme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(_HistoryTheme theme) {
    return Container(
      width: 3,
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: theme.textMuted.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
    );
  }
}

// ── Filter Sheet Bottom Modal ────────────────────────────────────────────────
class _HistoryFilterSheetWidget extends StatefulWidget {
  final _HistoryFilters filters;
  final List<Transaction> transactions;
  final Map<String, CategoryItem> categoriesMap;
  final Map<String, PaymentSource> paymentSourcesMap;
  final _HistoryTheme theme;
  final ValueChanged<_HistoryFilters> onApply;

  const _HistoryFilterSheetWidget({
    required this.filters,
    required this.transactions,
    required this.categoriesMap,
    required this.paymentSourcesMap,
    required this.theme,
    required this.onApply,
  });

  @override
  State<_HistoryFilterSheetWidget> createState() =>
      _HistoryFilterSheetWidgetState();
}

class _HistoryFilterSheetWidgetState extends State<_HistoryFilterSheetWidget> {
  late _HistoryFilters _local;
  late List<int> _availableYears;

  static const List<String> _monthsOrder = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _local = widget.filters.clone();

    // Extract ONLY years for which transactions exist
    final Set<int> yearsSet = {};
    for (final tx in widget.transactions) {
      yearsSet.add(tx.transactionDateTime.year);
    }
    _availableYears = yearsSet.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final l10n = AppLocalizations.of(context)!;
    final activeCount = _local.activeCount;

    return Container(
      decoration: BoxDecoration(
        color: theme.sheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: theme.isDark ? Border.all(color: theme.surfaceBorder) : null,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: theme.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Header (Filters title, Reset button, Close button)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        // Reset Button
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _local = _HistoryFilters();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.expenseAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.expenseAccent.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Text(
                              'Reset',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.expenseAccent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Close Button
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: theme.pillInactiveBg,
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.surfaceBorder),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: theme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Filter Body
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Transaction Type
                    _buildSectionHeader('TRANSACTION TYPE', theme),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildPill(
                          label: 'All',
                          active: _local.type == 'all',
                          color: theme.textSecondary,
                          theme: theme,
                          onTap: () => setState(() => _local.type = 'all'),
                        ),
                        _buildPill(
                          label: l10n.income,
                          active: _local.type == 'income',
                          color: theme.incomeAccent,
                          theme: theme,
                          onTap: () => setState(() => _local.type = 'income'),
                        ),
                        _buildPill(
                          label: l10n.expensesTab,
                          active: _local.type == 'expense',
                          color: theme.expenseAccent,
                          theme: theme,
                          onTap: () => setState(() => _local.type = 'expense'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 2. Year (only show if transactions exist)
                    if (_availableYears.isNotEmpty) ...[
                      _buildSectionHeader('YEAR', theme),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableYears.map((y) {
                          final isSelected = _local.year == y;
                          return _buildPill(
                            label: '$y',
                            active: isSelected,
                            color: theme.cyanAccent,
                            theme: theme,
                            onTap: () {
                              setState(() {
                                _local.year = isSelected ? null : y;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // 3. Month
                    _buildSectionHeader(
                      'MONTH ${_local.year != null ? '(${_local.year})' : ''}',
                      theme,
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(12, (index) {
                        final monthNum = index + 1;
                        final isSelected = _local.month == monthNum;
                        return _buildPill(
                          label: _monthsOrder[index],
                          active: isSelected,
                          color: theme.cyanAccent,
                          theme: theme,
                          onTap: () {
                            setState(() {
                              _local.month = isSelected ? null : monthNum;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // 4. Categories
                    if (widget.categoriesMap.isNotEmpty) ...[
                      _buildSectionHeader('CATEGORY', theme),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.categoriesMap.values.map((cat) {
                          final isSelected = _local.categories.contains(cat.id);
                          return _buildPill(
                            label: cat.name,
                            active: isSelected,
                            color: theme.purpleAccent,
                            theme: theme,
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _local.categories.remove(cat.id);
                                } else {
                                  _local.categories.add(cat.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // 5. Payment Source
                    if (widget.paymentSourcesMap.isNotEmpty) ...[
                      _buildSectionHeader('PAYMENT SOURCE', theme),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.paymentSourcesMap.values.map((src) {
                          final isSelected = _local.sources.contains(src.id);
                          return _buildPill(
                            label: src.name,
                            active: isSelected,
                            color: theme.amberAccent,
                            theme: theme,
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _local.sources.remove(src.id);
                                } else {
                                  _local.sources.add(src.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ],
                ),
              ),

              // Apply Filters CTA Button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: GestureDetector(
                  onTap: () {
                    widget.onApply(_local);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: theme.incomeAccent,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: theme.incomeAccent.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Apply Filters${activeCount > 0 ? ' ($activeCount)' : ''}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0A1A14),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String label, _HistoryTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: theme.textMuted,
        ),
      ),
    );
  }

  Widget _buildPill({
    required String label,
    required bool active,
    required Color color,
    required _HistoryTheme theme,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.15) : theme.pillInactiveBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? color.withValues(alpha: 0.45) : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? color : theme.pillInactiveText,
          ),
        ),
      ),
    );
  }
}
