import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/services/firebase_auth_service.dart';
import 'l10n/app_localizations.dart';
import 'screens/intro_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth_choice_screen.dart';
import 'screens/currency_selection_screen.dart';
import 'screens/backup_account_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/category_screen.dart';
import 'screens/payment_sources_screen.dart';
import 'screens/manage_accounts_screen.dart';
import 'screens/account_details_screen.dart';
import 'screens/add_account_screen.dart';
import 'models/account.dart';
import 'services/theme_service.dart';
import 'services/data_service.dart';
import 'services/device_record_service.dart';
import 'services/user_service.dart';
import 'services/account_service.dart';
import 'services/nudge_service.dart';
import 'services/category_service.dart';
import 'services/payment_source_service.dart';
import 'services/firebase_service.dart';
import 'services/logging_service.dart';
import 'services/sync_service.dart';
import 'database/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize logging service first
    LoggingService.initialize();

    // Initialize Firebase first
    await FirebaseService.instance.initialize();

    // Initialize core services
    await ThemeService.instance.initialize();

    // Initialize database and wait for it to complete
    await DatabaseService.instance.initialize();

    // Initialize services that depend on database
    await DataService.instance.initialize();
    await CategoryService.instance.initialize();
    await PaymentSourceService.instance.initialize();

    // Initialize other services
    await DeviceRecordService.instance.initialize();
    await UserService.instance.initialize();
    await AccountService.instance.initialize();
    await NudgeService.instance.initialize();
    await SyncService.instance.initialize();

    // Set up Firebase token refresh callback (for when user grants permission later)
    FirebaseService.instance.setOnTokenRefresh((newToken) {
      DeviceRecordService.instance.updateFcmToken(newToken);
    });

    // log jwt
    log('JWT: ${(await FirebaseAuthService.instance.getIdToken()).toString()}');

    // Note: FCM token will be fetched only when user grants notification permission

    // Schedule sync of pending transactions after app startup (non-blocking)
    // Delay by 2 seconds to allow app to fully initialize and render
    Future.delayed(const Duration(seconds: 2), () {
      SyncService.instance.syncPendingTransactions();
    });

    runApp(const ProviderScope(child: MoneyManagerApp()));
  } catch (e) {
    // Use logging service for app initialization errors
    final log = LoggingService.getLogger('Main');
    log.e('Failed to initialize app', error: e);
    // Run app anyway with error handling
    runApp(const ProviderScope(child: MoneyManagerApp()));
  }
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

  /// Determine the initial screen based on user existence and onboarding status
  Widget _getInitialScreen() {
    final userService = UserService.instance;

    // If user exists and onboarding is complete, go to home screen
    if (userService.hasUser) {
      return const HomeScreen();
    }

    // Otherwise, start with intro screen for new users
    return const IntroScreen();
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
      home: _getInitialScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/auth-choice': (context) => const AuthChoiceScreen(),
        '/currency-selection': (context) => const CurrencySelectionScreen(),
        '/backup-account': (context) => const BackupAccountScreen(),
        '/sign-in': (context) => const SignInScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/categories': (context) => const CategoryScreen(),
        '/payment-sources': (context) => const PaymentSourcesScreen(),
        '/manage-accounts': (context) => const ManageAccountsScreen(),
        '/add-account': (context) => const AddAccountScreen(),
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

        if (settings.name == '/account-details') {
          final account = settings.arguments as Account?;
          if (account != null) {
            return MaterialPageRoute(
              builder: (context) => AccountDetailsScreen(account: account),
            );
          }
        }

        return null;
      },
    );
  }
}
