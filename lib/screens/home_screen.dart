import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/welcome_nudge_card.dart';
import '../services/nudge_service.dart';
import '../services/account_service.dart';
import '../services/user_service.dart';
import '../services/preferences_service.dart';
import '../screens/currency_selection_screen.dart';
import '../models/account.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showWelcomeNudge = true;
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _checkWelcomeNudgeVisibility();
    _initializeSelectedAccount();
  }

  void _initializeSelectedAccount() async {
    final prefsService = await PreferencesService.getInstance();
    final savedAccountId = prefsService.getSelectedAccount();
    final accounts = AccountService.instance.activeAccounts;

    String? accountIdToUse;

    if (savedAccountId != null &&
        accounts.any((account) => account.id == savedAccountId)) {
      // Use saved account if it still exists
      accountIdToUse = savedAccountId;
    } else if (accounts.isNotEmpty) {
      // Fallback to first account and save it
      accountIdToUse = accounts.first.id;
      await prefsService.setSelectedAccount(accountIdToUse);
    }

    if (accountIdToUse != null && mounted) {
      setState(() {
        _selectedAccountId = accountIdToUse;
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
    // TODO: Implement account rename dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account rename feature coming soon!')),
    );
  }

  void _handleCurrencyChange() async {
    final currentUser = UserService.instance.currentUser;
    if (currentUser == null) return;

    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => CurrencySelectionScreen(
          isFromSettings: true,
          currentCurrency: currentUser.currencyCode,
        ),
      ),
    );

    if (result != null && mounted) {
      // Update user currency
      await UserService.instance.updateUser(currencyCode: result);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Currency updated to $result')));
      }
    }
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
    // Save selection to preferences
    final prefsService = await PreferencesService.getInstance();
    await prefsService.setSelectedAccount(accountId);

    // Update UI
    if (mounted) {
      setState(() {
        _selectedAccountId = accountId;
      });
      Navigator.of(context).pop();
    }
  }

  Account? get _currentAccount {
    if (_selectedAccountId == null) return null;
    return AccountService.instance.getAccountById(_selectedAccountId!);
  }

  Widget _buildAccountSelector(Account? account, ThemeData theme) {
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
              account?.name ?? 'No Account',
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
    final accounts = AccountService.instance.activeAccounts;

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
                  'Select Account',
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
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
        child: Icon(Icons.add, color: theme.colorScheme.secondary, size: 20),
      ),
      title: const Text('Add New Account'),
      onTap: () {
        Navigator.of(context).pop();
        // TODO: Navigate to add account screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add account feature coming soon!')),
        );
      },
    );
  }

  Widget _buildManageAccountsOption(ThemeData theme) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.tertiary.withValues(alpha: 0.1),
        child: Icon(
          Icons.settings,
          color: theme.colorScheme.tertiary,
          size: 20,
        ),
      ),
      title: const Text('Manage Accounts'),
      onTap: () {
        Navigator.of(context).pop();
        // TODO: Navigate to manage accounts screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Manage accounts feature coming soon!')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final user = UserService.instance.currentUser;
    final accounts = AccountService.instance.activeAccounts;
    final currentAccount =
        _currentAccount ?? (accounts.isNotEmpty ? accounts.first : null);

    return Scaffold(
      appBar: AppBar(
        title: _buildAccountSelector(currentAccount, theme),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed('/settings');
            },
            tooltip: l10n.settings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Welcome nudge card (shown only for first-time users)
          if (_showWelcomeNudge)
            WelcomeNudgeCard(
              onAccountRename: _handleAccountRename,
              onCurrencyChange: _handleCurrencyChange,
              onDismiss: _handleWelcomeNudgeDismiss,
            ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Currency section (tappable)
                  if (user != null && user.currencyCode.isNotEmpty) ...[
                    Card(
                      child: InkWell(
                        onTap: _handleCurrencyChange,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.currency_exchange,
                                  color: theme.colorScheme.secondary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Currency: ${user.currencyCode}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.secondary
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            'TAP TO CHANGE',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  theme.colorScheme.secondary,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (user.currencyName.isNotEmpty)
                                      Text(
                                        user.currencyName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: theme.colorScheme.secondary.withValues(
                                  alpha: 0.7,
                                ),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Quick stats or placeholder content
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 64,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ready to track your finances!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start by adding your first transaction',
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
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add transaction functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add transaction feature coming soon!'),
            ),
          );
        },
        tooltip: l10n.addTransaction,
        child: const Icon(Icons.add),
      ),
    );
  }
}
