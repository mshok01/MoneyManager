import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../models/category_item.dart';
import '../models/payment_source.dart';
import '../services/transaction_service.dart';
import '../services/category_service.dart';
import '../services/payment_source_service.dart';
import '../services/user_service.dart';
import '../services/account_service.dart';
import '../utils/currency_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_providers.dart';

/// Exact theme definitions matching Figma's design tokens.
class _FigmaTheme {
  final Color sheet;
  final Color bg;
  final Color bg2;
  final Color text;
  final Color textSub;
  final Color textMuted;
  final Color handle;
  final Color border;
  final Color numKey;
  final Color numKeyText;
  final Color notesFieldBg;
  final Color tagTextInactive;
  final Color expenseAccent;
  final Color incomeAccent;

  const _FigmaTheme({
    required this.sheet,
    required this.bg,
    required this.bg2,
    required this.text,
    required this.textSub,
    required this.textMuted,
    required this.handle,
    required this.border,
    required this.numKey,
    required this.numKeyText,
    required this.notesFieldBg,
    required this.tagTextInactive,
    required this.expenseAccent,
    required this.incomeAccent,
  });

  factory _FigmaTheme.of(bool isDark) {
    if (isDark) {
      return const _FigmaTheme(
        sheet: Color(0xFF181818),
        bg: Color(0x0FFFFFFF), // rgba(255,255,255,0.06)
        bg2: Color(0x1AFFFFFF), // rgba(255,255,255,0.1)
        text: Color(0xFFF0F0F0),
        textSub: Color(0xFFA0A0A0),
        textMuted: Color(0xFF6B6B6B),
        handle: Color(0x26FFFFFF), // rgba(255,255,255,0.15)
        border: Color(0x14FFFFFF), // rgba(255,255,255,0.08)
        numKey: Color(0x12FFFFFF), // rgba(255,255,255,0.07)
        numKeyText: Color(0xFFF0F0F0),
        notesFieldBg: Color(0x0FFFFFFF),
        tagTextInactive: Color(0xFF6B6B6B),
        expenseAccent: Color(0xFFFF4D6D),
        incomeAccent: Color(0xFF00E5A0),
      );
    } else {
      return const _FigmaTheme(
        sheet: Color(0xFFFFFFFF),
        bg: Color(0xFFF5F5F7),
        bg2: Color(0xFFEBEBED),
        text: Color(0xFF111111),
        textSub: Color(0xFF6B6B70),
        textMuted: Color(0xFFADADB5),
        handle: Color(0x1F000000), // rgba(0,0,0,0.12)
        border: Color(0x12000000), // rgba(0,0,0,0.07)
        numKey: Color(0xFFEFEFEF),
        numKeyText: Color(0xFF111111),
        notesFieldBg: Color(0xFFF2F3F5),
        tagTextInactive: Color(0xFF8A8A96),
        expenseAccent: Color(0xFFE8294A),
        incomeAccent: Color(0xFF009E76),
      );
    }
  }
}

class AddEditTransactionScreen extends ConsumerWidget {
  final Account account;
  final Transaction? transaction;

  const AddEditTransactionScreen({
    super.key,
    required this.account,
    this.transaction,
  });

  /// Centralized push method.
  /// Change this implementation to toggle between Modal Bottom Sheet and Full Page Route.
  static Future<bool?> push(
    BuildContext context, {
    required Account account,
    Transaction? transaction,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.94,
      ),
      builder: (context) => AddEditTransactionContent(
        account: account,
        transaction: transaction,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final figmaTheme = _FigmaTheme.of(isDark);

    // Full screen fallback scaffold
    return Scaffold(
      backgroundColor: figmaTheme.sheet,
      body: AddEditTransactionContent(
        account: account,
        transaction: transaction,
      ),
    );
  }
}

class AddEditTransactionContent extends ConsumerStatefulWidget {
  final Account account;
  final Transaction? transaction;

  const AddEditTransactionContent({
    super.key,
    required this.account,
    this.transaction,
  });

