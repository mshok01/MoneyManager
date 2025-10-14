import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/account_service.dart';
import '../services/preferences_service.dart';
import '../models/account.dart';

class ManageAccountsScreen extends StatefulWidget {
  const ManageAccountsScreen({super.key});

  @override
  State<ManageAccountsScreen> createState() => _ManageAccountsScreenState();
}

class _ManageAccountsScreenState extends State<ManageAccountsScreen> {
  List<Account> _accounts = [];
  String? _primaryAccountId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      final accounts = await AccountService.instance.activeAccounts;
      final prefsService = await PreferencesService.getInstance();
      final primaryAccountId = prefsService.getSelectedAccount();

      setState(() {
        _accounts = accounts;
        _primaryAccountId = primaryAccountId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.failedToLoadAccounts(e.toString()),
            ),
          ),
        );
      }
    }
  }

  Future<void> _setPrimaryAccount(String accountId) async {
    try {
      final prefsService = await PreferencesService.getInstance();
      await prefsService.setSelectedAccount(accountId);

      setState(() {
        _primaryAccountId = accountId;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.primaryAccountUpdated),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.failedToUpdatePrimaryAccount(e.toString()),
            ),
          ),
        );
      }
    }
  }

  void _navigateToAddAccount() {
    Navigator.of(context).pushNamed('/add-account').then((_) {
      // Refresh accounts list when returning from add account screen
      _loadAccounts();
    });
  }

  void _navigateToAccountDetails(Account account) {
    Navigator.of(
      context,
    ).pushNamed('/account-details', arguments: account).then((_) {
      // Refresh accounts list when returning from account details
      _loadAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageAccounts),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header with account count
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.accountsCount(
                          _accounts.length,
                          _accounts.length != 1 ? 's' : '',
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.tapAccountToEdit,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Accounts list
                Expanded(
                  child: _accounts.isEmpty
                      ? _buildEmptyState(theme)
                      : ListView.builder(
                          itemCount: _accounts.length,
                          itemBuilder: (context, index) {
                            final account = _accounts[index];
                            return _buildAccountListItem(account, theme);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddAccount,
        icon: const Icon(Icons.add),
        label: Text(l10n.addAccount),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noAccounts,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.createFirstAccount,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAddAccount,
            icon: const Icon(Icons.add),
            label: Text(l10n.addAccount),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountListItem(Account account, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final isPrimary = _primaryAccountId == account.id;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: isPrimary
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.account_balance_wallet,
            color: isPrimary
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                account.name,
                style: TextStyle(
                  fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isPrimary)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.primary,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (account.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(account.description),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  l10n.membersCount(
                    account.memberCount,
                    account.memberCount != 1 ? 's' : '',
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 16),
                if (!isPrimary)
                  GestureDetector(
                    onTap: () => _setPrimaryAccount(account.id),
                    child: Text(
                      l10n.setAsPrimary,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _navigateToAccountDetails(account),
      ),
    );
  }
}
