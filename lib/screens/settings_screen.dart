import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/preferences_service.dart';
import '../services/theme_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/settings_section_card.dart';
import 'backup_account_screen.dart';
import 'user_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PreferencesService? _preferencesService;
  String? _currentCurrency;
  String? _currentCurrencyName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    _preferencesService = await PreferencesService.getInstance();

    // Get currency from user record instead of preferences
    final currentUser = UserService.instance.currentUser;
    if (currentUser != null) {
      _currentCurrency = currentUser.currencyCode.isNotEmpty
          ? currentUser.currencyCode
          : null;
      _currentCurrencyName = currentUser.currencyName.isNotEmpty
          ? currentUser.currencyName
          : null;
    }

    // Fallback to preferences if user doesn't have currency set
    _currentCurrency ??= _preferencesService!.getSelectedCurrency();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _changeCurrency() async {
    final result = await Navigator.of(context).pushNamed(
      '/currency-selection-settings',
      arguments: {'currentCurrency': _currentCurrency},
    );

    if (result != null && result is Map<String, String>) {
      final selectedCurrencyCode = result['code'];
      final selectedCurrencyName = result['name'];

      if (selectedCurrencyCode != null &&
          selectedCurrencyCode != _currentCurrency) {
        try {
          // Update user record with new currency
          await UserService.instance.updateUser(
            currencyCode: selectedCurrencyCode,
            currencyName: selectedCurrencyName,
          );

          setState(() {
            _currentCurrency = selectedCurrencyCode;
            _currentCurrencyName = selectedCurrencyName;
          });

          // Show confirmation
          if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.currencyChangedTo(_currentCurrency!)),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          // Show error message
          if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.failedToUpdateCurrency(e.toString())),
                duration: const Duration(seconds: 3),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      }
    }
  }

  void _showComingSoonSnackBar(String feature) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.comingSoon(feature)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToCategories() {
    Navigator.of(context).pushNamed('/categories');
  }

  void _navigateToPaymentSources() {
    Navigator.of(context).pushNamed('/payment-sources');
  }

  void _navigateToManageAccounts() {
    Navigator.of(context).pushNamed('/manage-accounts');
  }

  void _navigateToBackupAccount() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BackupAccountScreen(isFromSettings: true),
      ),
    );
  }

  void _navigateToUserProfile() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const UserProfileScreen()));
  }

  Widget _buildInitialsAvatar(String name, ThemeData theme) {
    String initials = '';
    if (name.isNotEmpty) {
      final parts = name.trim().split(' ');
      if (parts.isNotEmpty) {
        initials = parts[0][0].toUpperCase();
        if (parts.length > 1) {
          initials += parts[1][0].toUpperCase();
        }
      }
    }

    return Center(
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildUserProfileCard(AppLocalizations l10n) {
    final currentUser = UserService.instance.currentUser;
    final theme = Theme.of(context);
    final hasBackupAccount =
        currentUser != null && currentUser.email.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: GestureDetector(
        onTap: _navigateToUserProfile,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            children: [
              // Profile Picture
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                child:
                    currentUser?.profilePic != null &&
                        currentUser!.profilePic.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          currentUser.profilePic,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildInitialsAvatar(
                              currentUser.name,
                              theme,
                            );
                          },
                        ),
                      )
                    : _buildInitialsAvatar(currentUser?.name ?? '', theme),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser?.name ?? 'User',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (hasBackupAccount)
                      Text(
                        currentUser.email,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_rounded,
                              size: 14,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.addBackupAccount,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<SettingItem> _buildAccountSecurityItems(AppLocalizations l10n) {
    final currentUser = UserService.instance.currentUser;

    return [
      // User Profile Item
      SettingItem(
        title: l10n.userProfile,
        subtitle: l10n.viewUserDetails,
        leadingIcon: Icons.person,
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () => _showUserProfileInfo(currentUser, l10n),
      ),
      // Backup & Sync Item
      SettingItem(
        title: l10n.backup,
        subtitle: l10n.backupAccountSubtitle,
        leadingIcon: Icons.cloud_upload,
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: _navigateToBackupAccount,
      ),
    ];
  }

  void _showUserProfileInfo(dynamic currentUser, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.userProfile),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child:
                      currentUser?.profilePic != null &&
                          currentUser!.profilePic.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            currentUser.profilePic,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 40,
                                color: Theme.of(context).colorScheme.primary,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // Name
              Text(
                '${l10n.name}:',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(currentUser?.name ?? 'N/A'),
              const SizedBox(height: 12),
              // Email
              Text(
                '${l10n.email}:',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(currentUser?.email ?? 'N/A'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.ok),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showThemeSelectionDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final currentTheme = ThemeService.instance.currentTheme;

    final selectedTheme = await showDialog<AppThemeMode>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.theme),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<AppThemeMode>(
                title: Text(l10n.light),
                value: AppThemeMode.light,
                groupValue: currentTheme,
                onChanged: (AppThemeMode? value) {
                  Navigator.of(context).pop(value);
                },
              ),
              RadioListTile<AppThemeMode>(
                title: Text(l10n.dark),
                value: AppThemeMode.dark,
                groupValue: currentTheme,
                onChanged: (AppThemeMode? value) {
                  Navigator.of(context).pop(value);
                },
              ),
              RadioListTile<AppThemeMode>(
                title: Text(l10n.system),
                value: AppThemeMode.system,
                groupValue: currentTheme,
                onChanged: (AppThemeMode? value) {
                  Navigator.of(context).pop(value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );

    if (selectedTheme != null && selectedTheme != currentTheme) {
      await ThemeService.instance.setTheme(selectedTheme);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.themeChangedTo(
                ThemeService.instance.getCurrentThemeDisplayName(l10n),
              ),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.settings),
          backgroundColor: theme.colorScheme.inversePrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          // User Profile Header Card
          _buildUserProfileCard(l10n),

          // Preferences Section (Currency & Appearance)
          SettingsSectionCard(
            title: l10n.preferences,
            subtitle: l10n.currencyTheme,
            icon: Icons.tune,
            iconBackgroundColor: Colors.blue.withValues(alpha: 0.2),
            items: [
              SettingItem(
                title: l10n.currency,
                subtitle: _currentCurrencyName ?? _currentCurrency ?? l10n.usd,
                leadingIcon: Icons.attach_money,
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: _changeCurrency,
              ),
              SettingItem(
                title: l10n.theme,
                subtitle: ThemeService.instance.getCurrentThemeDisplayName(
                  l10n,
                ),
                leadingIcon: Icons.palette,
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: _showThemeSelectionDialog,
              ),
            ],
          ),

          // Management Section (Accounts, Categories, Payment Sources)
          SettingsSectionCard(
            title: l10n.management,
            subtitle: l10n.accountsCategoriesPayment,
            icon: Icons.settings_suggest,
            iconBackgroundColor: Colors.purple.withValues(alpha: 0.2),
            items: [
              SettingItem(
                title: l10n.manageAccounts,
                subtitle: l10n.manageAccountsSubtitle,
                leadingIcon: Icons.account_balance_wallet,
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: _navigateToManageAccounts,
              ),
              SettingItem(
                title: l10n.categories,
                subtitle: l10n.manageCategories,
                leadingIcon: Icons.category,
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: _navigateToCategories,
              ),
              SettingItem(
                title: l10n.paymentSourcesTitle,
                subtitle: l10n.paymentSourcesSubtitle,
                leadingIcon: Icons.payment,
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: _navigateToPaymentSources,
              ),
            ],
          ),

          // Account & Security Section (User Profile + Data & Privacy)
          SettingsSectionCard(
            title: l10n.accountAndSecurity,
            subtitle: l10n.userProfileAndBackup,
            icon: Icons.security,
            iconBackgroundColor: Colors.orange.withValues(alpha: 0.2),
            items: _buildAccountSecurityItems(l10n),
          ),

          // About Section
          SettingsSectionCard(
            title: l10n.about,
            subtitle: '${l10n.version} 1.0.0',
            icon: Icons.info,
            iconBackgroundColor: Colors.green.withValues(alpha: 0.2),
            items: [
              SettingItem(
                title: l10n.about,
                subtitle: l10n.appVersion,
                leadingIcon: Icons.info_outline,
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () => _showComingSoonSnackBar(l10n.about),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingLg),
        ],
      ),
    );
  }
}
