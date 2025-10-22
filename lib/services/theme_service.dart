import 'package:flutter/material.dart';
import 'preferences_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

enum AppThemeMode { light, dark, system }

class ThemeService extends ChangeNotifier {
  static ThemeService? _instance;
  PreferencesService? _preferencesService;
  AppThemeMode _currentTheme = AppThemeMode.system;

  static ThemeService get instance {
    _instance ??= ThemeService._();
    return _instance!;
  }

  ThemeService._();

  AppThemeMode get currentTheme => _currentTheme;

  Future<void> initialize() async {
    _preferencesService = await PreferencesService.getInstance();
    final savedTheme = _preferencesService!.getSelectedTheme();
    _currentTheme = _parseThemeMode(savedTheme);
  }

  AppThemeMode _parseThemeMode(String themeString) {
    switch (themeString.toLowerCase()) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
      default:
        return AppThemeMode.system;
    }
  }

  String _themeToString(AppThemeMode theme) {
    switch (theme) {
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.system:
        return 'system';
    }
  }

  Future<void> setTheme(AppThemeMode theme) async {
    if (_currentTheme != theme) {
      _currentTheme = theme;
      await _preferencesService?.setSelectedTheme(_themeToString(theme));
      notifyListeners();
    }
  }

  ThemeMode get themeMode {
    switch (_currentTheme) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  ThemeData get lightTheme {
    return AppTheme.lightTheme;
  }

  ThemeData get darkTheme {
    return AppTheme.darkTheme;
  }

  String getThemeDisplayName(AppThemeMode theme, AppLocalizations l10n) {
    switch (theme) {
      case AppThemeMode.light:
        return l10n.light;
      case AppThemeMode.dark:
        return l10n.dark;
      case AppThemeMode.system:
        return l10n.system;
    }
  }

  String getCurrentThemeDisplayName(AppLocalizations l10n) {
    return getThemeDisplayName(_currentTheme, l10n);
  }
}
