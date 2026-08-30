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
    // -------------------------------------------------------------
    // To switch back to a Full Screen Page Route in the future,
    // uncomment the block below and comment out the Bottom Sheet block.
    // -------------------------------------------------------------
    /*
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF181818) : const Color(0xFFFFFFFF);
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: sheetBg,
          body: AddEditTransactionContent(
            account: account,
            transaction: transaction,
          ),
        ),
      ),
    );
    */

    // Bottom Sheet Implementation (Default):
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
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
    final sheetBg = isDark ? const Color(0xFF181818) : const Color(0xFFFFFFFF);

    // Full screen fallback scaffold
    return Scaffold(
      backgroundColor: sheetBg,
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
      // Initialize services
      await TransactionService.instance.initialize();
      await CategoryService.instance.initialize();
      await PaymentSourceService.instance.initialize();
      await AccountService.instance.initialize();

      // Load data lists
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

      // Set initial selections for editing or account defaults
      if (_isEditing && widget.transaction != null) {
        final transaction = widget.transaction!;

        // Find and set selected account
        _selectedAccount = _accounts
            .where((acc) => acc.id == transaction.accountId)
            .firstOrNull ?? widget.account;

        // Find and set selected category
        final allCategories = [..._incomeCategories, ..._expenseCategories];
        _selectedCategory = allCategories
            .where((cat) => cat.id == transaction.categoryId)
            .firstOrNull;

        // Find and set selected payment source
        _selectedPaymentSource = _paymentSources
            .where((source) => source.id == transaction.paymentSourceId)
            .firstOrNull;

        setState(() {});
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

    if (key == 'backspace') {
      if (currentText.isNotEmpty) {
        setState(() {
          _amountController.text = currentText.substring(0, currentText.length - 1);
          if (_amountController.text.isEmpty) {
            _amountController.text = '0';
          }
        });
      }
    } else if (key == '.') {
      if (!currentText.contains('.')) {
        setState(() {
          _amountController.text = currentText.isEmpty ? '0.' : '$currentText.';
        });
      }
    } else {
      // Digit key pressed
      if (currentText == '0') {
        setState(() {
          _amountController.text = key;
        });
      } else {
        // Limit fractional part to 2 decimal places
        if (currentText.contains('.')) {
          final parts = currentText.split('.');
          if (parts[1].length >= 2) {
            return; // Reject additional numbers
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

    // Validate payment source for expenses
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

      // Income defaults to 'bank_transfer'
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
        Navigator.of(context).pop(true); // Indication of success
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

    // Also invalidate origin account if switched during edit
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
      lastDate: today, // Constraints
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

    final isExpense = _selectedType == TransactionType.expense;

    // FIGMA Design Tokens (Extracted programmatically from mock pixels)
    final expenseColor = const Color(0xFFFF4D6D); // Figma pinkish red
    final incomeColor = const Color(0xFF20C997);  // Figma green/teal
    final accentColor = isExpense ? expenseColor : incomeColor;

    final sheetBg = isDark ? const Color(0xFF181818) : const Color(0xFFFFFFFF);
    final surfaceBg = isDark ? const Color(0xFF212121) : const Color(0xFFF5F5F5);
    final toggleBg = isDark ? const Color(0xFF212121) : const Color(0xFFF5F5F5);
    final toggleBorderColor = isDark ? const Color(0xFF323232) : const Color(0xFFE5E5E5);

    final textPrimary = isDark ? const Color(0xFFF0F0F0) : const Color(0xFF1A1A1A);
    final textSecondary = isDark ? const Color(0xFF888888) : const Color(0xFF757575);

    // Active Toggle Segment Backgrounds
    final activeBg = isExpense
        ? (isDark ? const Color(0xFF4B292F) : const Color(0xFFFFEEF0))
        : (isDark ? const Color(0xFF1E3129) : const Color(0xFFE6FCF5));

    final activeBorder = isExpense
        ? (isDark ? const Color(0xFF5D2E36) : const Color(0xFFFFD1D6))
        : (isDark ? const Color(0xFF2C4C3E) : const Color(0xFFC3FBEF));

    return Material(
      color: sheetBg,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SafeArea(
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Sheet Handle Drag bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Sheet Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isEditing ? l10n.editTransactionTitle : l10n.addTransaction,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF242424) : const Color(0xFFF0F0F0),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close, color: textPrimary, size: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Segmented Button Toggle (Income vs. Expense)
                      Container(
                        decoration: BoxDecoration(
                          color: toggleBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: toggleBorderColor,
                            width: 1.2,
                          ),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildTypeButton(
                                TransactionType.expense,
                                "↑ Expense",
                                isExpense,
                                activeBg,
                                activeBorder,
                                expenseColor,
                                textSecondary,
                              ),
                            ),
                            Expanded(
                              child: _buildTypeButton(
                                TransactionType.income,
                                "↓ Income",
                                !isExpense,
                                activeBg,
                                activeBorder,
                                incomeColor,
                                textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Amount Text Display & Mode Indicator
                      Center(
                        child: Column(
                          children: [
                            Text(
                              isExpense ? "EXPENSE" : "INCOME",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textSecondary,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  _userCurrencySymbol,
                                  style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w500,
                                      color: accentColor),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _amountController.text,
                                  style: TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Divider(color: accentColor, thickness: 1.5, height: 1),
                      const SizedBox(height: 20),

                      // Custom Keyboard Numpad
                      _buildNumpad(isDark, textPrimary, surfaceBg),
                      const SizedBox(height: 24),

                      // Category Pill Wrap Selection
                      _buildSectionHeader("CATEGORY", textSecondary),
                      const SizedBox(height: 10),
                      _buildCategoryWrap(isDark, surfaceBg),
                      const SizedBox(height: 24),

                      // Payment Source Pill Wrap Selection (Only for Expenses)
                      if (isExpense) ...[
                        _buildSectionHeader("PAYMENT SOURCE", textSecondary),
                        const SizedBox(height: 10),
                        _buildPaymentSourceWrap(isDark, surfaceBg),
                        const SizedBox(height: 24),
                      ],

                      /*
                      // Account Selection Pills
                      _buildSectionHeader("ACCOUNT", textSecondary),
                      const SizedBox(height: 10),
                      _buildAccountWrap(isDark, surfaceBg),
                      const SizedBox(height: 24),
                      */

                      // Date Selection row picker
                      _buildDateSelector(isDark, textPrimary, textSecondary, accentColor, surfaceBg),
                      const SizedBox(height: 24),

                      /*
                      // Future feature - Recurring schedule row switcher
                      _buildRecurringToggleSwitch(isDark, textPrimary, textSecondary, accentColor, surfaceBg),
                      const SizedBox(height: 24),
                      */

                      // Notes details inputs with tag chips
                      _buildNotesAndTagsField(isDark, textPrimary, textSecondary, surfaceBg),
                      const SizedBox(height: 36),

                      // Submit CTA Button
                      _buildSubmitCTAButton(l10n, isDark, accentColor, activeBg),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(
    String type,
    String label,
    bool isActive,
    Color activeBg,
    Color activeBorder,
    Color activeText,
    Color textSecondary,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          _selectedCategory = null;
          _selectedPaymentSource = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: isActive
            ? BoxDecoration(
                color: activeBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: activeBorder, width: 1.5),
              )
            : const BoxDecoration(),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? activeText : textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String label, Color textSecondary) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: textSecondary,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildNumpadButton(
    String label,
    bool isDark,
    Color textPrimary,
    Color surfaceBg, {
    IconData? icon,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        height: 58,
        child: InkWell(
          onTap: () => _onNumpadPressed(label),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: surfaceBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: icon != null
                  ? Icon(icon, color: textPrimary, size: 22)
                  : Text(
                      label,
                      style: TextStyle(
                        color: textPrimary,
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

  Widget _buildNumpadRow(List<String> keys, bool isDark, Color textPrimary, Color surfaceBg) {
    return Row(
      children: keys.map((key) {
        if (key == 'backspace') {
          return _buildNumpadButton(key, isDark, textPrimary, surfaceBg, icon: Icons.backspace_outlined);
        }
        return _buildNumpadButton(key, isDark, textPrimary, surfaceBg);
      }).toList(),
    );
  }

  Widget _buildNumpad(bool isDark, Color textPrimary, Color surfaceBg) {
    return Column(
      children: [
        _buildNumpadRow(['1', '2', '3'], isDark, textPrimary, surfaceBg),
        _buildNumpadRow(['4', '5', '6'], isDark, textPrimary, surfaceBg),
        _buildNumpadRow(['7', '8', '9'], isDark, textPrimary, surfaceBg),
        _buildNumpadRow(['.', '0', 'backspace'], isDark, textPrimary, surfaceBg),
      ],
    );
  }

  Widget _buildCategoryWrap(bool isDark, Color surfaceBg) {
    final categories = _availableCategories;
    if (categories.isEmpty) {
      return const Text("No categories configured", style: TextStyle(color: Colors.grey));
    }

    final inactiveTextColor = isDark ? Colors.grey : const Color(0xFF666666);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final isSelected = _selectedCategory?.id == cat.id;
        final activeColor = cat.color;

        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withValues(alpha: 0.12)
                  : surfaceBg,
              border: isSelected
                  ? Border.all(color: activeColor, width: 1.5)
                  : null,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  cat.icon,
                  size: 14,
                  color: isSelected ? activeColor : inactiveTextColor,
                ),
                const SizedBox(width: 6),
                Text(
                  cat.name,
                  style: TextStyle(
                    color: isSelected ? activeColor : inactiveTextColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentSourceWrap(bool isDark, Color surfaceBg) {
    if (_paymentSources.isEmpty) {
      return const Text("No payment sources configured", style: TextStyle(color: Colors.grey));
    }

    final inactiveTextColor = isDark ? Colors.grey : const Color(0xFF666666);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _paymentSources.map((source) {
        final isSelected = _selectedPaymentSource?.id == source.id;
        final activeColor = source.color;

        return GestureDetector(
          onTap: () => setState(() => _selectedPaymentSource = source),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withValues(alpha: 0.12)
                  : surfaceBg,
              border: isSelected
                  ? Border.all(color: activeColor, width: 1.5)
                  : null,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  source.icon,
                  size: 14,
                  color: isSelected ? activeColor : inactiveTextColor,
                ),
                const SizedBox(width: 6),
                Text(
                  source.name,
                  style: TextStyle(
                    color: isSelected ? activeColor : inactiveTextColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ignore: unused_element
  Widget _buildAccountWrap(bool isDark, Color surfaceBg) {
    if (_accounts.isEmpty) {
      return const Text("Loading accounts...", style: TextStyle(color: Colors.grey));
    }

    final inactiveTextColor = isDark ? Colors.grey : const Color(0xFF666666);
    const activeColor = Color(0xFF8C52FF);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _accounts.map((acc) {
        final isSelected = _selectedAccount?.id == acc.id;

        return GestureDetector(
          onTap: () => setState(() => _selectedAccount = acc),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withValues(alpha: 0.12)
                  : surfaceBg,
              border: isSelected
                  ? Border.all(color: activeColor, width: 1.5)
                  : null,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              acc.name,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveTextColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateSelector(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color accentColor,
    Color surfaceBg,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("DATE", textSecondary),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: surfaceBg,
              borderRadius: BorderRadius.circular(10),
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
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getFormattedDate(DateTime date) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  // ignore: unused_element
  Widget _buildRecurringToggleSwitch(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color accentColor,
    Color surfaceBg,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.autorenew_outlined, color: textPrimary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Recurring Transaction",
                style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const Text(
                "Set a repeat schedule",
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
          const Spacer(),
          Switch(
            value: false,
            onChanged: (val) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Recurring schedules will be added in a future update!"),
                ),
              );
            },
            activeColor: accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesAndTagsField(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color surfaceBg,
  ) {
    final tags = ['#business', '#family', '#subscription', '#urgent', '#tax', '#personal'];
    final tagTextColor = isDark ? Colors.grey : const Color(0xFF666666);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("NOTES · optional", textSecondary),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          style: TextStyle(color: textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: "Add a note, memo, or reference...",
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            fillColor: surfaceBg,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) {
            return GestureDetector(
              onTap: () {
                String currentText = _descriptionController.text.trim();
                if (currentText.contains(tag)) return; // No repeats
                if (currentText.isEmpty) {
                  _descriptionController.text = tag;
                } else {
                  _descriptionController.text = "$currentText $tag";
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: surfaceBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag,
                  style: TextStyle(color: tagTextColor, fontSize: 12),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubmitCTAButton(AppLocalizations l10n, bool isDark, Color accentColor, Color activeBg) {
    final double? amount = double.tryParse(_amountController.text);
    final String amountStr = amount != null
        ? "$_userCurrencySymbol${amount.toStringAsFixed(2)}"
        : "${_userCurrencySymbol}0.00";
    final isExpense = _selectedType == TransactionType.expense;
    
    // Background color: active toggle/accent color in dark mode, light overlay in light mode
    final String actionText = isExpense ? "Add Expense" : "Add Income";

    return InkWell(
      onTap: _saveTransaction,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: activeBg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: accentColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "✓ $actionText · $amountStr",
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
