import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/preferences_service.dart';
import '../services/theme_service.dart';
import '../services/user_service.dart';

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
          // Currency Section
          _buildSectionHeader(l10n.currency),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: Text(l10n.currency),
            subtitle: Text(
              _currentCurrencyName ?? _currentCurrency ?? l10n.usd,
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _changeCurrency,
          ),
          const Divider(),

          // Appearance Section
          _buildSectionHeader(l10n.appearance),
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(l10n.theme),
            subtitle: Text(
              ThemeService.instance.getCurrentThemeDisplayName(l10n),
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _showThemeSelectionDialog,
          ),
          const Divider(),

          // Accounts Section
          _buildSectionHeader(l10n.accounts),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: Text(l10n.manageAccounts),
            subtitle: Text(l10n.manageAccountsSubtitle),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _navigateToManageAccounts,
          ),
          const Divider(),

          // Categories Section
          _buildSectionHeader(l10n.categories),
          ListTile(
            leading: const Icon(Icons.category),
            title: Text(l10n.categories),
            subtitle: Text(l10n.manageCategories),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _navigateToCategories,
          ),
          const Divider(),

          // Payment Sources Section
          _buildSectionHeader(l10n.paymentSources),
          ListTile(
            leading: const Icon(Icons.payment),
            title: Text(l10n.paymentSourcesTitle),
            subtitle: Text(l10n.paymentSourcesSubtitle),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _navigateToPaymentSources,
          ),
          const Divider(),

          // Data & Privacy Section
          _buildSectionHeader(l10n.dataPrivacy),
          ListTile(
            leading: const Icon(Icons.backup),
            title: Text(l10n.backup),
            subtitle: Text(l10n.notConnected),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showComingSoonSnackBar(l10n.backup),
          ),
          const Divider(),

          // Notifications Section - Hidden for now
          // _buildSectionHeader(l10n.notifications),
          // ListTile(
          //   leading: const Icon(Icons.notifications),
          //   title: Text(l10n.notifications),
          //   subtitle: Text(l10n.enabled),
          //   trailing: const Icon(Icons.arrow_forward_ios),
          //   onTap: () => _showComingSoonSnackBar(l10n.notifications),
          // ),
          // const Divider(),

          // About Section
          _buildSectionHeader(l10n.about),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(l10n.about),
            subtitle: Text('${l10n.version} 1.0.0'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showComingSoonSnackBar(l10n.about),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
