import '../models/device.dart';
import 'device_info_service.dart';
import 'preferences_service.dart';
import '../utils/device_record_error_handler.dart';
import 'firebase_service.dart';

class DeviceRecordService {
  static DeviceRecordService? _instance;
  static DeviceRecordService get instance {
    _instance ??= DeviceRecordService._();
    return _instance!;
  }

  DeviceRecordService._();

  PreferencesService? _preferencesService;
  Device? _currentDeviceRecord;
  bool _isInitialized = false;

  /// Get the current device record
  Device? get currentDeviceRecord => _currentDeviceRecord;

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the device record service
  /// This should be called when the app starts
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize dependencies
      _preferencesService = await PreferencesService.getInstance();
      await DeviceInfoService.instance.initialize();

      // Load or create device record
      await _loadOrCreateDeviceRecord();

      // Update last opened timestamp
      await updateLastOpenedAt();

      _isInitialized = true;
    } catch (e) {
      DeviceRecordErrorHandler.handleInitializationError(e);
      // Create a fallback device record to ensure app doesn't crash
      _currentDeviceRecord = DeviceRecordErrorHandler.handleDeviceInfoError(e);
      _isInitialized = true; // Mark as initialized to prevent retry loops
    }
  }

  /// Load existing device record or create a new one
  Future<void> _loadOrCreateDeviceRecord() async {
    try {
      // Try to load existing device record
      _currentDeviceRecord = _preferencesService!.getDeviceRecord();

      if (_currentDeviceRecord == null) {
        // No existing record, create a new one
        await _createNewDeviceRecord();
      } else {
        // Validate and fix any issues with existing record
        _currentDeviceRecord =
            DeviceRecordErrorHandler.validateAndFixDeviceRecord(
              _currentDeviceRecord!,
            );
        // Optionally update it with fresh info
        await _updateDeviceRecordInfo();
      }
    } catch (e) {
      DeviceRecordErrorHandler.logError(e, 'loadOrCreateDeviceRecord');
      // If loading fails, create a fallback record
      _currentDeviceRecord = DeviceRecordErrorHandler.handleDeviceInfoError(e);
      await _saveDeviceRecordSafely(_currentDeviceRecord!);
    }
  }

  /// Create a new device record
  Future<void> _createNewDeviceRecord() async {
    try {
      _currentDeviceRecord = await DeviceInfoService.instance
          .collectDeviceInfo();
      await _saveDeviceRecordSafely(_currentDeviceRecord!);
    } catch (e) {
      DeviceRecordErrorHandler.logError(e, 'createNewDeviceRecord');
      _currentDeviceRecord = DeviceRecordErrorHandler.handleDeviceInfoError(e);
      await _saveDeviceRecordSafely(_currentDeviceRecord!);
    }
  }

  /// Safely save device record with error handling
  Future<void> _saveDeviceRecordSafely(Device record) async {
    try {
      await _preferencesService!.setDeviceRecord(record);
    } catch (e) {
      DeviceRecordErrorHandler.handleStorageError(e, 'saveDeviceRecord');
      // Continue execution even if save fails
    }
  }

  /// Update device record with fresh information (preserving ID and timestamps)
  Future<void> _updateDeviceRecordInfo() async {
    if (_currentDeviceRecord == null) return;

    try {
      final updatedRecord = await DeviceInfoService.instance.updateDeviceRecord(
        _currentDeviceRecord!,
      );
      _currentDeviceRecord = updatedRecord;
      await _saveDeviceRecordSafely(_currentDeviceRecord!);
    } catch (e) {
      DeviceRecordErrorHandler.handleUpdateError(e, 'updateDeviceRecordInfo');
      // If update fails, keep the existing record
    }
  }

  /// Update the lastOpenedAt timestamp
  /// This should be called every time the app is opened
  Future<void> updateLastOpenedAt() async {
    if (_currentDeviceRecord == null) return;

    try {
      _currentDeviceRecord = _currentDeviceRecord!.updateLastOpenedAt();
      await _saveDeviceRecordSafely(_currentDeviceRecord!);
    } catch (e) {
      DeviceRecordErrorHandler.handleUpdateError(e, 'updateLastOpenedAt');
    }
  }

  /// Update the user ID when a user is created or logged in
  Future<void> updateUserId(String userId) async {
    if (_currentDeviceRecord == null) return;

    try {
      _currentDeviceRecord = _currentDeviceRecord!.updateUserId(userId);
      await _preferencesService!.setDeviceRecord(_currentDeviceRecord!);
    } catch (e) {
      throw Exception('Failed to update user ID: $e');
    }
  }

  /// Clear the user ID (when user logs out)
  Future<void> clearUserId() async {
    await updateUserId('');
  }

  /// Update the FCM token
  Future<void> updateFcmToken(String fcmToken) async {
    if (_currentDeviceRecord == null) return;

    try {
      _currentDeviceRecord = _currentDeviceRecord!.updateFcmToken(fcmToken);
      await _preferencesService!.setDeviceRecord(_currentDeviceRecord!);
    } catch (e) {
      throw Exception('Failed to update FCM token: $e');
    }
  }

  /// Fetch and store FCM token from Firebase (only if already available)
  Future<void> fetchAndStoreFcmToken() async {
    try {
      final fcmToken = await FirebaseService.instance.getCurrentToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        await updateFcmToken(fcmToken);
      }
    } catch (e) {
      // Don't throw error as FCM is not critical for app functionality
      DeviceRecordErrorHandler.logError(e, 'fetchAndStoreFcmToken');
    }
  }

  /// Request notification permission and fetch FCM token
  Future<bool> requestNotificationPermissionAndFetchToken() async {
    try {
      final permissionGranted = await FirebaseService.instance
          .requestNotificationPermission();
      if (permissionGranted) {
        final fcmToken = await FirebaseService.instance
            .getTokenWithPermission();
        if (fcmToken != null && fcmToken.isNotEmpty) {
          await updateFcmToken(fcmToken);
          return true;
        }
      }
      return false;
    } catch (e) {
      DeviceRecordErrorHandler.logError(
        e,
        'requestNotificationPermissionAndFetchToken',
      );
      return false;
    }
  }

  /// Get device record as JSON for API calls or debugging
  Map<String, dynamic>? getDeviceRecordJson() {
    return _currentDeviceRecord?.toJson();
  }

  /// Force refresh the device record with current device information
  Future<void> refreshDeviceRecord() async {
    try {
      if (_currentDeviceRecord != null) {
        await _updateDeviceRecordInfo();
      } else {
        await _createNewDeviceRecord();
      }
    } catch (e) {
      throw Exception('Failed to refresh device record: $e');
    }
  }

  /// Check if this is the first time the app is opened on this device
  bool isFirstTimeOpen() {
    return _currentDeviceRecord?.isNewDevice ?? false;
  }

  /// Check if the device has a user associated with it
  bool hasUser() {
    return _currentDeviceRecord?.hasUserId ?? false;
  }

  /// Get device ID
  String? getDeviceId() {
    return _currentDeviceRecord?.id;
  }

  /// Get platform type
  String? getPlatformType() {
    return _currentDeviceRecord?.platformType;
  }

  /// Get app version info
  String? getAppVersion() {
    final record = _currentDeviceRecord;
    if (record == null) return null;
    return '${record.appVersion}+${record.appBuildNumber}';
  }

  /// Clear all device record data (useful for testing or reset)
  Future<void> clearDeviceRecord() async {
    try {
      await _preferencesService?.clearDeviceRecord();
      _currentDeviceRecord = null;
      _isInitialized = false;
    } catch (e) {
      throw Exception('Failed to clear device record: $e');
    }
  }

  /// Get a summary of device information for debugging
  String getDeviceRecordSummary() {
    if (_currentDeviceRecord == null) {
      return 'No device record available';
    }
    return _currentDeviceRecord.toString();
  }

  /// Export device record for backup or migration
  Map<String, dynamic>? exportDeviceRecord() {
    return _currentDeviceRecord?.toJson();
  }

  /// Import device record from backup or migration
  Future<void> importDeviceRecord(Map<String, dynamic> deviceRecordJson) async {
    try {
      final deviceRecord = Device.fromJson(deviceRecordJson);
      _currentDeviceRecord = deviceRecord;
      await _preferencesService!.setDeviceRecord(_currentDeviceRecord!);
    } catch (e) {
      throw Exception('Failed to import device record: $e');
    }
  }

  /// Save device received from backend API response
  /// Used after successful anonymous auth API call
  Future<void> saveDeviceFromResponse(Device device) async {
    try {
      _currentDeviceRecord = device;
      await _preferencesService!.setDeviceRecord(_currentDeviceRecord!);
    } catch (e) {
      throw Exception('Failed to save device from API response: $e');
    }
  }
}
