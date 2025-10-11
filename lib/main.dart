import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'screens/intro_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth_choice_screen.dart';
import 'screens/currency_selection_screen.dart';
import 'screens/backup_account_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/settings_screen.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.instance.initialize();
  runApp(const MoneyManagerApp());
}

class MoneyManagerApp extends StatefulWidget {
  const MoneyManagerApp({super.key});

  @override
  State<MoneyManagerApp> createState() => _MoneyManagerAppState();
}

class _MoneyManagerAppState extends State<MoneyManagerApp> {
  @override
  void initState() {
    super.initState();
    ThemeService.instance.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeService.instance.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Manager',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeService.instance.lightTheme,
      darkTheme: ThemeService.instance.darkTheme,
      themeMode: ThemeService.instance.themeMode,
      home: const IntroScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/auth-choice': (context) => const AuthChoiceScreen(),
        '/currency-selection': (context) => const CurrencySelectionScreen(),
        '/backup-account': (context) => const BackupAccountScreen(),
        '/sign-in': (context) => const SignInScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/currency-selection-settings') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => CurrencySelectionScreen(
              isFromSettings: true,
              currentCurrency: args?['currentCurrency'],
            ),
          );
        }
        return null;
      },
    );
  }
}
