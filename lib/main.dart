import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'screens/intro_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth_choice_screen.dart';
import 'screens/currency_selection_screen.dart';
import 'screens/backup_account_screen.dart';
import 'screens/sign_in_screen.dart';

void main() {
  runApp(const MoneyManagerApp());
}

class MoneyManagerApp extends StatelessWidget {
  const MoneyManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Manager',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const IntroScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/auth-choice': (context) => const AuthChoiceScreen(),
        '/currency-selection': (context) => const CurrencySelectionScreen(),
        '/backup-account': (context) => const BackupAccountScreen(),
        '/sign-in': (context) => const SignInScreen(),
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
