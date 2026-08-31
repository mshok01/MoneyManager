import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/account.dart';
import '../history_screen.dart';
import '../add_edit_transaction_screen.dart';

import 'analytics_screen.dart';

class HomeBottomBarWidget extends StatelessWidget {
  final Account? account;

  const HomeBottomBarWidget({super.key, this.account});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.settings,
                label: l10n.settings,
                onTap: () => _navigateToSettings(context),
              ),
              _buildNavItem(
                context: context,
                icon: Icons.receipt_long,
                label: l10n.history,
                onTap: () => _navigateToTransactions(context),
              ),
              _buildNavItem(
                context: context,
                icon: Icons.analytics,
                label: l10n.analytics,
                onTap: () => _navigateToAnalytics(context),
              ),
              _buildNavItem(
                context: context,
                icon: Icons.add,
                label: l10n.add,
                onTap: () => _navigateToAddTransaction(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).pushNamed('/settings');
  }

  void _navigateToTransactions(BuildContext context) {
    if (account == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseSelectAccountFirst),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => HistoryScreen(account: account!)),
    );
  }

  void _navigateToAnalytics(BuildContext context) {
    if (account == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseSelectAccountFirst),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AnalyticsScreen(account: account!),
      ),
    );
  }

  void _navigateToAddTransaction(BuildContext context) {
    if (account == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseSelectAccountFirst),
        ),
      );
      return;
    }

    AddEditTransactionScreen.push(context, account: account!);
  }
}
