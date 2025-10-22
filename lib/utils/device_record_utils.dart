import '../services/device_record_service.dart';
import '../models/device.dart';
import '../services/logging_service.dart';

/// Utility class for common device record operations
class DeviceRecordUtils {
  /// Private constructor to prevent instantiation
  DeviceRecordUtils._();

  // Logger instance for this utility class
  static final _log = LoggingService.getLogger('DeviceRecordUtils');

  /// Get the current device record
  static Device? getCurrentDeviceRecord() {
    return DeviceRecordService.instance.currentDeviceRecord;
  }

  /// Update user ID when user signs up or logs in
  static Future<void> setUserId(String userId) async {
    _log.entering('setUserId', {'userId': userId});

    try {
      await DeviceRecordService.instance.updateUserId(userId);
      _log.i('User ID updated successfully');
    } catch (e) {
      _log.e('Failed to update user ID in device record', error: e);
      rethrow;
    }

    _log.exiting('setUserId');
  }

  /// Clear user ID when user logs out
  static Future<void> clearUserId() async {
    _log.entering('clearUserId');

    try {
      await DeviceRecordService.instance.clearUserId();
      _log.i('User ID cleared successfully');
    } catch (e) {
      _log.e('Failed to clear user ID from device record', error: e);
      rethrow;
    }

    _log.exiting('clearUserId');
  }

  /// Update last opened timestamp (called on app launch)
  static Future<void> updateLastOpened() async {
    _log.entering('updateLastOpened');

    try {
      await DeviceRecordService.instance.updateLastOpenedAt();
      _log.d('Last opened timestamp updated successfully');
    } catch (e) {
      _log.w('Failed to update last opened timestamp', error: e);
      // Don't rethrow as this is not critical
    }

    _log.exiting('updateLastOpened');
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
    _log.entering('refreshDeviceRecord');

    try {
      await DeviceRecordService.instance.refreshDeviceRecord();
      _log.i('Device record refreshed successfully');
    } catch (e) {
      _log.e('Failed to refresh device record', error: e);
      rethrow;
    }

    _log.exiting('refreshDeviceRecord');
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
    _log.entering('importDeviceRecord');

    try {
      await DeviceRecordService.instance.importDeviceRecord(deviceRecordJson);
      _log.i('Device record imported successfully');
    } catch (e) {
      _log.e('Failed to import device record', error: e);
      rethrow;
    }

    _log.exiting('importDeviceRecord');
  }

  /// Clear device record (for testing or reset)
  static Future<void> clearDeviceRecord() async {
    _log.entering('clearDeviceRecord');

    try {
      await DeviceRecordService.instance.clearDeviceRecord();
      _log.i('Device record cleared successfully');
    } catch (e) {
      _log.e('Failed to clear device record', error: e);
      rethrow;
    }

    _log.exiting('clearDeviceRecord');
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
