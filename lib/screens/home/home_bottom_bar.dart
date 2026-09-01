import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/account.dart';
import '../history_screen.dart';
import '../add_edit_transaction_screen.dart';
import 'analytics_screen.dart';

enum HomeBottomBarTab {
  home,
  history,
  analytics,
  settings,
}

class HomeBottomBarWidget extends StatelessWidget {
  final Account? account;
  final HomeBottomBarTab currentTab;
  final ValueChanged<HomeBottomBarTab>? onTabSelected;

  const HomeBottomBarWidget({
    super.key,
    this.account,
    this.currentTab = HomeBottomBarTab.home,
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final barBg = isDark ? const Color(0xFF181818) : const Color(0xFFFFFFFF);
    final borderTopColor =
        isDark ? const Color(0x14FFFFFF) : const Color(0x12000000);

    return Container(
      decoration: BoxDecoration(
        color: barBg,
        border: Border(
          top: BorderSide(color: borderTopColor, width: 1),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Row of Navigation Tabs
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Home Tab
                  Expanded(
                    child: _buildNavItem(
                      context: context,
                      tab: HomeBottomBarTab.home,
                      icon: Icons.home_rounded,
                      label: l10n.appTitle == 'Money Manager' ? 'Home' : l10n.appTitle,
                      isDark: isDark,
                      onTap: () {
                        if (onTabSelected != null) {
                          onTabSelected!(HomeBottomBarTab.home);
                        } else if (currentTab != HomeBottomBarTab.home) {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        }
                      },
                    ),
                  ),

                  // 2. History Tab
                  Expanded(
                    child: _buildNavItem(
                      context: context,
                      tab: HomeBottomBarTab.history,
                      icon: Icons.receipt_long_rounded,
                      label: l10n.history,
                      isDark: isDark,
                      onTap: () {
                        if (onTabSelected != null) {
                          onTabSelected!(HomeBottomBarTab.history);
                        } else {
                          _navigateToTransactions(context);
                        }
                      },
                    ),
                  ),

                  // 3. Center Spacer for FAB
                  const SizedBox(width: 56),

                  // 4. Analytics Tab
                  Expanded(
                    child: _buildNavItem(
                      context: context,
                      tab: HomeBottomBarTab.analytics,
                      icon: Icons.analytics_rounded,
                      label: l10n.analytics,
                      isDark: isDark,
                      onTap: () {
                        if (onTabSelected != null) {
                          onTabSelected!(HomeBottomBarTab.analytics);
                        } else {
                          _navigateToAnalytics(context);
                        }
                      },
                    ),
                  ),

                  // 5. Settings Tab
                  Expanded(
                    child: _buildNavItem(
                      context: context,
                      tab: HomeBottomBarTab.settings,
                      icon: Icons.settings_rounded,
                      label: l10n.settings,
                      isDark: isDark,
                      onTap: () {
                        if (onTabSelected != null) {
                          onTabSelected!(HomeBottomBarTab.settings);
                        } else {
                          _navigateToSettings(context);
                        }
                      },
                    ),
                  ),
                ],
              ),

              // Floating Center Action Button (Add Transaction)
              Positioned(
                top: -22,
                child: _buildFab(context, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Individual Navigation Item with active glowing bottom indicator
  Widget _buildNavItem({
    required BuildContext context,
    required HomeBottomBarTab tab,
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isActive = currentTab == tab;
    final activeColor =
        isDark ? const Color(0xFF00E5A0) : const Color(0xFF009E76);
    final inactiveColor =
        isDark ? const Color(0xFF6B6B6B) : const Color(0xFF8E8E93);
    final color = isActive ? activeColor : inactiveColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          // Active Glow Bottom Line Indicator (36x2.5)
          if (isActive)
            Positioned(
              bottom: 0,
              child: Container(
                width: 36,
                height: 2.5,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.6),
                      blurRadius: 8,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Center Floating Add Action Button
  Widget _buildFab(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _navigateToAddTransaction(context),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF00E5A0), // Mint
              Color(0xFF00B4D8), // Cyan
            ],
          ),
          border: Border.all(
            color: isDark ? const Color(0xFF181818) : const Color(0xFFFFFFFF),
            width: 3.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5A0).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: const Color(0xFF00E5A0).withValues(alpha: 0.15),
              blurRadius: 40,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.add_rounded,
            size: 28,
            color: Color(0xFF0A1A14),
          ),
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
