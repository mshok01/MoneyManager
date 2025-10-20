import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/user_service.dart';
import '../services/device_record_service.dart';
import '../services/account_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/auth_api_service.dart';
import '../services/logging_service.dart';
import '../services/firebase_service.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  /// Handle "Get Started" button press - create new user with Firebase anonymous auth
  Future<void> _onGetStarted(BuildContext context) async {
    final log = LoggingService.getLogger('AuthChoiceScreen');
    try {
      // Show loading indicator
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      log.i('Starting Firebase anonymous authentication');

      // Step 1: Firebase anonymous sign-in
      final firebaseAuthService = FirebaseAuthService.instance;
      final credential = await firebaseAuthService.signInAnonymously();
      if (credential == null || credential.user == null) {
        throw Exception('Firebase anonymous sign-in failed');
      }

      final firebaseUid = credential.user!.uid;
      log.d('Firebase anonymous sign-in successful, UID: $firebaseUid');

      // Step 2: Get Firebase ID token
      final idToken = await firebaseAuthService.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }
      log.d('Firebase ID token obtained: $idToken');

      // Step 3: Prepare user and device details (WITHOUT saving locally yet)
      final userService = UserService.instance;
      final deviceService = DeviceRecordService.instance;

      // Build user object WITHOUT saving to database
      final user = userService.buildUser();
      log.d('User object prepared: ${user.id}');

      // Get device details
      final deviceRecord = deviceService.currentDeviceRecord;
      if (deviceRecord == null) {
        throw Exception('Device record not available');
      }
      log.d('Device record obtained');

      // Step 4: Get FCM token if available
      final fcmToken = FirebaseService.instance.fcmToken;
      log.d('FCM token: ${fcmToken != null ? 'available' : 'not available'}');

      // Step 5: Call backend API
      log.i('Calling backend authentication API');
      final authApiService = AuthApiService.instance;
      final authResponse = await authApiService.authenticateAnonymously(
        firebaseIdToken: idToken,
        firebaseUid: firebaseUid,
        userDetails: user,
        deviceDetails: deviceRecord,
        fcmToken: fcmToken,
      );
      log.i('Backend authentication successful');

      // Step 6: Save user, account, and device locally after successful API response
      log.d('Saving user, account, and device locally');
      await userService.saveUserFromResponse(authResponse.user);
      await AccountService.instance.saveAccountFromResponse(
        authResponse.account,
      );
      await deviceService.saveDeviceFromResponse(authResponse.device);
      log.d('User, account, and device saved successfully');

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();

        // Navigate directly to backup account screen (skip currency selection)
        Navigator.of(context).pushNamed('/backup-account');
      }
    } catch (e) {
      log.e('Get started failed', error: e);
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.failedToCreateUserAccount(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Top spacing
              const SizedBox(height: 60),

              // App logo/icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 50,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                l10n.appTitle,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                l10n.authChoiceSubtitle,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Primary CTA - Get Started
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _onGetStarted(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.getStarted,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

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
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                  const Expanded(
                    child: Divider(color: Colors.grey, thickness: 1),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Secondary CTA - I have an account
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/sign-in');
                  },
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
                    l10n.iHaveAnAccount,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
