import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_manager/services/theme_service.dart';
import 'package:money_manager/l10n/app_localizations.dart';

void main() {
  group('ThemeService', () {
    late ThemeService themeService;

    setUp(() async {
      // Initialize SharedPreferences with empty values for testing
      SharedPreferences.setMockInitialValues({});
      themeService = ThemeService.instance;
      await themeService.initialize();
    });

    test('should initialize with system theme by default', () {
      expect(themeService.currentTheme, equals(AppThemeMode.system));
    });

    test('should save and retrieve selected theme', () async {
      // Test setting light theme
      await themeService.setTheme(AppThemeMode.light);
      expect(themeService.currentTheme, equals(AppThemeMode.light));

      // Test setting dark theme
      await themeService.setTheme(AppThemeMode.dark);
      expect(themeService.currentTheme, equals(AppThemeMode.dark));

      // Test setting system theme
      await themeService.setTheme(AppThemeMode.system);
      expect(themeService.currentTheme, equals(AppThemeMode.system));
    });

    test('should persist theme across app restarts', () async {
      // Set a theme
      await themeService.setTheme(AppThemeMode.dark);
      expect(themeService.currentTheme, equals(AppThemeMode.dark));

      // Create a new instance to simulate app restart
      final newThemeService = ThemeService.instance;
      await newThemeService.initialize();

      expect(newThemeService.currentTheme, equals(AppThemeMode.dark));
    });

    test('should return correct theme mode for Flutter', () {
      // Test light theme mode
      themeService.setTheme(AppThemeMode.light);
      expect(themeService.themeMode, equals(ThemeMode.light));

      // Test dark theme mode
      themeService.setTheme(AppThemeMode.dark);
      expect(themeService.themeMode, equals(ThemeMode.dark));

      // Test system theme mode
      themeService.setTheme(AppThemeMode.system);
      expect(themeService.themeMode, equals(ThemeMode.system));
    });

    test('should provide light and dark theme data', () {
      final lightTheme = themeService.lightTheme;
      final darkTheme = themeService.darkTheme;

      expect(lightTheme.brightness, equals(Brightness.light));
      expect(darkTheme.brightness, equals(Brightness.dark));
      expect(lightTheme.useMaterial3, isTrue);
      expect(darkTheme.useMaterial3, isTrue);
    });

    test('should notify listeners when theme changes', () async {
      bool notified = false;
      themeService.addListener(() {
        notified = true;
      });

      await themeService.setTheme(AppThemeMode.dark);
      expect(notified, isTrue);
    });

    test('should not notify listeners when setting same theme', () async {
      await themeService.setTheme(AppThemeMode.light);

      bool notified = false;
      themeService.addListener(() {
        notified = true;
      });

      // Set the same theme again
      await themeService.setTheme(AppThemeMode.light);
      expect(notified, isFalse);
    });
  });
}
