import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/preferences_service.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PreferencesService? _preferencesService;
  String? _currentCurrency;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    _preferencesService = await PreferencesService.getInstance();
    _currentCurrency = _preferencesService!.getSelectedCurrency();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _changeCurrency() async {
    final selectedCurrency = await Navigator.of(context).pushNamed(
      '/currency-selection-settings',
      arguments: {'currentCurrency': _currentCurrency},
    );

    if (selectedCurrency != null && selectedCurrency != _currentCurrency) {
      setState(() {
        _currentCurrency = selectedCurrency as String;
      });

      // Show confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Currency changed to $_currentCurrency'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is coming soon!'),
        duration: const Duration(seconds: 2),
      ),
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
          // Currency Section
          _buildSectionHeader(l10n.currency),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: Text(l10n.currency),
            subtitle: Text(_currentCurrency ?? 'USD'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _changeCurrency,
          ),
          const Divider(),

          // Appearance Section
          _buildSectionHeader('Appearance'),
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

          // Data & Privacy Section
          _buildSectionHeader('Data & Privacy'),
          ListTile(
            leading: const Icon(Icons.backup),
            title: Text(l10n.backup),
            subtitle: const Text('Not connected'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showComingSoonSnackBar(l10n.backup),
          ),
          const Divider(),

          // Notifications Section - Hidden for now
          // _buildSectionHeader(l10n.notifications),
          // ListTile(
          //   leading: const Icon(Icons.notifications),
          //   title: Text(l10n.notifications),
          //   subtitle: const Text('Enabled'),
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
