import 'dart:io';
import '../models/device.dart';
import '../services/logging_service.dart';
import 'package:uuid/uuid.dart';

/// Error handler for device record operations with fallback mechanisms
class DeviceRecordErrorHandler {
  static const Uuid _uuid = Uuid();

  // Logger instance for this utility class
  static final _log = LoggingService.getLogger('DeviceRecordErrorHandler');

  /// Handle device info collection errors and provide fallback values
  static Device handleDeviceInfoError(
    dynamic error, {
    String? existingId,
    String? userId,
  }) {
    _log.e('Device info collection failed', error: error);
    return _createFallbackDeviceRecord(
      existingId: existingId,
      userId: userId,
      error: error,
    );
  }

  /// Handle preferences service errors
  static T handlePreferencesError<T>(
    dynamic error,
    T fallbackValue, {
    String? operation,
  }) {
    _log.e(
      'Preferences operation failed${operation != null ? ' ($operation)' : ''}',
      error: error,
    );
    return fallbackValue;
  }

  /// Handle device record service initialization errors
  static void handleInitializationError(dynamic error) {
    _log.e('Device record service initialization failed', error: error);
    // Log error for debugging but don't crash the app
    // In production, you might want to send this to a crash reporting service
  }

  /// Handle device record update errors
  static void handleUpdateError(dynamic error, String operation) {
    _log.e('Device record update failed ($operation)', error: error);
    // Log error but continue app execution
  }

  /// Create a comprehensive fallback device record
  static Device _createFallbackDeviceRecord({
    String? existingId,
    String? userId,
    dynamic error,
  }) {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    return Device(
      id: existingId ?? _uuid.v4(),
      platformType: _getFallbackPlatformType(),
      os: _getFallbackOS(),
      osVersion: _getFallbackOSVersion(),
      countryCode: 'US',
      countryName: 'United States',
      createdAt: existingId != null ? 0 : now,
      updatedAt: now,
      userId: userId ?? '',
      lastOpenedAt: now,
      appVersion: '1.0.0',
      appBuildNumber: '1',
      deviceManufacturer: _getFallbackManufacturer(),
      langCode: 'en',
      timezone: 'UTC',
      timezoneOffset: 0,
      fcmToken: '', // Will be updated by FirebaseService
    );
  }

  /// Get fallback platform type
  static String _getFallbackPlatformType() {
    try {
      if (Platform.isAndroid) return 'android';
      if (Platform.isIOS) return 'ios';
      return 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }

  /// Get fallback OS name
  static String _getFallbackOS() {
    try {
      return Platform.operatingSystem;
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Get fallback OS version
  static String _getFallbackOSVersion() {
    try {
      return Platform.operatingSystemVersion;
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Get fallback device manufacturer
  static String _getFallbackManufacturer() {
    try {
      if (Platform.isIOS) return 'Apple';
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Validate device record data and fix any issues
  static Device validateAndFixDeviceRecord(Device record) {
    return record.copyWith(
      id: record.id.isEmpty ? _uuid.v4() : record.id,
      platformType: record.platformType.isEmpty
          ? _getFallbackPlatformType()
          : record.platformType,
      os: record.os.isEmpty ? _getFallbackOS() : record.os,
      osVersion: record.osVersion.isEmpty
          ? _getFallbackOSVersion()
          : record.osVersion,
      countryCode: record.countryCode.isEmpty ? 'US' : record.countryCode,
      countryName: record.countryName.isEmpty
          ? 'United States'
          : record.countryName,
      appVersion: record.appVersion.isEmpty ? '1.0.0' : record.appVersion,
      appBuildNumber: record.appBuildNumber.isEmpty
          ? '1'
          : record.appBuildNumber,
      deviceManufacturer: record.deviceManufacturer.isEmpty
          ? _getFallbackManufacturer()
          : record.deviceManufacturer,
      langCode: record.langCode.isEmpty ? 'en' : record.langCode,
      timezone: record.timezone.isEmpty ? 'UTC' : record.timezone,
      createdAt: record.createdAt == 0
          ? DateTime.now().toUtc().millisecondsSinceEpoch
          : record.createdAt,
      updatedAt: record.updatedAt == 0
          ? DateTime.now().toUtc().millisecondsSinceEpoch
          : record.updatedAt,
      lastOpenedAt: record.lastOpenedAt == 0
          ? DateTime.now().toUtc().millisecondsSinceEpoch
          : record.lastOpenedAt,
    );
  }

  /// Check if device record has valid data
  static bool isValidDeviceRecord(Device? record) {
    if (record == null) return false;

    return record.id.isNotEmpty &&
        record.platformType.isNotEmpty &&
        record.os.isNotEmpty &&
        record.createdAt > 0 &&
        record.updatedAt > 0 &&
        record.lastOpenedAt > 0;
  }

  /// Get error-safe device record (never returns null)
  static Device getErrorSafeDeviceRecord(Device? record) {
    if (record == null || !isValidDeviceRecord(record)) {
      return _createFallbackDeviceRecord();
    }
    return validateAndFixDeviceRecord(record);
  }

  /// Handle JSON parsing errors
  static Device? handleJsonParsingError(dynamic error, String jsonString) {
    _log.e('Failed to parse device record JSON', error: error);
    _log.d('JSON string: $jsonString');
    return null;
  }

  /// Handle network-related errors (for future API integration)
  static void handleNetworkError(dynamic error, String operation) {
    _log.e('Network error during $operation', error: error);
    // In production, you might want to:
    // 1. Retry the operation
    // 2. Queue for later when network is available
    // 3. Send to error reporting service
  }

  /// Handle permission-related errors
  static void handlePermissionError(dynamic error, String permission) {
    _log.e('Permission error for $permission', error: error);
    // In production, you might want to:
    // 1. Show user-friendly message
    // 2. Provide alternative flow
    // 3. Log for analytics
  }

  /// Handle storage-related errors
  static void handleStorageError(dynamic error, String operation) {
    _log.e('Storage error during $operation', error: error);
    // In production, you might want to:
    // 1. Try alternative storage method
    // 2. Clear corrupted data
    // 3. Show user notification
  }

  /// Get error message for user display
  static String getUserFriendlyErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'Network connection error. Please check your internet connection.';
    } else if (error is FormatException) {
      return 'Data format error. Please try again.';
    } else if (error.toString().contains('permission')) {
      return 'Permission required. Please grant necessary permissions.';
    } else if (error.toString().contains('storage')) {
      return 'Storage error. Please check available storage space.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Log error for debugging (in production, send to crash reporting)
  static void logError(
    dynamic error,
    String context, {
    Map<String, dynamic>? additionalData,
  }) {
    _log.e('Error in $context', error: error);
    if (additionalData != null) {
      _log.d('Additional data: $additionalData');
    }

    // In production, you would send this to a crash reporting service like:
    // - Firebase Crashlytics
    // - Sentry
    // - Bugsnag
    // etc.
  }
}
