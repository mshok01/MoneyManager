import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/screens/home/home_bottom_bar.dart';
import '../l10n/app_localizations.dart';
import '../widgets/welcome_nudge_card.dart';
import '../widgets/transaction_summary_card.dart';

import '../services/nudge_service.dart';
import '../services/preferences_service.dart';
import '../services/user_service.dart';
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

  // Account badge colors matching Figma palette
  static const List<Color> _accountColors = [
    Color(0xFF00E5A0), // Mint / Green
    Color(0xFF00B4D8), // Cyan / Blue
    Color(0xFFA78BFA), // Purple
    Color(0xFFFF4D6D), // Coral / Pink
    Color(0xFFF59E0B), // Amber
  ];

  Color _getAccountColor(int index) {
    return _accountColors[index % _accountColors.length];
  }

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

  void _showAccountSelector(List<Account> accounts) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAccountSelectorBottomSheet(accounts),
    );
  }

  void _onAccountSelected(String accountId) async {
    final prefsService = await PreferencesService.getInstance();
    await prefsService.setSelectedAccount(accountId);

    if (mounted) {
      setState(() {
        _selectedAccountId = accountId;
      });
    }
  }

  /// Figma-styled Account Selector Pill Widget
  Widget _buildFigmaAccountSelectorPill({
    required Account? account,
    required List<Account> accounts,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    final accountIndex = account != null ? accounts.indexOf(account) : 0;
    final accountColor = _getAccountColor(accountIndex >= 0 ? accountIndex : 0);

    final pillBg = isDark ? const Color(0x14FFFFFF) : const Color(0xFFF5F5F7);
    final pillBorder = isDark ? const Color(0x1FFFFFFF) : const Color(0x12000000);
    final textColor = isDark ? const Color(0xFFF0F0F0) : const Color(0xFF111111);
    final chevronColor = isDark ? const Color(0xFFA0A0A0) : const Color(0xFF888888);

    return GestureDetector(
      onTap: () => _showAccountSelector(accounts),
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
        decoration: BoxDecoration(
          color: pillBg,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: pillBorder, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Badge
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: accountColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: accountColor.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.credit_card,
                  color: accountColor,
                  size: 15,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                account?.name ?? l10n.noAccount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down,
              color: chevronColor,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  /// Figma-styled User Avatar / Settings Button
  Widget _buildSettingsAvatarButton(BuildContext context, bool isDark) {
    final user = UserService.instance.currentUser;
    final accentColor = isDark ? const Color(0xFF00E5A0) : const Color(0xFF009E76);

    String initial = "A";
    if (user != null) {
      if (user.name.trim().isNotEmpty) {
        initial = user.name.trim()[0].toUpperCase();
      } else if (user.email.trim().isNotEmpty) {
        initial = user.email.trim()[0].toUpperCase();
      }
    }

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/settings'),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(
            color: accentColor.withValues(alpha: 0.27),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            initial,
            style: TextStyle(
              color: accentColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  /// Figma-styled Account Selector Modal Bottom Sheet
  Widget _buildAccountSelectorBottomSheet(List<Account> accounts) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final sheetBg = isDark ? const Color(0xFF181818) : const Color(0xFFFFFFFF);
    final textPrimary = isDark ? const Color(0xFFF0F0F0) : const Color(0xFF111111);
    final textSecondary = isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B70);
    final handleColor = isDark ? const Color(0x26FFFFFF) : const Color(0x1F000000);
    final itemBg = isDark ? const Color(0x0FFFFFFF) : const Color(0xFFF5F5F7);
    final borderColor = isDark ? const Color(0x14FFFFFF) : const Color(0x12000000);
    final accentGreen = isDark ? const Color(0xFF00E5A0) : const Color(0xFF009E76);

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: isDark ? Border.all(color: borderColor) : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: handleColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.selectAccount,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: itemBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor),
                      ),
                      child: Icon(Icons.close, color: textSecondary, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Account List
              if (accounts.isNotEmpty)
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: accounts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      final isSelected = _selectedAccountId == account.id;
                      final accountColor = _getAccountColor(index);

                      return GestureDetector(
                        onTap: () {
                          _onAccountSelected(account.id);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? itemBg : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? accountColor.withValues(alpha: 0.3) : Colors.transparent,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Glowing Dot Indicator
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: accountColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: accountColor.withValues(alpha: 0.5),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      account.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: textPrimary,
                                      ),
                                    ),
                                    if (account.description.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          account.description,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: textSecondary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: accentGreen,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              Divider(color: borderColor, height: 1),
              const SizedBox(height: 12),

              // Add Account Action
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accentGreen.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, color: accentGreen, size: 20),
                ),
                title: Text(
                  l10n.addNewAccountAction,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/add-account');
                },
              ),

              // Manage Accounts Action
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.settings_outlined, color: textSecondary, size: 20),
                ),
                title: Text(
                  l10n.manageAccountsAction,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/manage-accounts');
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accountsAsync = ref.watch(accountsProvider);

    return accountsAsync.when(
      data: (accounts) {
        if (_selectedAccountId == null && accounts.isNotEmpty && !_isInit) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _selectedAccountId == null) {
              _onAccountSelected(accounts.first.id);
            }
          });
        }

        return _buildScaffoldWithAccount(context, l10n, theme, isDark, accounts);
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text(l10n.appTitle),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.appTitle),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildScaffoldWithAccount(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
    List<Account> accounts,
  ) {
    Account? currentAccount;
    if (_selectedAccountId != null) {
      try {
        currentAccount = accounts.firstWhere((a) => a.id == _selectedAccountId);
      } catch (_) {
        if (accounts.isNotEmpty) {
          currentAccount = accounts.first;
        }
      }
    } else if (accounts.isNotEmpty) {
      currentAccount = accounts.first;
    }

    final scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: _buildFigmaAccountSelectorPill(
          account: currentAccount,
          accounts: accounts,
          isDark: isDark,
          l10n: l10n,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: _buildSettingsAvatarButton(context, isDark),
          ),
        ],
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
