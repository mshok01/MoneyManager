import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/monthly_summary.dart';
import '../services/transaction_service.dart';
import '../services/user_service.dart';
import '../utils/currency_utils.dart';
import '../l10n/app_localizations.dart';
import 'monthly_transactions_screen.dart';

class YearlyTransactionsScreen extends StatefulWidget {
  final Account account;
  final int? initialYear;

  const YearlyTransactionsScreen({
    super.key,
    required this.account,
    this.initialYear,
  });

  @override
  State<YearlyTransactionsScreen> createState() =>
      _YearlyTransactionsScreenState();
}

class _YearlyTransactionsScreenState extends State<YearlyTransactionsScreen> {
  List<MonthlySummary> _monthlySummaries = [];
  List<int> _availableYears = [];
  late int _selectedYear;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear ?? DateTime.now().year;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load available years and monthly summaries
      final availableYears = await TransactionService.instance
          .getAvailableYears(widget.account.id);
      final monthlySummaries = await TransactionService.instance
          .getYearlyMonthlySummaries(widget.account.id, _selectedYear);

      setState(() {
        _availableYears = availableYears;
        _monthlySummaries = monthlySummaries;
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

  void _onYearChanged(int? newYear) {
    if (newYear != null && newYear != _selectedYear) {
      setState(() {
        _selectedYear = newYear;
      });
      _loadData();
    }
  }

  Future<void> _navigateToMonthDetails(MonthlySummary monthlySummary) async {
    if (!monthlySummary.hasTransactions) return;

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => MonthlyTransactionsScreen(
          account: widget.account,
          year: monthlySummary.year,
          month: monthlySummary.month,
        ),
      ),
    );

    // Reload data if transactions were modified
    if (result == true) {
      _loadData();
    }
  }

  Widget _buildYearSelector() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 20),
          const SizedBox(width: 8),
          Text('${l10n.year}:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<int>(
              value: _selectedYear,
              isExpanded: true,
              onChanged: _onYearChanged,
              items: _availableYears.map((year) {
                return DropdownMenuItem<int>(
                  value: year,
                  child: Text(year.toString()),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummaryCard(MonthlySummary summary) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final hasTransactions = summary.hasTransactions;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: hasTransactions ? () => _navigateToMonthDetails(summary) : null,
        leading: CircleAvatar(
          backgroundColor: hasTransactions
              ? (summary.isPositiveBalance
                    ? Colors.green.withValues(alpha: 0.2)
                    : summary.isNegativeBalance
                    ? Colors.red.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.2))
              : Colors.grey.withValues(alpha: 0.1),
          child: Text(
            summary.shortMonthName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: hasTransactions
                  ? (summary.isPositiveBalance
                        ? Colors.green
                        : summary.isNegativeBalance
                        ? Colors.red
                        : Colors.grey)
                  : Colors.grey.withValues(alpha: 0.5),
            ),
          ),
        ),
        title: Text(
          summary.monthName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: hasTransactions
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        subtitle: hasTransactions
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.trending_up, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        _formatAmount(summary.totalIncome),
                        style: TextStyle(fontSize: 12, color: Colors.green),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.trending_down, size: 14, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        _formatAmount(summary.totalExpenses),
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.transactionsCount(summary.transactionCount),
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              )
            : Text(
                l10n.noTransactionsText,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
        trailing: hasTransactions
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatAmount(summary.balance),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: summary.isPositiveBalance
                          ? Colors.green
                          : summary.isNegativeBalance
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.accountYearlyTransactions(widget.account.name, _selectedYear),
        ),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildYearSelector(),
                const Divider(height: 1),
                Expanded(
                  child: _monthlySummaries.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_month,
                                size: 64,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noTransactionsInYear(_selectedYear),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _monthlySummaries.length,
                            itemBuilder: (context, index) {
                              final summary = _monthlySummaries[index];
                              return _buildMonthlySummaryCard(summary);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
