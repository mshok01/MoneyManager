import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../services/preferences_service.dart';
import '../models/account.dart';
import '../providers/account_providers.dart';

class ManageAccountsScreen extends ConsumerStatefulWidget {
  const ManageAccountsScreen({super.key});

  @override
  ConsumerState<ManageAccountsScreen> createState() =>
      _ManageAccountsScreenState();
}

class _ManageAccountsScreenState extends ConsumerState<ManageAccountsScreen> {
  String? _primaryAccountId;
  bool _isLoadingPrimary = true;

  @override
  void initState() {
    super.initState();
    _loadPrimaryAccount();
  }

  Future<void> _loadPrimaryAccount() async {
    try {
      final prefsService = await PreferencesService.getInstance();
      final primaryAccountId = prefsService.getSelectedAccount();

      if (mounted) {
        setState(() {
          _primaryAccountId = primaryAccountId;
          _isLoadingPrimary = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPrimary = false;
        });
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
    Navigator.of(context).pushNamed('/add-account');
    // No need to manually refresh, provider invalidation handles it
  }

  void _navigateToAccountDetails(Account account) {
    Navigator.of(
      context,
    ).pushNamed('/account-details', arguments: account);
    // No need to manually refresh, provider invalidation handles it
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageAccounts),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: accountsAsync.when(
        data: (accounts) {
          if (_isLoadingPrimary) {
             return const Center(child: CircularProgressIndicator());
          }

          return Column(
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
                        accounts.length,
                        accounts.length != 1 ? 's' : '',
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
                child: accounts.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.builder(
                        itemCount: accounts.length,
                        itemBuilder: (context, index) {
                          final account = accounts[index];
                          return _buildAccountListItem(account, theme);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            l10n.failedToLoadAccounts(error.toString()),
            textAlign: TextAlign.center,
          ),
        ),
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
