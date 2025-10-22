import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../l10n/app_localizations.dart';
import '../services/firebase_auth_service.dart';
import '../services/logging_service.dart';
import '../services/user_service.dart';
import '../services/device_record_service.dart';
import '../services/account_service.dart';
import '../services/auth_api_service.dart';
import '../services/firebase_service.dart';
import '../services/transaction_api_service.dart';
import '../database/database_service.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  Future<void> _onGoogleSignIn(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final log = LoggingService.getLogger('SignInScreen');

    if (!context.mounted) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(l10n.signingIn),
              ],
            ),
          ),
        );
      },
    );

    try {
      log.i('Starting Google sign-in flow');

      // Step 1: Sign in with Google
      final firebaseAuthService = FirebaseAuthService.instance;
      final userCredential = await firebaseAuthService.signInWithGoogle();

      if (userCredential == null || userCredential.user == null) {
        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.signInFailed)));
        }
        return;
      }

      log.d('Google sign-in successful, UID: ${userCredential.user!.uid}');

      // Step 2: Check if user is new
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      log.d('Is new user: $isNewUser');

      if (!context.mounted) return;

      if (isNewUser) {
        // New user - show dialog to create account
        Navigator.of(context).pop(); // Close loading dialog
        await _showNewAccountDialog(context, userCredential);
      } else {
        // Existing user - fetch user details from backend
        await _fetchExistingUserDetails(context, userCredential);
      }
    } catch (e) {
      log.e('Google sign-in failed', error: e);
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.signInFailed)));
      }
    }
  }

  Future<void> _showNewAccountDialog(
    BuildContext context,
    UserCredential userCredential,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final log = LoggingService.getLogger('SignInScreen');

    final googleUser = userCredential.user;
    if (googleUser == null) return;

    log.d('Showing new account dialog for: ${googleUser.email}');

    if (!context.mounted) return;

    final shouldCreateAccount = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.newAccountDetected),
          content: Text(l10n.noAssociatedDetailsMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.createAccount),
            ),
          ],
        );
      },
    );

    if (shouldCreateAccount == null || !shouldCreateAccount) {
      // User declined - sign out and return to getting started
      log.d('User declined account creation');
      if (context.mounted) {
        await _signOutAndReturnToGettingStarted(context);
      }
      return;
    }

    // User wants to create account - proceed with account creation
    if (context.mounted) {
      await _createNewGoogleAccount(context, userCredential);
    }
  }

  Future<void> _createNewGoogleAccount(
    BuildContext context,
    UserCredential userCredential,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final log = LoggingService.getLogger('SignInScreen');

    if (!context.mounted) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(l10n.signingIn),
              ],
            ),
          ),
        );
      },
    );

    try {
      final googleUser = userCredential.user;
      if (googleUser == null) {
        throw Exception('Google user is null');
      }

      log.i('Creating new account for Google user: ${googleUser.email}');

      // Step 1: Get Firebase ID token
      final firebaseAuthService = FirebaseAuthService.instance;
      final idToken = await firebaseAuthService.getIdToken(true);
      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }
      log.d('Firebase ID token obtained');

      // Step 2: Prepare user details from Google auth
      final userService = UserService.instance;
      final user = userService.buildUser(
        email: googleUser.email ?? '',
        name: googleUser.displayName ?? 'User',
        profilePic: googleUser.photoURL ?? '',
      );
      log.d('User object prepared with Google details');

      // Step 3: Get device details
      final deviceService = DeviceRecordService.instance;
      final deviceRecord = deviceService.currentDeviceRecord;
      if (deviceRecord == null) {
        throw Exception('Device record not available');
      }
      log.d('Device record obtained');

      // Step 4: Get FCM token if available
      final fcmToken = FirebaseService.instance.fcmToken;
      log.d('FCM token: ${fcmToken != null ? 'available' : 'not available'}');

      // Step 5: Call backend API to register Google account
      log.i('Calling backend register API for Google account');
      final authApiService = AuthApiService.instance;
      final authResponse = await authApiService.register(
        firebaseIdToken: idToken,
        firebaseUid: googleUser.uid,
        userDetails: user,
        deviceDetails: deviceRecord,
        fcmToken: fcmToken,
      );
      log.i('Backend registration successful');

      // Step 6: Save user, account, and device locally after successful API response
      log.d('Saving user, account, and device locally');
      // refresh idtoken
      await userService.saveUserFromResponse(authResponse.user);
      for (final account in authResponse.accounts) {
        await AccountService.instance.saveAccountFromResponse(account);
      }
      await deviceService.saveDeviceFromResponse(authResponse.device);
      log.d('User, account, and device saved successfully');

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      // Navigate to backup account screen
      log.i('Account created successfully, navigating to backup account');
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } catch (e) {
      log.e('Account creation failed', error: e);
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }

      // Sign out the Google user so they can retry
      try {
        log.i('Signing out Google user due to account creation failure');
        await FirebaseAuthService.instance.signOut();
      } catch (signOutError) {
        log.e(
          'Failed to sign out after account creation failure',
          error: signOutError,
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.accountCreationFailed)));
      }
    }
  }

  Future<void> _fetchExistingUserDetails(
    BuildContext context,
    UserCredential userCredential,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final log = LoggingService.getLogger('SignInScreen');

    if (!context.mounted) return;

    // Update loading dialog message
    Navigator.of(context).pop(); // Close previous loading dialog

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(l10n.fetchingUserDetails),
              ],
            ),
          ),
        );
      },
    );

    try {
      final googleUser = userCredential.user;
      if (googleUser == null) {
        throw Exception('Google user is null');
      }

      log.i('Fetching existing user details from backend');

      // Step 1: Get Firebase ID token
      final firebaseAuthService = FirebaseAuthService.instance;
      final idToken = await firebaseAuthService.getIdToken(true);
      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }
      log.d('Firebase ID token obtained');

      // Step 2: Prepare user details from Google auth
      final userService = UserService.instance;
      final user = userService.buildUser(
        email: googleUser.email ?? '',
        name: googleUser.displayName ?? 'User',
        profilePic: googleUser.photoURL ?? '',
      );
      log.d('User object prepared with Google details');

      // Step 3: Get device details
      final deviceService = DeviceRecordService.instance;
      final deviceRecord = deviceService.currentDeviceRecord;
      if (deviceRecord == null) {
        throw Exception('Device record not available');
      }
      log.d('Device record obtained');

      // Step 4: Get FCM token if available
      final fcmToken = FirebaseService.instance.fcmToken;
      log.d('FCM token: ${fcmToken != null ? 'available' : 'not available'}');

      // Step 5: Call backend API to register/fetch existing Google account
      log.i('Calling backend register API for existing Google account');
      final authApiService = AuthApiService.instance;
      final authResponse = await authApiService.register(
        firebaseIdToken: idToken,
        firebaseUid: googleUser.uid,
        userDetails: user,
        deviceDetails: deviceRecord,
        fcmToken: fcmToken,
      );
      log.i('Backend registration successful');

      // Step 6: Save user, account, and device locally after successful API response
      log.d('Saving user, account, and device locally');
      await userService.saveUserFromResponse(authResponse.user);
      for (final account in authResponse.accounts) {
        await AccountService.instance.saveAccountFromResponse(account);
      }

      await deviceService.saveDeviceFromResponse(authResponse.device);
      log.d('User, account, and device saved successfully');

      // Step 7: Fetch transactions asynchronously for all accounts
      log.i('Starting async transaction fetch for all accounts');
      await _fetchTransactionsForAllAccounts();
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      // Navigate to home
      log.i('User details fetched successfully, navigating to home');
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } catch (e) {
      log.e('Failed to fetch user details', error: e);
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }

      // Sign out the Google user so they can retry
      try {
        log.i('Signing out Google user due to fetch failure');
        await FirebaseAuthService.instance.signOut();
      } catch (signOutError) {
        log.e('Failed to sign out after fetch failure', error: signOutError);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.signInFailed)));
      }
    }
  }

  Future<void> _signOutAndReturnToGettingStarted(BuildContext context) async {
    final log = LoggingService.getLogger('SignInScreen');
    final l10n = AppLocalizations.of(context)!;

    try {
      log.i('Signing out user');

      // Step 1: Get current Firebase UID
      final firebaseAuthService = FirebaseAuthService.instance;
      final currentUser = firebaseAuthService.getCurrentUser();

      if (currentUser != null) {
        log.d('Current user UID: ${currentUser.uid}');

        // Step 2: Call remove user API
        try {
          log.i('Calling remove user API');
          final authApiService = AuthApiService.instance;
          await authApiService.removeUser(firebaseUID: currentUser.uid);
          log.i('Remove user API call successful');
        } catch (apiError) {
          log.e('Remove user API call failed', error: apiError);
          // Continue with sign out even if API call fails
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.failedToRemoveUser),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }

      // Step 3: Sign out from Firebase
      log.i('Signing out from Firebase');
      await firebaseAuthService.signOut();
      log.i('Firebase sign out successful');

      if (context.mounted) {
        // Navigate back to getting started screen
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/auth-choice', (route) => false);
      }
    } catch (e) {
      log.e('Failed to sign out', error: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.signOutFailed),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Fetch transactions for all user accounts asynchronously
  /// Starts with current timestamp and fetches transactions in batches of 50
  /// Continues fetching until a batch has less than 50 transactions
  Future<void> _fetchTransactionsForAllAccounts() async {
    final log = LoggingService.getLogger('SignInScreen');
    log.entering('_fetchTransactionsForAllAccounts');

    try {
      String jwtToken = await FirebaseAuthService.instance.getIdToken() ?? '';
      log.d('JWT: $jwtToken');
      if (jwtToken.isEmpty) {
        log.w('JWT is empty, skipping transaction fetch');
        log.exiting('_fetchTransactionsForAllAccounts');
        return;
      }
      // Get all accounts for the current user
      final accounts = await AccountService.instance.accounts;
      log.d('Found ${accounts.length} accounts for transaction fetch');

      if (accounts.isEmpty) {
        log.d('No accounts found, skipping transaction fetch');
        log.exiting('_fetchTransactionsForAllAccounts');
        return;
      }

      // Fetch transactions for each account asynchronously (don't wait)
      for (final account in accounts) {
        await _fetchTransactionsForAccount(account.id, jwtToken);
      }

      log.exiting('_fetchTransactionsForAllAccounts');
    } catch (e) {
      log.e('Error fetching transactions for all accounts', error: e);
      log.exiting('_fetchTransactionsForAllAccounts');
    }
  }

  /// Fetch transactions for a specific account in batches
  /// Starts with current timestamp and continues until a batch has less than 50 transactions
  Future<void> _fetchTransactionsForAccount(
    String accountId,
    String jwtToken,
  ) async {
    final log = LoggingService.getLogger('SignInScreen');
    log.entering('_fetchTransactionsForAccount');

    try {
      final transactionApiService = TransactionApiService.instance;
      int currentTimestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
      int batchCount = 0;

      while (true) {
        batchCount++;
        log.d(
          'Fetching batch $batchCount for account $accountId, timestamp: $currentTimestamp',
        );

        // Fetch transactions before current timestamp
        final transactions = await transactionApiService
            .getTransactionsByAccountAndTimestamp(
              accountId: accountId,
              timestamp: currentTimestamp,
              jwtToken: jwtToken,
            );

        log.d(
          'Fetched ${transactions.length} transactions in batch $batchCount for account $accountId',
        );

        // Save transactions to local database
        for (final transaction in transactions) {
          try {
            await DatabaseService.instance.transactionDao.insert(transaction);
          } catch (e) {
            log.w(
              'Failed to save transaction ${transaction.id} locally',
              error: e,
            );
          }
        }

        // If we got less than 50 transactions, we've reached the end
        if (transactions.length < 50) {
          log.d(
            'Reached end of transactions for account $accountId (batch $batchCount had ${transactions.length} transactions)',
          );
          break;
        }

        // If we got exactly 50 transactions, prepare for next batch
        // The next timestamp should be the last transaction's timestamp
        if (transactions.isNotEmpty) {
          final lastTransaction = transactions.last;
          currentTimestamp = lastTransaction.transactionDate;
          log.d(
            'Continuing to next batch for account $accountId, new timestamp: $currentTimestamp',
          );
        } else {
          break;
        }
      }

      log.d(
        'Completed transaction fetch for account $accountId (total batches: $batchCount)',
      );
      log.exiting('_fetchTransactionsForAccount');
    } catch (e) {
      log.e('Error fetching transactions for account $accountId', error: e);
      log.exiting('_fetchTransactionsForAccount');
    }
  }

  void _onAppleSignIn(BuildContext context) {
    // TODO: Implement Apple Sign-in with account detection
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.appleSignInComingSoon),
        duration: const Duration(seconds: 2),
      ),
    );
    // For now, navigate to home
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  void _onStartFresh(BuildContext context) {
    // Navigate to currency selection (anonymous flow)
    Navigator.of(context).pushReplacementNamed('/currency-selection');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Top spacing
                const SizedBox(height: 40),

                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.login,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  l10n.welcomeBack,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  l10n.signInToRestoreData,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Google Sign-in button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () => _onGoogleSignIn(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 2,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(
                      Icons.g_mobiledata,
                      size: 24,
                      color: Colors.red,
                    ),
                    label: Text(
                      l10n.signInWithGoogle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Google subtitle
                Text(
                  l10n.restoreYourData,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Apple Sign-in button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () => _onAppleSignIn(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.apple, size: 24),
                    label: Text(
                      l10n.signInWithApple,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Apple subtitle
                Text(
                  l10n.secureAndPrivate,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Divider with "or"
                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: Colors.grey, thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.or,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: Colors.grey, thickness: 1),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Start Fresh button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => _onStartFresh(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.startFresh,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Helper text
                Text(
                  l10n.notYouSignInDifferent,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
