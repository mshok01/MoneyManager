import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account.dart';
import '../models/transaction_summary.dart';
import '../providers/transaction_providers.dart';
import '../services/user_service.dart';
import '../utils/currency_utils.dart';
import '../l10n/app_localizations.dart';
import '../screens/history_screen.dart';

/// Widget that displays transaction summaries for today, this month, and this year
class TransactionSummaryCard extends ConsumerWidget {
  final Account account;

  const TransactionSummaryCard({super.key, required this.account});

  /// Format amount with user's preferred currency symbol
  String _formatAmount(double amount) {
    final currentUser = UserService.instance.currentUser;
    final userCurrency = currentUser?.currencyCode ?? account.baseCurrency;
    final currencySymbol = CurrencyUtils.getCurrencySymbol(userCurrency);

    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Watch providers for each period
    final todayAsync = ref.watch(
      transactionSummaryProvider((accountId: account.id, period: 'today')),
    );
    final monthAsync = ref.watch(
      transactionSummaryProvider((accountId: account.id, period: 'month')),
    );
    final yearAsync = ref.watch(
      transactionSummaryProvider((accountId: account.id, period: 'year')),
    );

    // Check if any state is loading or error
    if (todayAsync.isLoading || monthAsync.isLoading || yearAsync.isLoading) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (todayAsync.hasError || monthAsync.hasError || yearAsync.hasError) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.error,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.errorLoadingSummary,
                  style: TextStyle(color: theme.colorScheme.error, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // All data is available
    final todaySummary = todayAsync.value!;
    final monthSummary = monthAsync.value!;
    final yearSummary = yearAsync.value!;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.summary,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Summary periods
            _buildSummaryPeriod(
              context,
              l10n.today,
              todaySummary,
              Icons.today,
              'today',
            ),
            const SizedBox(height: 16),
            _buildSummaryPeriod(
              context,
              l10n.thisMonth,
              monthSummary,
              Icons.calendar_month,
              'month',
            ),
            const SizedBox(height: 16),
            _buildSummaryPeriod(
              context,
              l10n.thisYear,
              yearSummary,
              Icons.event_note,
              'year',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryPeriod(
    BuildContext context,
    String title,
    TransactionSummary summary,
    IconData icon,
    String periodType,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap:
          summary.hasTransactions
              ? () => _navigateToTransactionHistory(context, title, periodType)
              : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
            // Period header
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
              ],
            ),

            if (summary.hasTransactions) ...[
              const SizedBox(height: 12),
              // Financial summary
              Row(
                children: [
                  // Income
                  Expanded(
                    child: _buildAmountColumn(
                      context,
                      l10n.income,
                      summary.totalIncome,
                      Colors.green,
                      Icons.trending_up,
                    ),
                  ),
                  // Expenses
                  Expanded(
                    child: _buildAmountColumn(
                      context,
                      l10n.expensesTab,
                      summary.totalExpenses,
                      Colors.red,
                      Icons.trending_down,
                    ),
                  ),
                  // Balance
                  Expanded(
                    child: _buildAmountColumn(
                      context,
                      l10n.balance,
                      summary.balance,
                      summary.isPositiveBalance
                          ? Colors.green
                          : summary.isNegativeBalance
                              ? Colors.red
                              : theme.colorScheme.onSurface,
                      summary.isPositiveBalance
                          ? Icons.arrow_upward
                          : summary.isNegativeBalance
                              ? Icons.arrow_downward
                              : Icons.remove,
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                l10n.noTransactionsText,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToTransactionHistory(
    BuildContext context,
    String title,
    String periodType,
  ) async {
    final now = DateTime.now();
    int? year;
    int? month;

    if (periodType == 'month') {
      year = now.year;
      month = now.month;
    } else if (periodType == 'year') {
      year = now.year;
    }

    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => HistoryScreen(
          account: account,
          initialYear: year,
          initialMonth: month,
        ),
      ),
    );
    
    // No need to manually refresh, providers will update if invalidated elsewhere
    // If TransactionHistoryScreen edits transactions, it should invalidate providers
  }

  Widget _buildAmountColumn(
    BuildContext context,
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
