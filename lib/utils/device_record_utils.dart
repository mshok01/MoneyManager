import '../services/device_record_service.dart';
import '../models/device.dart';

/// Utility class for common device record operations
class DeviceRecordUtils {
  /// Private constructor to prevent instantiation
  DeviceRecordUtils._();

  /// Get the current device record
  static Device? getCurrentDeviceRecord() {
    return DeviceRecordService.instance.currentDeviceRecord;
  }

  /// Update user ID when user signs up or logs in
  static Future<void> setUserId(String userId) async {
    try {
      await DeviceRecordService.instance.updateUserId(userId);
    } catch (e) {
      print('Failed to update user ID in device record: $e');
      rethrow;
    }
  }

  /// Clear user ID when user logs out
  static Future<void> clearUserId() async {
    try {
      await DeviceRecordService.instance.clearUserId();
    } catch (e) {
      print('Failed to clear user ID from device record: $e');
      rethrow;
    }
  }

  /// Update last opened timestamp (called on app launch)
  static Future<void> updateLastOpened() async {
    try {
      await DeviceRecordService.instance.updateLastOpenedAt();
    } catch (e) {
      print('Failed to update last opened timestamp: $e');
      // Don't rethrow as this is not critical
    }
  }

  /// Check if this is the first time the app is opened
  static bool isFirstTimeUser() {
    return DeviceRecordService.instance.isFirstTimeOpen();
  }

  /// Check if device has a user associated
  static bool hasUser() {
    return DeviceRecordService.instance.hasUser();
  }

  /// Get device ID for analytics or API calls
  static String? getDeviceId() {
    return DeviceRecordService.instance.getDeviceId();
  }

  /// Get platform type (android/ios)
  static String? getPlatformType() {
    return DeviceRecordService.instance.getPlatformType();
  }

  /// Get app version string
  static String? getAppVersion() {
    return DeviceRecordService.instance.getAppVersion();
  }

  /// Get device record as JSON for API calls
  static Map<String, dynamic>? getDeviceRecordJson() {
    return DeviceRecordService.instance.getDeviceRecordJson();
  }

  /// Refresh device record with current information
  static Future<void> refreshDeviceRecord() async {
    try {
      await DeviceRecordService.instance.refreshDeviceRecord();
    } catch (e) {
      print('Failed to refresh device record: $e');
      rethrow;
    }
  }

  /// Get device record summary for debugging
  static String getDeviceRecordSummary() {
    return DeviceRecordService.instance.getDeviceRecordSummary();
  }

  /// Export device record for backup
  static Map<String, dynamic>? exportDeviceRecord() {
    return DeviceRecordService.instance.exportDeviceRecord();
  }

  /// Import device record from backup
  static Future<void> importDeviceRecord(
    Map<String, dynamic> deviceRecordJson,
  ) async {
    try {
      await DeviceRecordService.instance.importDeviceRecord(deviceRecordJson);
    } catch (e) {
      print('Failed to import device record: $e');
      rethrow;
    }
  }

  /// Clear device record (for testing or reset)
  static Future<void> clearDeviceRecord() async {
    try {
      await DeviceRecordService.instance.clearDeviceRecord();
    } catch (e) {
      print('Failed to clear device record: $e');
      rethrow;
    }
  }

  /// Get specific device information
  static String? getDeviceManufacturer() {
    return getCurrentDeviceRecord()?.deviceManufacturer;
  }

  static String? getOSVersion() {
    return getCurrentDeviceRecord()?.osVersion;
  }

  static String? getCountryCode() {
    return getCurrentDeviceRecord()?.countryCode;
  }

  static String? getCountryName() {
    return getCurrentDeviceRecord()?.countryName;
  }

  static String? getLanguageCode() {
    return getCurrentDeviceRecord()?.langCode;
  }

  static String? getTimezone() {
    return getCurrentDeviceRecord()?.timezone;
  }

  static int? getTimezoneOffset() {
    return getCurrentDeviceRecord()?.timezoneOffset;
  }

  /// Get timestamps
  static DateTime? getCreatedAt() {
    final createdAt = getCurrentDeviceRecord()?.createdAt;
    if (createdAt == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(createdAt, isUtc: true);
  }

  static DateTime? getUpdatedAt() {
    final updatedAt = getCurrentDeviceRecord()?.updatedAt;
    if (updatedAt == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(updatedAt, isUtc: true);
  }

  static DateTime? getLastOpenedAt() {
    final lastOpenedAt = getCurrentDeviceRecord()?.lastOpenedAt;
    if (lastOpenedAt == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(lastOpenedAt, isUtc: true);
  }

  /// Helper method to format device info for display
  static String getFormattedDeviceInfo() {
    final record = getCurrentDeviceRecord();
    if (record == null) return 'Device information not available';

    return '''
Device ID: ${record.id}
Platform: ${record.platformType}
OS: ${record.os} ${record.osVersion}
Manufacturer: ${record.deviceManufacturer}
App Version: ${record.appVersion}+${record.appBuildNumber}
Country: ${record.countryName} (${record.countryCode})
Language: ${record.langCode}
Timezone: ${record.timezone} (${record.timezoneOffset} min)
User ID: ${record.userId.isEmpty ? 'Not set' : record.userId}
Created: ${getCreatedAt()?.toLocal()}
Last Opened: ${getLastOpenedAt()?.toLocal()}
''';
  }
}
