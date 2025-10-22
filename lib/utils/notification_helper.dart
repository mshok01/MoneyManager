import 'package:flutter/material.dart';
import '../services/device_record_service.dart';

/// Helper class for managing notification permissions and setup
class NotificationHelper {
  /// Show a dialog asking user if they want to enable notifications
  static Future<bool> showNotificationPermissionDialog(
    BuildContext context, {
    String title = 'Enable Notifications',
    String message = 'Would you like to receive notifications for reminders and account updates?',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Not Now'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Enable'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      return await requestNotificationPermission(context);
    }

    return false;
  }

  /// Request notification permission and handle the result
  static Future<bool> requestNotificationPermission(BuildContext context) async {
    try {
      final success = await DeviceRecordService.instance
          .requestNotificationPermissionAndFetchToken();

      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notifications enabled successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return true;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification permission was denied.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to enable notifications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  /// Check if notifications are currently enabled
  static bool areNotificationsEnabled() {
    final deviceRecord = DeviceRecordService.instance.currentDeviceRecord;
    return deviceRecord?.fcmToken.isNotEmpty ?? false;
  }

  /// Show notification settings in app settings
  static Widget buildNotificationSettingTile({
    required VoidCallback onTap,
    bool enabled = false,
  }) {
    return ListTile(
      leading: Icon(
        enabled ? Icons.notifications_active : Icons.notifications_off,
        color: enabled ? Colors.green : Colors.grey,
      ),
      title: const Text('Notifications'),
      subtitle: Text(
        enabled 
          ? 'Enabled - You\'ll receive reminders and updates'
          : 'Disabled - Tap to enable notifications',
      ),
      trailing: enabled 
        ? const Icon(Icons.check_circle, color: Colors.green)
        : const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
