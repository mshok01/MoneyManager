import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../services/firebase_auth_service.dart';
import '../services/auth_api_service.dart';
import '../services/user_api_service.dart';
import '../services/user_service.dart';
import '../services/transaction_service.dart';
import '../services/device_record_service.dart';
import '../services/account_service.dart';
import '../services/category_service.dart';
import '../services/payment_source_service.dart';
import '../services/sync_service.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../providers/user_details_provider.dart';
import 'backup_account_screen.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  static void _navigateToBackupAccount(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BackupAccountScreen(isFromSettings: true),
      ),
    );
  }

  static Future<void> _showEditNameDialog(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _EditNameDialog(
        currentName: currentName,
        onSave: (newName) async {
          if (newName.isNotEmpty && newName != currentName) {
            // Close dialog immediately (don't wait for API)
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }

            try {
              // Update user name (offline-first pattern)
              // This happens in background without blocking UI
              await ref.read(
                updateUserProvider((
                  email: null,
                  name: newName,
                  profilePic: null,
                  isActive: null,
                  currencyCode: null,
                  currencyName: null,
                )).future,
              );

              // Show success message only if context is still mounted
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.nameUpdatedSuccessfully),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              // Show error message but don't block UI
              // The update is saved locally, will retry on app reopen
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.failedToUpdateName),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          } else {
            Navigator.of(dialogContext).pop();
          }
        },
      ),
    );
  }

  static Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                const Text('Logging out...'),
              ],
            ),
          ),
        );

        // Get current Firebase UID
        final firebaseAuthService = FirebaseAuthService.instance;
        final currentUser = firebaseAuthService.getCurrentUser();

        if (currentUser != null) {
          // Call remove user API
          try {
            final authApiService = AuthApiService.instance;
            await authApiService.removeUser(firebaseUID: currentUser.uid);
          } catch (apiError) {
            // Continue with logout even if API call fails
            debugPrint('Failed to remove user from API: $apiError');
          }
        }

        // Clear all user data from services
        try {
          // 1. Clear user details in memory and in sqlite
          await UserService.instance.clearUserData();

          // 2. Clear all user transactions
          await TransactionService.instance.clearAllTransactions();

          // 3. Clear device details in state and in sqlite (but preserve FCM token)
          await DeviceRecordService.instance.clearDeviceRecordButKeepFcmToken();

          // 4. Clear user accounts in state and sqlite
          await AccountService.instance.clearAccountData();

          // 5. Clear user related categories (but not default ones)
          await CategoryService.instance.clearCustomCategories();

          // 6. Clear user related payment sources (but not default ones)
          await PaymentSourceService.instance.clearCustomPaymentSources();

          // 7. Clear sync queue
          await SyncService.instance.clearAll();

          // 8. Clear data service cache
          DataService.instance.clearCache();

          // 9. Invalidate all relevant providers to refresh UI
          ref.invalidate(currentUserProvider);
        } catch (e) {
          debugPrint('Error clearing user data: $e');
          // Continue with sign out even if clearing data fails
        }

        // Sign out from Firebase
        await firebaseAuthService.signOut();

        if (context.mounted) {
          // Close loading dialog
          Navigator.of(context).pop();

          // Navigate to intro screen
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/intro', (route) => false);
        }
      } catch (e) {
        if (context.mounted) {
          // Close loading dialog if still open
          try {
            Navigator.of(context).pop();
          } catch (_) {
            // Dialog might not be open
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.signOutFailed}: $e'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  static Future<void> _deleteAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    // First confirmation dialog
    final firstConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.deleteAccountWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (firstConfirmed != true) return;

    // Second confirmation dialog (extra safety)
    if (context.mounted) {
      final secondConfirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.deleteAccountConfirm),
          content: Text(l10n.deleteAccountConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.deleteAccountPermanently),
            ),
          ],
        ),
      );

      if (secondConfirmed != true) return;
    }

    if (context.mounted) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text(l10n.deletingAccount),
            ],
          ),
        ),
      );
    }

    try {
      // Get current Firebase UID and user ID
      final firebaseAuthService = FirebaseAuthService.instance;
      final currentFirebaseUser = firebaseAuthService.getCurrentUser();
      final userService = UserService.instance;
      final userId = userService.getUserId();

      if (userId == null) {
        throw Exception('User ID not found');
      }

      // Step 1: Call backend deleteUser API
      try {
        final userApiService = UserApiService.instance;
        await userApiService.deleteUser(userId: userId);
      } catch (apiError) {
        // If API call fails, show error and don't proceed with local deletion
        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.deleteAccountFailed}: $apiError'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        rethrow;
      }

      // Step 2: Clear all user data from local storage (only if API call succeeded)
      try {
        // 1. Clear user details in memory and in sqlite
        await UserService.instance.clearUserData();

        // 2. Clear all user transactions
        await TransactionService.instance.clearAllTransactions();

        // 3. Clear device details in state and in sqlite (but preserve FCM token)
        await DeviceRecordService.instance.clearDeviceRecordButKeepFcmToken();

        // 4. Clear user accounts in state and sqlite
        await AccountService.instance.clearAccountData();

        // 5. Clear user related categories (but not default ones)
        await CategoryService.instance.clearCustomCategories();

        // 6. Clear user related payment sources (but not default ones)
        await PaymentSourceService.instance.clearCustomPaymentSources();

        // 7. Clear sync queue
        await SyncService.instance.clearAll();

        // 8. Clear data service cache
        DataService.instance.clearCache();

        // 9. Invalidate all relevant providers to refresh UI
        ref.invalidate(currentUserProvider);
      } catch (e) {
        debugPrint('Error clearing user data: $e');
        // Continue with deletion even if clearing data fails
      }

      // Step 3: Delete from Firebase
      if (currentFirebaseUser != null) {
        try {
          await firebaseAuthService.deleteCurrentUser();
        } catch (firebaseError) {
          debugPrint('Failed to delete Firebase user: $firebaseError');
          // Continue even if Firebase deletion fails
        }
      }

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        // Navigate to intro screen
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/intro', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.deleteAccountFailed}: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final hasBackupAccount =
        currentUser != null && currentUser.email.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.userProfile), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Name Title
              Text(
                l10n.yourName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),

              // Name with Edit Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      currentUser?.name ?? 'User',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: l10n.editName,
                    onPressed: () => _showEditNameDialog(
                      context,
                      ref,
                      currentUser?.name ?? '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // Email (if exists)
              if (hasBackupAccount)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.email,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentUser.email,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(height: AppTheme.spacingMd),

              const SizedBox(height: AppTheme.spacingLg),

              // Backup Account Section
              if (!hasBackupAccount)
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            color: Colors.orange.shade700,
                            size: 24,
                          ),
                          const SizedBox(width: AppTheme.spacingMd),
                          Expanded(
                            child: Text(
                              l10n.addBackupAccount,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      Text(
                        l10n.backupAccountDescription,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _navigateToBackupAccount(context),
                          icon: const Icon(Icons.cloud_upload),
                          label: Text(l10n.addBackupAccount),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacingMd,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.backupAccountConnected,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.yourDataIsSecure,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AppTheme.spacingLg),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _logout(context, ref),
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.logout),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingMd,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _deleteAccount(context, ref),
                  icon: const Icon(Icons.delete_forever),
                  label: Text(l10n.deleteAccount),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingMd,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  final String currentName;
  final Future<void> Function(String newName) onSave;

  const _EditNameDialog({required this.currentName, required this.onSave});

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.editName),
      content: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          hintText: l10n.enterName,
          border: const OutlineInputBorder(),
        ),
        maxLines: 1,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () async {
            final newName = _nameController.text.trim();
            await widget.onSave(newName);
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
