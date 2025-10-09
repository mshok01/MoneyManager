import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  void _onGoogleSignIn(BuildContext context) {
    // TODO: Implement Google Sign-in with account detection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sign-in will be implemented with Firebase Auth'),
        duration: Duration(seconds: 2),
      ),
    );
    // For now, navigate to home
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  void _onAppleSignIn(BuildContext context) {
    // TODO: Implement Apple Sign-in with account detection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Apple Sign-in will be implemented with Firebase Auth'),
        duration: Duration(seconds: 2),
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