  @override
  ConsumerState<AddEditTransactionContent> createState() =>
      _AddEditTransactionContentState();
}

class _AddEditTransactionContentState
    extends ConsumerState<AddEditTransactionContent> {
  final _amountController = TextEditingController(text: '0');
  final _descriptionController = TextEditingController();
  final List<String> _selectedTags = [];

  bool _isLoading = false;
  String _selectedType = TransactionType.expense; // Default to expense
  CategoryItem? _selectedCategory;
  PaymentSource? _selectedPaymentSource;
  Account? _selectedAccount;
  DateTime _selectedDate = DateTime.now();

  List<CategoryItem> _incomeCategories = [];
  List<CategoryItem> _expenseCategories = [];
  List<PaymentSource> _paymentSources = [];
  List<Account> _accounts = [];

  bool get _isEditing => widget.transaction != null;

  /// Get user's preferred currency for display
  String get _userCurrency {
    final currentUser = UserService.instance.currentUser;
    return currentUser?.currencyCode ?? widget.account.baseCurrency;
  }

  /// Get user's currency symbol for display
  String get _userCurrencySymbol {
    return CurrencyUtils.getCurrencySymbol(_userCurrency);
  }

  @override
  void initState() {
    super.initState();
    _selectedAccount = widget.account;
    _loadData();
    _initializeFields();
  }

  void _initializeFields() {
    if (_isEditing && widget.transaction != null) {
      final transaction = widget.transaction!;
      _amountController.text = transaction.amount.toString();
      _descriptionController.text = transaction.description;
      _selectedType = transaction.type;
      _selectedDate = transaction.transactionDateTime;
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      await TransactionService.instance.initialize();
      await CategoryService.instance.initialize();
      await PaymentSourceService.instance.initialize();
      await AccountService.instance.initialize();

      final incomeCategories = await CategoryService.instance.getIncomeCategories();
      final expenseCategories = await CategoryService.instance.getExpenseCategories();
      final paymentSources = await PaymentSourceService.instance.getAllPaymentSources();
      final activeAccounts = await AccountService.instance.activeAccounts;

      setState(() {
        _incomeCategories = incomeCategories;
        _expenseCategories = expenseCategories;
        _paymentSources = paymentSources;
        _accounts = activeAccounts;
        _isLoading = false;
      });

      if (_isEditing && widget.transaction != null) {
        final transaction = widget.transaction!;

        _selectedAccount = _accounts
            .where((acc) => acc.id == transaction.accountId)
            .firstOrNull ?? widget.account;

        final allCategories = [..._incomeCategories, ..._expenseCategories];
        _selectedCategory = allCategories
            .where((cat) => cat.id == transaction.categoryId)
            .firstOrNull;

        _selectedPaymentSource = _paymentSources
            .where((source) => source.id == transaction.paymentSourceId)
            .firstOrNull;

        setState(() {});
      } else {
        // Set default category and payment source
        if (_availableCategories.isNotEmpty) {
          _selectedCategory = _availableCategories.first;
        }
        if (_paymentSources.isNotEmpty) {
          _selectedPaymentSource = _paymentSources.first;
        }
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

  List<CategoryItem> get _availableCategories {
    return _selectedType == TransactionType.income
        ? _incomeCategories
        : _expenseCategories;
  }

  void _onNumpadPressed(String key) {
    String currentText = _amountController.text;

    if (key == 'del') {
      if (currentText.isNotEmpty) {
        setState(() {
          _amountController.text = currentText.length <= 1
              ? '0'
              : currentText.substring(0, currentText.length - 1);
        });
      }
    } else if (key == '.') {
      if (!currentText.contains('.')) {
        setState(() {
          _amountController.text = currentText.isEmpty ? '0.' : '$currentText.';
        });
      }
    } else {
      if (currentText == '0') {
        setState(() {
          _amountController.text = key;
        });
      } else {
        if (currentText.contains('.')) {
          final parts = currentText.split('.');
          if (parts[1].length >= 2) {
            return;
          }
        }
        setState(() {
          _amountController.text = currentText + key;
        });
      }
    }
  }

  Future<void> _saveTransaction() async {
    final l10n = AppLocalizations.of(context)!;
    final amountText = _amountController.text.trim();

    final amount = double.tryParse(amountText) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterValidAmount)),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectCategory)),
      );
      return;
    }

    if (_selectedType == TransactionType.expense && _selectedPaymentSource == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectPaymentSource)),
      );
      return;
    }

    final targetAccountId = _selectedAccount?.id ?? widget.account.id;

    setState(() => _isLoading = true);

    try {
      final description = _descriptionController.text.trim();

      final paymentSourceId = _selectedType == TransactionType.income
          ? 'bank_transfer'
          : _selectedPaymentSource!.id;

      if (_isEditing) {
        await TransactionService.instance.updateTransaction(
          widget.transaction!.id,
          accountId: targetAccountId,
          categoryId: _selectedCategory!.id,
          paymentSourceId: paymentSourceId,
          amount: amount,
          type: _selectedType,
          description: description,
          transactionDate: _selectedDate,
        );
      } else {
        await TransactionService.instance.createTransaction(
          accountId: targetAccountId,
          categoryId: _selectedCategory!.id,
          paymentSourceId: paymentSourceId,
          amount: amount,
          type: _selectedType,
          description: description,
          transactionDate: _selectedDate,
        );
      }

      _invalidateProviders(targetAccountId);
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? l10n.transactionUpdatedSuccessfully
                  : l10n.transactionCreatedSuccessfully,
            ),
          ),
        );
      }
    } catch (e) {
      _invalidateProviders(targetAccountId);
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToSaveTransaction(e.toString()))),
        );
      }
    }
  }

  void _invalidateProviders(String targetAccountId) {
    ref.invalidate(accountHasTransactionsProvider(targetAccountId));
    ref.invalidate(transactionSummaryProvider((accountId: targetAccountId, period: 'today')));
    ref.invalidate(transactionSummaryProvider((accountId: targetAccountId, period: 'month')));
    ref.invalidate(transactionSummaryProvider((accountId: targetAccountId, period: 'year')));
    ref.invalidate(accountTransactionsProvider(targetAccountId));
    ref.invalidate(accountBalanceProvider(targetAccountId));

    if (widget.account.id != targetAccountId) {
      ref.invalidate(accountHasTransactionsProvider(widget.account.id));
      ref.invalidate(transactionSummaryProvider((accountId: widget.account.id, period: 'today')));
      ref.invalidate(transactionSummaryProvider((accountId: widget.account.id, period: 'month')));
      ref.invalidate(transactionSummaryProvider((accountId: widget.account.id, period: 'year')));
      ref.invalidate(accountTransactionsProvider(widget.account.id));
      ref.invalidate(accountBalanceProvider(widget.account.id));
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isAfter(today) ? today : _selectedDate,
      firstDate: DateTime(2020),
      lastDate: today,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
          _selectedDate.second,
        );
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = _FigmaTheme.of(isDark);

    final isExpense = _selectedType == TransactionType.expense;
    final accentColor = isExpense ? theme.expenseAccent : theme.incomeAccent;

    return Container(
      decoration: BoxDecoration(
        color: theme.sheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: isDark ? Border.all(color: theme.border) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.18),
            blurRadius: 40,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _isLoading && !_isEditing
              ? SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Drag Handle
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.handle,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),

                      // Header Row
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _isEditing ? l10n.editTransactionTitle : l10n.addTransaction,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: theme.text,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: theme.bg,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: theme.border),
                                ),
                                child: Icon(Icons.close, color: theme.textSub, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Segmented Button Toggle (Income vs. Expense)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0x0DFFFFFF) : theme.bg,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildTypeToggleOption(
                                type: TransactionType.expense,
                                label: "↑  Expense",
                                isActive: isExpense,
                                activeColor: theme.expenseAccent,
                                theme: theme,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: _buildTypeToggleOption(
                                type: TransactionType.income,
                                label: "↓  Income",
                                isActive: !isExpense,
                                activeColor: theme.incomeAccent,
                                theme: theme,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Amount Card Container
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0x0DFFFFFF) : theme.bg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Text(
                              isExpense ? "EXPENSE AMOUNT" : "INCOME AMOUNT",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: theme.textMuted,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    _userCurrencySymbol,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w300,
                                      color: accentColor,
                                      height: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _amountController.text,
                                  style: TextStyle(
                                    fontSize: 64,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -2,
                                    height: 1,
                                    color: isDark
                                        ? (isExpense ? const Color(0xFFF0F0F0) : const Color(0xFF00E5A0))
                                        : theme.text,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 2,
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Custom Keyboard Numpad
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildNumpad(theme, accentColor),
                      ),

                      // Divider below numpad
                      Container(
                        height: 1,
                        margin: const EdgeInsets.only(bottom: 20),
                        color: isDark ? const Color(0x0FFFFFFF) : theme.border,
                      ),

                      // Category Pill Wrap Selection
                      _buildSectionHeader("CATEGORY", theme.textMuted),
                      const SizedBox(height: 10),
                      _buildCategoryWrap(theme, accentColor, isDark),
                      const SizedBox(height: 20),

                      // Payment Source Pill Wrap Selection (Only for Expenses)
                      if (isExpense) ...[
                        _buildSectionHeader("PAYMENT SOURCE", theme.textMuted),
                        const SizedBox(height: 10),
                        _buildPaymentSourceWrap(theme, isDark),
                        const SizedBox(height: 20),
                      ],

                      // Date Selection
                      _buildSectionHeader("DATE", theme.textMuted),
                      const SizedBox(height: 10),
                      _buildDateSelector(theme, accentColor, isDark),
                      const SizedBox(height: 20),

                      // Notes with quick hashtags
                      _buildNotesAndTagsField(theme, accentColor, isDark),
                      const SizedBox(height: 36),

                      // Submit CTA Button
                      _buildSubmitCTAButton(l10n, accentColor, isExpense),
                      const SizedBox(height: 36),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTypeToggleOption({
    required String type,
    required String label,
    required bool isActive,
    required Color activeColor,
    required _FigmaTheme theme,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          if (_availableCategories.isNotEmpty) {
            _selectedCategory = _availableCategories.first;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.27),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : theme.textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String label, Color color) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.9,
      ),
    );
  }

  Widget _buildNumpadButton({
    required String keyVal,
    required _FigmaTheme theme,
    required Color accentColor,
    IconData? icon,
  }) {
    final isDel = keyVal == 'del';
    final bg = isDel ? accentColor.withValues(alpha: 0.08) : theme.numKey;
    final border = isDel ? accentColor.withValues(alpha: 0.19) : theme.border;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 54,
        child: InkWell(
          onTap: () => _onNumpadPressed(keyVal),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: 1),
            ),
            child: Center(
              child: icon != null
                  ? Icon(icon, color: accentColor, size: 20)
                  : Text(
                      keyVal,
                      style: TextStyle(
                        color: theme.numKeyText,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumpadRow(List<String> keys, _FigmaTheme theme, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: keys.map((key) {
          if (key == 'del') {
            return _buildNumpadButton(
              keyVal: key,
              theme: theme,
              accentColor: accentColor,
              icon: Icons.backspace_outlined,
            );
          }
          return _buildNumpadButton(keyVal: key, theme: theme, accentColor: accentColor);
        }).toList(),
      ),
    );
  }

  Widget _buildNumpad(_FigmaTheme theme, Color accentColor) {
    return Column(
      children: [
        _buildNumpadRow(['1', '2', '3'], theme, accentColor),
        _buildNumpadRow(['4', '5', '6'], theme, accentColor),
        _buildNumpadRow(['7', '8', '9'], theme, accentColor),
        _buildNumpadRow(['.', '0', 'del'], theme, accentColor),
      ],
    );
  }

  Widget _buildCategoryWrap(_FigmaTheme theme, Color accentColor, bool isDark) {
    final categories = _availableCategories;
    if (categories.isEmpty) {
      return Text("No categories configured", style: TextStyle(color: theme.textMuted));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final isSelected = _selectedCategory?.id == cat.id;

        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor.withValues(alpha: isDark ? 0.09 : 0.08)
                  : (isDark ? const Color(0x0FFFFFFF) : theme.bg),
              border: Border.all(
                color: isSelected
                    ? accentColor.withValues(alpha: 0.33)
                    : Colors.transparent,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              cat.name,
              style: TextStyle(
                color: isSelected ? accentColor : theme.textSub,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentSourceWrap(_FigmaTheme theme, bool isDark) {
    if (_paymentSources.isEmpty) {
      return Text("No payment sources configured", style: TextStyle(color: theme.textMuted));
    }

    const sourceAccent = Color(0xFF0077B6);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _paymentSources.map((source) {
        final isSelected = _selectedPaymentSource?.id == source.id;

        return GestureDetector(
          onTap: () => setState(() => _selectedPaymentSource = source),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? sourceAccent.withValues(alpha: isDark ? 0.09 : 0.08)
                  : (isDark ? const Color(0x0FFFFFFF) : theme.bg),
              border: Border.all(
                color: isSelected
                    ? sourceAccent.withValues(alpha: 0.33)
                    : Colors.transparent,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              source.name,
              style: TextStyle(
                color: isSelected ? sourceAccent : theme.textSub,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateSelector(_FigmaTheme theme, Color accentColor, bool isDark) {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: isDark ? const Color(0x0FFFFFFF) : theme.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: accentColor,
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(
              _getFormattedDate(_selectedDate),
              style: TextStyle(
                color: theme.text,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(Icons.unfold_more, color: theme.textMuted, size: 16),
          ],
        ),
      ),
    );
  }

  String _getFormattedDate(DateTime date) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  Widget _buildNotesAndTagsField(_FigmaTheme theme, Color accentColor, bool isDark) {
    final tags = ['#business', '#family', '#subscription', '#urgent', '#tax', '#personal'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            _buildSectionHeader("NOTES", theme.textMuted),
            const SizedBox(width: 4),
            Text(
              "· optional",
              style: TextStyle(
                fontSize: 10,
                color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFC0C0C8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.notesFieldBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.transparent, width: 1.5),
          ),
          child: TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            style: TextStyle(color: theme.text, fontSize: 13, height: 1.6),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: "Add a note, memo, or reference…",
              hintStyle: TextStyle(color: theme.textMuted, fontSize: 13),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) {
            final isTagSelected = _selectedTags.contains(tag);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isTagSelected) {
                    _selectedTags.remove(tag);
                  } else {
                    _selectedTags.add(tag);
                    String currentText = _descriptionController.text.trim();
                    if (!currentText.contains(tag)) {
                      _descriptionController.text =
                          currentText.isEmpty ? tag : "$currentText $tag";
                    }
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: isTagSelected
                      ? accentColor.withValues(alpha: 0.09)
                      : (isDark ? const Color(0x12FFFFFF) : theme.notesFieldBg),
                  border: Border.all(
                    color: isTagSelected
                        ? accentColor.withValues(alpha: 0.33)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: isTagSelected ? accentColor : theme.tagTextInactive,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubmitCTAButton(AppLocalizations l10n, Color accentColor, bool isExpense) {
    final double? amount = double.tryParse(_amountController.text);
    final String amountStr = amount != null
        ? "$_userCurrencySymbol${amount.toStringAsFixed(2)}"
        : "${_userCurrencySymbol}0.00";
    final String actionText = isExpense ? "Add Expense" : "Add Income";

    return InkWell(
      onTap: _saveTransaction,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: accentColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.33),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                "$actionText · $amountStr",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
