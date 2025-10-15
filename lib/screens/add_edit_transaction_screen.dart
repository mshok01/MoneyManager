import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../models/category_item.dart';
import '../models/payment_source.dart';
import '../services/transaction_service.dart';
import '../services/category_service.dart';
import '../services/payment_source_service.dart';
import '../services/user_service.dart';
import '../utils/currency_utils.dart';
import '../widgets/category_bottom_sheet.dart';
import '../widgets/payment_source_bottom_sheet.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final Account account;
  final Transaction? transaction; // null for add, non-null for edit

  const AddEditTransactionScreen({
    super.key,
    required this.account,
    this.transaction,
  });

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  String _selectedType = TransactionType.expense; // Default to expense
  CategoryItem? _selectedCategory;
  PaymentSource? _selectedPaymentSource;
  DateTime _selectedDate = DateTime.now();

  List<CategoryItem> _incomeCategories = [];
  List<CategoryItem> _expenseCategories = [];
  List<PaymentSource> _paymentSources = [];

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

      // Load categories and payment sources
      final incomeCategories = await CategoryService.instance
          .getIncomeCategories();
      final expenseCategories = await CategoryService.instance
          .getExpenseCategories();
      final paymentSources = await PaymentSourceService.instance
          .getAllPaymentSources();

      setState(() {
        _incomeCategories = incomeCategories;
        _expenseCategories = expenseCategories;
        _paymentSources = paymentSources;
        _isLoading = false;
      });

      // Set initial selections for editing
      if (_isEditing && widget.transaction != null) {
        final transaction = widget.transaction!;

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
      }
    }
  }

  List<CategoryItem> get _availableCategories {
    return _selectedType == TransactionType.income
        ? _incomeCategories
        : _expenseCategories;
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }
    // Only validate payment source for expenses
    if (_selectedType == TransactionType.expense &&
        _selectedPaymentSource == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment source')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.trim();

      // For income transactions, use default bank transfer payment source
      final paymentSourceId = _selectedType == TransactionType.income
          ? 'bank_transfer' // Default payment source for income
          : _selectedPaymentSource!.id;

      if (_isEditing) {
        await TransactionService.instance.updateTransaction(
          widget.transaction!.id,
          accountId: widget.account.id,
          categoryId: _selectedCategory!.id,
          paymentSourceId: paymentSourceId,
          amount: amount,
          type: _selectedType,
          description: description,
          transactionDate: _selectedDate,
        );
      } else {
        await TransactionService.instance.createTransaction(
          accountId: widget.account.id,
          categoryId: _selectedCategory!.id,
          paymentSourceId: paymentSourceId,
          amount: amount,
          type: _selectedType,
          description: description,
          transactionDate: _selectedDate,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Transaction updated successfully'
                  : 'Transaction created successfully',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save transaction: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isAfter(today) ? today : _selectedDate,
      firstDate: DateTime(2020),
      lastDate: today, // Only allow today and past dates
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
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
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'Add Transaction'),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveTransaction,
              child: Text(_isEditing ? 'Update' : 'Save'),
            ),
        ],
      ),
      body: _isLoading && !_isEditing
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  16 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Transaction type selection
                      Text(
                        'Transaction Type',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Income'),
                              value: TransactionType.income,
                              groupValue: _selectedType,
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value!;
                                  _selectedCategory =
                                      null; // Reset category selection
                                  _selectedPaymentSource =
                                      null; // Reset payment source selection
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Expense'),
                              value: TransactionType.expense,
                              groupValue: _selectedType,
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value!;
                                  _selectedCategory =
                                      null; // Reset category selection
                                  _selectedPaymentSource =
                                      null; // Reset payment source selection
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Amount input
                      Text(
                        'Amount ($_userCurrencySymbol)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        decoration: InputDecoration(
                          hintText: '0.00',
                          prefixText: '$_userCurrencySymbol ',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount greater than 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Category selection
                      Text(
                        'Category',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildCategorySelector(),
                      const SizedBox(height: 24),

                      // Payment source selection (only for expenses)
                      if (_selectedType == TransactionType.expense) ...[
                        Text(
                          'Payment Source',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildPaymentSourceSelector(),
                        const SizedBox(height: 24),
                      ],

                      // Date selection
                      Text(
                        'Date',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: theme.textTheme.bodyLarge,
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Notes input
                      Text(
                        'Notes',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: 'Milk, Eggs etc',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      // Add bottom padding to prevent cutoff by navigation bar
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCategorySelector() {
    final theme = Theme.of(context);
    final categories = _availableCategories;

    if (categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'No categories available for ${_selectedType}',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => _showCategoryBottomSheet(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            if (_selectedCategory != null) ...[
              CircleAvatar(
                radius: 12,
                backgroundColor: _selectedCategory!.color.withValues(
                  alpha: 0.2,
                ),
                child: Icon(
                  _selectedCategory!.icon,
                  size: 16,
                  color: _selectedCategory!.color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedCategory!.name,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ] else ...[
              Icon(
                Icons.category_outlined,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Select a category',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
            Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryBottomSheet() {
    final categories = _availableCategories;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CategoryBottomSheet(
        categories: categories,
        selectedCategory: _selectedCategory,
        onCategorySelected: (category) {
          setState(() => _selectedCategory = category);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildPaymentSourceSelector() {
    final theme = Theme.of(context);

    if (_paymentSources.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'No payment sources available',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => _showPaymentSourceBottomSheet(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            if (_selectedPaymentSource != null) ...[
              CircleAvatar(
                radius: 12,
                backgroundColor: _selectedPaymentSource!.color.withValues(
                  alpha: 0.2,
                ),
                child: Icon(
                  _selectedPaymentSource!.icon,
                  size: 16,
                  color: _selectedPaymentSource!.color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedPaymentSource!.name,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ] else ...[
              Icon(
                Icons.payment_outlined,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Select a payment source',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
            Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PaymentSourceBottomSheet(
        paymentSources: _paymentSources,
        selectedPaymentSource: _selectedPaymentSource,
        onPaymentSourceSelected: (paymentSource) {
          setState(() => _selectedPaymentSource = paymentSource);
          Navigator.pop(context);
        },
      ),
    );
  }
}
