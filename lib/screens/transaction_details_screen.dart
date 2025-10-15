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
          name: 'Unknown Category',
          description: 'Category not found',
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
          name: 'Unknown Source',
          description: 'Payment source not found',
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
        await TransactionService.instance.deleteTransaction(
          widget.transaction.id,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction deleted successfully')),
          );
          Navigator.of(context).pop(true); // Return true to indicate deletion
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _editTransaction,
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Transaction',
          ),
          IconButton(
            onPressed: _deleteTransaction,
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Transaction',
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
                            widget.transaction.isIncome ? 'Income' : 'Expense',
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
                            'Transaction Details',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Description
                          if (widget.transaction.description.isNotEmpty) ...[
                            _buildDetailRow(
                              context,
                              'Description',
                              widget.transaction.description,
                              Icons.description,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Category
                          _buildDetailRow(
                            context,
                            'Category',
                            _category?.name ?? 'Unknown Category',
                            _category?.icon ?? Icons.help_outline,
                            iconColor: _category?.color,
                          ),
                          const SizedBox(height: 16),

                          // Payment Source
                          _buildDetailRow(
                            context,
                            'Payment Source',
                            _paymentSource?.name ?? 'Unknown Source',
                            Icons.payment,
                          ),
                          const SizedBox(height: 16),

                          // Date
                          _buildDetailRow(
                            context,
                            'Date',
                            _formatDate(widget.transaction.transactionDateTime),
                            Icons.calendar_today,
                          ),
                          const SizedBox(height: 16),

                          // Time
                          _buildDetailRow(
                            context,
                            'Time',
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
