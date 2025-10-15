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
import '../utils/currency_utils.dart';
import 'add_edit_transaction_screen.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final Transaction transaction;
  final Account account;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
    required this.account,
  });

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  CategoryItem? _category;
  PaymentSource? _paymentSource;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactionDetails();
  }

  Future<void> _loadTransactionDetails() async {
    try {
      // Load category
      final incomeCategories = await CategoryService.instance
          .getIncomeCategories();
      final expenseCategories = await CategoryService.instance
          .getExpenseCategories();
      final allCategories = [...incomeCategories, ...expenseCategories];

      _category = allCategories.firstWhere(
        (cat) => cat.id == widget.transaction.categoryId,
        orElse: () => CategoryItem(
          id: 'unknown',
          name: 'Unknown Category', // This will be replaced in UI
          description: 'Category not found', // This will be replaced in UI
          icon: Icons.help_outline,
          color: Colors.grey,
          isDefault: false,
          createdBy: '',
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          accessTo: [],
        ),
      );

      // Load payment source
      final paymentSources = await PaymentSourceService.instance
          .getAllPaymentSources();
      _paymentSource = paymentSources.firstWhere(
        (source) => source.id == widget.transaction.paymentSourceId,
        orElse: () => PaymentSource(
          id: 'unknown',
          name: 'Unknown Source', // This will be replaced in UI
          description:
              'Payment source not found', // This will be replaced in UI
          icon: Icons.payment,
          color: Colors.grey,
          isDefault: false,
          createdBy: '',
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          accessTo: [],
        ),
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _editTransaction() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddEditTransactionScreen(
          account: widget.account,
          transaction: widget.transaction,
        ),
      ),
    );

    if (result == true && mounted) {
      // Transaction was updated, pop back to previous screen
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _deleteTransaction() async {
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
        await TransactionService.instance.deleteTransaction(
          widget.transaction.id,
        );
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.transactionDeletedSuccessfully)),
          );
          Navigator.of(context).pop(true); // Return true to indicate deletion
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactionDetails),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _editTransaction,
            icon: const Icon(Icons.edit),
            tooltip: l10n.editTransaction,
          ),
          IconButton(
            onPressed: _deleteTransaction,
            icon: const Icon(Icons.delete),
            tooltip: l10n.deleteTransactionTooltip,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            widget.transaction.isIncome
                                ? Icons.trending_up
                                : Icons.trending_down,
                            size: 48,
                            color: widget.transaction.isIncome
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${widget.transaction.isIncome ? '+' : '-'}${_formatAmount(widget.transaction.amount)}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: widget.transaction.isIncome
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.transaction.isIncome
                                ? l10n.income
                                : l10n.expense,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Details Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.transactionDetails,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Description
                          if (widget.transaction.description.isNotEmpty) ...[
                            _buildDetailRow(
                              context,
                              l10n.description,
                              widget.transaction.description,
                              Icons.description,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Category
                          _buildDetailRow(
                            context,
                            l10n.category,
                            _category?.name ?? l10n.unknownCategory,
                            _category?.icon ?? Icons.help_outline,
                            iconColor: _category?.color,
                          ),
                          const SizedBox(height: 16),

                          // Payment Source
                          _buildDetailRow(
                            context,
                            l10n.paymentSource,
                            _paymentSource?.name ?? l10n.unknownSource,
                            Icons.payment,
                          ),
                          const SizedBox(height: 16),

                          // Date
                          _buildDetailRow(
                            context,
                            l10n.date,
                            _formatDate(widget.transaction.transactionDateTime),
                            Icons.calendar_today,
                          ),
                          const SizedBox(height: 16),

                          // Time
                          _buildDetailRow(
                            context,
                            l10n.time,
                            _formatTime(widget.transaction.transactionDateTime),
                            Icons.access_time,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? iconColor,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor ?? theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
