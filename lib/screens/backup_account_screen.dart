import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/preferences_service.dart';
import '../services/firebase_auth_linking_service.dart';
import '../services/logging_service.dart';

class BackupAccountScreen extends StatelessWidget {
  /// If true, this screen is opened from settings (show back button, hide skip)
  /// If false, this screen is part of onboarding flow (show skip, hide back button)
  final bool isFromSettings;

  const BackupAccountScreen({super.key, this.isFromSettings = false});

  /// Complete onboarding and navigate to home
  Future<void> _completeOnboarding(BuildContext context) async {
    try {
      final prefsService = await PreferencesService.getInstance();
      await prefsService.setOnboardingComplete(true);

      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      // If there's an error, still navigate to home but log the error
      LoggingService.getLogger(
        'BackupAccountScreen',
      ).e('Error completing onboarding: $e');
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    }
  }

  void _onGoogleSignIn(BuildContext context) async {
    final log = LoggingService.getLogger('BackupAccountScreen');
    log.d('Google sign-in initiated');

    // Show loading dialog
    if (!context.mounted) return;
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
                Text(AppLocalizations.of(context)!.linkingAccount),
              ],
            ),
          ),
        );
      },
    );

    try {
      final linkingService = FirebaseAuthLinkingService.instance;

      // Try to link new Google account (Scenario 1)
      try {
        await linkingService.linkNewGoogleAccount();
        log.d('New Google account linked successfully');

        if (!context.mounted) return;
        Navigator.of(context).pop(); // Close loading dialog

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.accountLinkedSuccessfully,
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        // Complete onboarding and navigate to home
        _completeOnboarding(context);
      } on GoogleAccountAlreadyExistsException catch (e) {
        log.d('Google account already exists: ${e.googleEmail}');

        if (!context.mounted) return;
        Navigator.of(context).pop(); // Close loading dialog

        // Check if this is a specific error that should show the restore dialog
        if (_isAccountExistsError(e.errorCode)) {
          // Show dialog asking user to restore data
          _showAccountExistsDialog(context, e);
        } else {
          // Show generic failed dialog for other errors
          _showFailedToAddRecoveryAccountDialog(context);
        }
      }
    } catch (e) {
      log.e('Google sign-in failed: $e');

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.linkingFailed}: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Show dialog when Google account already has data
  void _showAccountExistsDialog(
    BuildContext context,
    GoogleAccountAlreadyExistsException exception,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.accountAlreadyExists),
          content: Text(l10n.accountAlreadyExistsMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // User chose to proceed without restore
                _completeOnboarding(context);
              },
              child: Text(l10n.proceedWithoutRestore),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // User chose to restore data
                _restoreDataWithGoogleAccount(context, exception);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
              ),
              child: Text(l10n.restoreData),
            ),
          ],
        );
      },
    );
  }

  /// Restore data by logging out current account and logging in with Google account
  Future<void> _restoreDataWithGoogleAccount(
    BuildContext context,
    GoogleAccountAlreadyExistsException exception,
  ) async {
    final log = LoggingService.getLogger('BackupAccountScreen');
    log.d('User chose to restore data with Google account');

    // Show loading dialog
    if (!context.mounted) return;
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
                Text(AppLocalizations.of(context)!.linkingAccount),
              ],
            ),
          ),
        );
      },
    );

    try {
      final linkingService = FirebaseAuthLinkingService.instance;

      // Link existing Google account (Scenario 2)
      await linkingService.linkExistingGoogleAccount();
      log.d('Existing Google account linked successfully');

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.accountLinkedSuccessfully,
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Complete onboarding and navigate to home
      _completeOnboarding(context);
    } catch (e) {
      log.e('Failed to restore data with Google account', error: e);

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.linkingFailed}: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Check if the error code indicates an account already exists scenario
  bool _isAccountExistsError(String? errorCode) {
    return errorCode == 'credential-already-in-use' ||
        errorCode == 'email-already-in-use';
  }

  /// Show dialog when adding recovery account fails
  void _showFailedToAddRecoveryAccountDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.failedToAddRecoveryAccount),
          content: Text(l10n.failedToAddRecoveryAccountMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // User chose to skip recovery account
                _completeOnboarding(context);
              },
              child: Text(AppLocalizations.of(context)!.skip),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // User chose to try again
                _onGoogleSignIn(context);
              },
              child: Text(l10n.tryAgain),
            ),
          ],
        );
      },
    );
  }

  void _onAppleSignIn(BuildContext context) {
    // TODO: Implement Apple Sign-in
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.appleSignInComingSoon),
        duration: const Duration(seconds: 2),
      ),
    );
    // Complete onboarding and navigate to home
    _completeOnboarding(context);
  }

  void _onSkip(BuildContext context) {
    // Complete onboarding and navigate to home without backup account
    _completeOnboarding(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: isFromSettings
          ? AppBar(
              title: Text(l10n.backup),
              backgroundColor: theme.colorScheme.inversePrimary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Top spacing
                SizedBox(height: isFromSettings ? 24 : 40),

                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cloud_upload_outlined,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  l10n.secureYourData,
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
                  l10n.backupAccountDescription,
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

                const SizedBox(height: 16),

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

                const SizedBox(height: 32),

                // Divider with "or" - only show in onboarding flow
                if (!isFromSettings)
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

                if (!isFromSettings) const SizedBox(height: 32),

                // Skip button - only show in onboarding flow
                if (!isFromSettings)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: TextButton(
                      onPressed: () => _onSkip(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.skipForNow,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                if (!isFromSettings) const SizedBox(height: 16),

                // Helper text - only show in onboarding flow
                if (!isFromSettings)
                  Text(
                    l10n.addBackupLaterInSettings,
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
