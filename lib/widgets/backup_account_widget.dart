import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/user_service.dart';

class BackupAccountWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const BackupAccountWidget({super.key, this.onTap});

  /// Determine if user has a backup account (email is not empty)
  bool _hasBackupAccount() {
    final currentUser = UserService.instance.currentUser;
    return currentUser != null && currentUser.email.isNotEmpty;
  }

  /// Get the backup provider icon based on email domain
  /// For now, we'll use a generic cloud icon, but this can be extended
  /// to detect Google, Apple, or other providers
  IconData _getProviderIcon() {
    final currentUser = UserService.instance.currentUser;
    if (currentUser == null) return Icons.cloud;

    final email = currentUser.email.toLowerCase();
    if (email.contains('gmail.com') || email.contains('google.com')) {
      return Icons.g_mobiledata;
    } else if (email.contains('icloud.com') || email.contains('apple.com')) {
      return Icons.apple;
    }
    return Icons.cloud;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasBackup = _hasBackupAccount();

    if (hasBackup) {
      // Show connected backup account with email and provider icon
      final currentUser = UserService.instance.currentUser;
      final email = currentUser?.email ?? '';
      final providerIcon = _getProviderIcon();

      return ListTile(
        leading: const Icon(Icons.backup),
        title: Text(l10n.backup),
        subtitle: Row(
          children: [
            Icon(providerIcon, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                email,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(l10n.connected, style: const TextStyle(fontSize: 12)),
          backgroundColor: Colors.green.withValues(alpha: 0.2),
          labelStyle: TextStyle(color: Colors.green.shade700),
        ),
        onTap: onTap,
      );
    } else {
      // Show not connected state with entire tile clickable
      return ListTile(
        leading: const Icon(Icons.backup),
        title: Text(l10n.backup),
        subtitle: Text(l10n.notConnected),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      );
    }
  }
}
