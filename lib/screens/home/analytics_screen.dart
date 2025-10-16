import 'package:flutter/material.dart';
import '../../models/account.dart';
import '../../models/transaction_summary.dart';
import '../../models/monthly_summary.dart';
import '../../services/transaction_service.dart';
import '../../services/user_service.dart';
import '../../utils/currency_utils.dart';
import '../../l10n/app_localizations.dart';

class AnalyticsScreen extends StatefulWidget {
  final Account account;

  const AnalyticsScreen({super.key, required this.account});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  TransactionSummary? _todaySummary;
  TransactionSummary? _monthSummary;
  TransactionSummary? _yearSummary;
  List<MonthlySummary> _yearlyMonthlySummaries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();

      // Get date ranges
      final todayStart = DateTime(now.year, now.month, now.day).toUtc();
      final todayEnd = DateTime(
        now.year,
        now.month,
        now.day,
        23,
        59,
        59,
        999,
      ).toUtc();

      final monthStart = DateTime(now.year, now.month, 1).toUtc();
      final monthEnd = DateTime(
        now.year,
        now.month + 1,
        0,
        23,
        59,
        59,
        999,
      ).toUtc();

      final yearStart = DateTime(now.year, 1, 1).toUtc();
      final yearEnd = DateTime(now.year, 12, 31, 23, 59, 59, 999).toUtc();

      // Load summaries
      final todaySummary = await TransactionService.instance
          .getTransactionSummary(
            widget.account.id,
            todayStart.millisecondsSinceEpoch,
            todayEnd.millisecondsSinceEpoch,
          );

      final monthSummary = await TransactionService.instance
          .getTransactionSummary(
            widget.account.id,
            monthStart.millisecondsSinceEpoch,
            monthEnd.millisecondsSinceEpoch,
          );

      final yearSummary = await TransactionService.instance
          .getTransactionSummary(
            widget.account.id,
            yearStart.millisecondsSinceEpoch,
            yearEnd.millisecondsSinceEpoch,
          );

      // Load monthly summaries for the year
      final yearlyMonthlySummaries = await TransactionService.instance
          .getYearlyMonthlySummaries(widget.account.id, now.year);

      setState(() {
        _todaySummary = todaySummary;
        _monthSummary = monthSummary;
        _yearSummary = yearSummary;
        _yearlyMonthlySummaries = yearlyMonthlySummaries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.failedToLoadAnalytics(e.toString()),
            ),
          ),
        );
      }
    }
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

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.analytics),
            Text(
              widget.account.name,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalyticsData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Stats
                    _buildQuickStats(theme, l10n),
                    const SizedBox(height: 24),

                    // Monthly Breakdown
                    _buildMonthlyBreakdown(theme, l10n),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildQuickStats(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickStats,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        // Today
        _buildStatCard(
          theme,
          l10n.today,
          _todaySummary ?? TransactionSummary.empty(),
          Icons.today,
          Colors.blue,
          l10n,
        ),
        const SizedBox(height: 12),

        // This Month
        _buildStatCard(
          theme,
          l10n.thisMonth,
          _monthSummary ?? TransactionSummary.empty(),
          Icons.calendar_month,
          Colors.green,
          l10n,
        ),
        const SizedBox(height: 12),

        // This Year
        _buildStatCard(
          theme,
          l10n.thisYear,
          _yearSummary ?? TransactionSummary.empty(),
          Icons.event_note,
          Colors.purple,
          l10n,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String title,
    TransactionSummary summary,
    IconData icon,
    Color accentColor,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accentColor, size: 20),
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
                Text(
                  l10n.transactionsCount(summary.transactionCount),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildAmountColumn(
                    l10n.income,
                    summary.totalIncome,
                    Colors.green,
                    Icons.trending_up,
                  ),
                ),
                Expanded(
                  child: _buildAmountColumn(
                    l10n.expensesTab,
                    summary.totalExpenses,
                    Colors.red,
                    Icons.trending_down,
                  ),
                ),
                Expanded(
                  child: _buildAmountColumn(
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
          ],
        ),
      ),
    );
  }

  Widget _buildAmountColumn(
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
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

  Widget _buildMonthlyBreakdown(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.monthlyBreakdown,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        if (_yearlyMonthlySummaries.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 48,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noDataAvailable,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.addTransactionsToSeeAnalytics,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ..._yearlyMonthlySummaries.map(
            (monthlySummary) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: monthlySummary.isPositiveBalance
                        ? Colors.green.withValues(alpha: 0.2)
                        : monthlySummary.isNegativeBalance
                        ? Colors.red.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                    child: Text(
                      monthlySummary.shortMonthName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: monthlySummary.isPositiveBalance
                            ? Colors.green
                            : monthlySummary.isNegativeBalance
                            ? Colors.red
                            : Colors.grey,
                      ),
                    ),
                  ),
                  title: Text(
                    monthlySummary.monthName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    l10n.transactionsCount(monthlySummary.transactionCount),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatAmount(monthlySummary.balance),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: monthlySummary.isPositiveBalance
                              ? Colors.green
                              : monthlySummary.isNegativeBalance
                              ? Colors.red
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        l10n.balance,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
