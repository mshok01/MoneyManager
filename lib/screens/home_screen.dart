import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/screens/home/home_bottom_bar.dart';
import '../l10n/app_localizations.dart';
import '../widgets/welcome_nudge_card.dart';
import '../widgets/transaction_summary_card.dart';

import '../services/nudge_service.dart';
import '../services/preferences_service.dart';
import '../models/account.dart';
import '../providers/transaction_providers.dart';
import '../providers/account_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showWelcomeNudge = true;
  String? _selectedAccountId;
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _checkWelcomeNudgeVisibility();
    _initializeSelectedAccount();
  }

  void _initializeSelectedAccount() async {
    final prefsService = await PreferencesService.getInstance();
    final savedAccountId = prefsService.getSelectedAccount();

    if (mounted) {
      setState(() {
        _selectedAccountId = savedAccountId;
        _isInit = false;
      });
    }
  }

  void _checkWelcomeNudgeVisibility() {
    final shouldShow = NudgeService.instance.shouldShowNudge(
      NudgeService.welcomeNudge,
    );
    setState(() {
      _showWelcomeNudge = shouldShow;
    });
  }

  void _handleAccountRename() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.accountRenameComingSoon),
      ),
    );
  }

  void _handleWelcomeNudgeDismiss() {
    setState(() {
      _showWelcomeNudge = false;
    });
  }

  void _showAccountSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildAccountSelectorBottomSheet(),
    );
  }

  void _onAccountSelected(String accountId) async {
    final prefsService = await PreferencesService.getInstance();
    await prefsService.setSelectedAccount(accountId);

    if (mounted) {
      setState(() {
        _selectedAccountId = accountId;
      });
      Navigator.of(context).pop();
    }
  }

  Widget _buildAccountSelector(
    Account? account,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return GestureDetector(
      onTap: _showAccountSelector,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet,
            color:
                theme.appBarTheme.foregroundColor ??
                theme.colorScheme.onSurface,
            size: 20,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              account?.name ?? l10n.noAccount,
              style:
                  theme.appBarTheme.titleTextStyle?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ) ??
                  TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color:
                        theme.appBarTheme.foregroundColor ??
                        theme.colorScheme.onSurface,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down,
            color:
                theme.appBarTheme.foregroundColor ??
                theme.colorScheme.onSurface,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSelectorBottomSheet() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final accountsAsync = ref.watch(accountsProvider);

    return accountsAsync.when(
      data: (accounts) => _buildAccountSelectorContent(theme, accounts, l10n),
      loading: () => Container(
        height: 200,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      ),
      error: (error, stack) => Container(
        height: 200,
        alignment: Alignment.center,
        child: Text('Error loading accounts: $error'),
      ),
    );
  }

  Widget _buildAccountSelectorContent(
    ThemeData theme,
    List<Account> accounts,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  l10n.selectAccount,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  iconSize: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Account list
          if (accounts.isNotEmpty) ...[
            ...accounts.map((account) => _buildAccountListItem(account, theme)),
            const Divider(height: 32),
          ],

          // Add account option
          _buildAddAccountOption(theme),

          // Manage accounts option
          _buildManageAccountsOption(theme),

          // Bottom padding for safe area
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAccountListItem(Account account, ThemeData theme) {
    final isSelected = _selectedAccountId == account.id;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        child: Icon(
          Icons.account_balance_wallet,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        account.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: account.description.isNotEmpty
          ? Text(account.description)
          : null,
      trailing: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      onTap: () => _onAccountSelected(account.id),
    );
  }

  Widget _buildAddAccountOption(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
        child: Icon(Icons.add, color: theme.colorScheme.secondary, size: 20),
      ),
      title: Text(l10n.addNewAccountAction),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed('/add-account');
      },
    );
  }

  Widget _buildManageAccountsOption(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.tertiary.withValues(alpha: 0.1),
        child: Icon(
          Icons.settings,
          color: theme.colorScheme.tertiary,
          size: 20,
        ),
      ),
      title: Text(l10n.manageAccountsAction),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed('/manage-accounts');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final accountsAsync = ref.watch(accountsProvider);

    return accountsAsync.when(
      data: (accounts) {
        // Handle initial selection if needed
        if (_selectedAccountId == null && accounts.isNotEmpty && !_isInit) {
          // If loaded and still null, default to first (and save it potentially)
          // But we don't want to save recursively in build.
          // Just use it for display.
          // Or better: rely on `_initializeSelectedAccount` to have set it if found in prefs.
          // If not in prefs (first run or cleared), pick first.
          // We can schedule a SetState or just use a local var.
           WidgetsBinding.instance.addPostFrameCallback((_) {
             if (mounted && _selectedAccountId == null) {
               _onAccountSelected(accounts.first.id);
             }
           });
        }

        // If no accounts, show empty state or logic to force add
        // ... handled in scaffold body mainly?

        return _buildScaffoldWithAccount(context, l10n, theme, accounts);
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text(l10n.appTitle),
          backgroundColor: theme.colorScheme.inversePrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.appTitle),
          backgroundColor: theme.colorScheme.inversePrimary,
        ),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildScaffoldWithAccount(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    List<Account> accounts,
  ) {
    // Determine current account
    // If _selectedAccountId is set, find it in list (to ensure it's still active)
    // If not found (deleted?), fallback to first.

    Account? currentAccount;
    if (_selectedAccountId != null) {
      // Find in the list of active accounts
      try {
        currentAccount = accounts.firstWhere((a) => a.id == _selectedAccountId);
      } catch (_) {
        // Not found in active accounts
        if (accounts.isNotEmpty) {
          currentAccount = accounts.first;
          // Ideally update selection
        }
      }
    } else if (accounts.isNotEmpty) {
      currentAccount = accounts.first;
    }

    // If we have a selected ID, we want to watch it specifically to get updates (like rename)
    // The `accounts` list from `accountsProvider` should effectively already contain updated accounts
    // because `updateAccountProvider` invalidates `accountsProvider`.
    // So looking up from `accounts` list is sufficient for the name update!
    // NO NEED to `ref.watch(accountDetailsProvider)` separately if we trust `accountsProvider` to be refreshed.
    // AND `updateAccountProvider` invalidates `accountsProvider`.
    // So `accounts` list here is fresh. `currentAccount` derived from it is fresh.



    return Scaffold(
      appBar: AppBar(
        title: _buildAccountSelector(currentAccount, theme, l10n),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          if (_showWelcomeNudge)
            WelcomeNudgeCard(
              onAccountRename: _handleAccountRename,
              onDismiss: _handleWelcomeNudgeDismiss,
            ),

          Expanded(
            child: currentAccount != null
                ? ref
                      .watch(accountHasTransactionsProvider(currentAccount.id))
                      .when(
                        data: (hasTransactions) {
                          if (hasTransactions) {
                            return SafeArea(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TransactionSummaryCard(
                                    account: currentAccount!,
                                  ),
                                  HomeBottomBarWidget(account: currentAccount),
                                ],
                              ),
                            );
                          } else {
                            return SafeArea(
                              child: Stack(
                                children: [
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.trending_up,
                                          size: 64,
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.5),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          l10n.readyToTrackFinances,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          l10n.startByAddingTransaction,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: HomeBottomBarWidget(
                                      account: currentAccount!,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Center(
                          child: Text(
                            'Error loading data: $error',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 64,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noAccountSelected,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.pleaseSelectAccountFirst,
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
