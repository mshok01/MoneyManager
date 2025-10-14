import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/welcome_nudge_card.dart';
import '../services/nudge_service.dart';
import '../services/account_service.dart';
import '../services/user_service.dart';
import '../screens/currency_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showWelcomeNudge = true;

  @override
  void initState() {
    super.initState();
    _checkWelcomeNudgeVisibility();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final user = UserService.instance.currentUser;
    final accounts = AccountService.instance.activeAccounts;
    final mainAccount = accounts.isNotEmpty ? accounts.first : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
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
                  // Account header
                  if (mainAccount != null) ...[
                    Card(
                      child: Column(
                        children: [
                          // Account name section (tappable)
                          InkWell(
                            onTap: _handleAccountRename,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.account_balance_wallet,
                                      color: theme.colorScheme.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                mainAccount.name,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.primary
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'TAP TO EDIT',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      theme.colorScheme.primary,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (mainAccount.description.isNotEmpty)
                                          Text(
                                            mainAccount.description,
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
                                    Icons.edit,
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.7,
                                    ),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Currency section (tappable)
                          if (user != null && user.currencyCode.isNotEmpty) ...[
                            Divider(
                              height: 1,
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.2,
                              ),
                            ),
                            InkWell(
                              onTap: _handleCurrencyChange,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.secondary
                                            .withValues(alpha: 0.1),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Currency: ${user.currencyCode}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: theme
                                                      .colorScheme
                                                      .secondary
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  'TAP TO CHANGE',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: theme
                                                        .colorScheme
                                                        .secondary,
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
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.6),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: theme.colorScheme.secondary
                                          .withValues(alpha: 0.7),
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
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
