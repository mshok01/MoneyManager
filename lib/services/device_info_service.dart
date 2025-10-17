import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:uuid/uuid.dart';
import '../models/device.dart';
import 'logging_service.dart';

class DeviceInfoService {
  static DeviceInfoService? _instance;
  static DeviceInfoService get instance {
    _instance ??= DeviceInfoService._();
    return _instance!;
  }

  DeviceInfoService._();

  // Logger instance for this service
  static final _log = LoggingService.getLogger('DeviceInfoService');

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Uuid _uuid = const Uuid();

  /// Initialize timezone data
  Future<void> initialize() async {
    _log.entering('initialize');

    try {
      tz.initializeTimeZones();
      _log.d('Timezone data initialized successfully');
    } catch (e) {
      // Timezone initialization failed, continue with fallback values
      _log.w('Failed to initialize timezone data, using fallbacks', error: e);
    }

    _log.exiting('initialize');
  }

  /// Collect comprehensive device information and create a Device
  Future<Device> collectDeviceInfo({String? existingId, String? userId}) async {
    try {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;

      // Get package info for app version details
      final packageInfo = await PackageInfo.fromPlatform();

      // Get platform-specific device info
      final platformInfo = await _getPlatformSpecificInfo();

      // Get locale and timezone info
      final localeInfo = _getLocaleInfo();
      final timezoneInfo = _getTimezoneInfo();

      return Device(
        id: existingId ?? _uuid.v4(),
        platformType: _getPlatformType(),
        os: platformInfo['os'] ?? 'Unknown',
        osVersion: platformInfo['osVersion'] ?? 'Unknown',
        countryCode: localeInfo['countryCode'] ?? 'US',
        countryName: localeInfo['countryName'] ?? 'United States',
        createdAt: existingId != null
            ? 0
            : now, // Keep original createdAt if updating
        updatedAt: now,
        userId: userId ?? '',
        lastOpenedAt: now,
        appVersion: packageInfo.version,
        appBuildNumber: packageInfo.buildNumber,
        deviceManufacturer: platformInfo['manufacturer'] ?? 'Unknown',
        langCode: localeInfo['langCode'] ?? 'en',
        timezone: timezoneInfo['timezone'] ?? 'UTC',
        timezoneOffset: timezoneInfo['timezoneOffset'] ?? 0,
        fcmToken: '', // Will be updated by FirebaseService
      );
    } catch (e) {
      // Return a basic device record with fallback values if collection fails
      return _createFallbackDeviceRecord(
        existingId: existingId,
        userId: userId,
      );
    }
  }

  /// Get platform type (android/ios)
  String _getPlatformType() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  /// Get platform-specific device information
  Future<Map<String, String>> _getPlatformSpecificInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'os': 'Android',
          'osVersion':
              'Android ${androidInfo.version.release} (API ${androidInfo.version.sdkInt})',
          'manufacturer': androidInfo.manufacturer,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'os': 'iOS',
          'osVersion': '${iosInfo.systemName} ${iosInfo.systemVersion}',
          'manufacturer': 'Apple',
        };
      }
    } catch (e) {
      _log.w('Failed to get platform-specific info, using fallbacks', error: e);
    }

    return {
      'os': Platform.operatingSystem,
      'osVersion': Platform.operatingSystemVersion,
      'manufacturer': 'Unknown',
    };
  }

  /// Get locale information
  Map<String, String> _getLocaleInfo() {
    try {
      final locale = Platform.localeName; // e.g., 'en_US'
      final parts = locale.split('_');
      final langCode = parts.isNotEmpty ? parts[0] : 'en';
      final countryCode = parts.length > 1 ? parts[1] : 'US';

      return {
        'langCode': langCode,
        'countryCode': countryCode,
        'countryName': _getCountryName(countryCode),
      };
    } catch (e) {
      _log.w('Failed to get locale info, using fallbacks', error: e);
      return {
        'langCode': 'en',
        'countryCode': 'US',
        'countryName': 'United States',
      };
    }
  }

  /// Get timezone information
  Map<String, dynamic> _getTimezoneInfo() {
    try {
      final now = DateTime.now();
      final timezoneName = now.timeZoneName;
      final timezoneOffset = now.timeZoneOffset.inMinutes;

      return {'timezone': timezoneName, 'timezoneOffset': timezoneOffset};
    } catch (e) {
      _log.w('Failed to get timezone info, using fallbacks', error: e);
      return {'timezone': 'UTC', 'timezoneOffset': 0};
    }
  }

  /// Get country name from country code
  String _getCountryName(String countryCode) {
    final countryNames = {
      'US': 'United States',
      'CA': 'Canada',
      'GB': 'United Kingdom',
      'AU': 'Australia',
      'DE': 'Germany',
      'FR': 'France',
      'IT': 'Italy',
      'ES': 'Spain',
      'JP': 'Japan',
      'KR': 'South Korea',
      'CN': 'China',
      'IN': 'India',
      'BR': 'Brazil',
      'MX': 'Mexico',
      'RU': 'Russia',
      'NL': 'Netherlands',
      'SE': 'Sweden',
      'NO': 'Norway',
      'DK': 'Denmark',
      'FI': 'Finland',
    };

    return countryNames[countryCode] ?? countryCode;
  }

  /// Create a fallback device record when device info collection fails
  Device _createFallbackDeviceRecord({String? existingId, String? userId}) {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    return Device(
      id: existingId ?? _uuid.v4(),
      platformType: _getPlatformType(),
      os: Platform.operatingSystem,
      osVersion: Platform.operatingSystemVersion,
      countryCode: 'US',
      countryName: 'United States',
      createdAt: existingId != null ? 0 : now,
      updatedAt: now,
      userId: userId ?? '',
      lastOpenedAt: now,
      appVersion: '1.0.0',
      appBuildNumber: '1',
      deviceManufacturer: 'Unknown',
      langCode: 'en',
      timezone: 'UTC',
      timezoneOffset: 0,
      fcmToken: '', // Will be updated by FirebaseService
    );
  }

  /// Update an existing device record with fresh information
  Future<Device> updateDeviceRecord(Device existingRecord) async {
    final updatedRecord = await collectDeviceInfo(
      existingId: existingRecord.id,
      userId: existingRecord.userId,
    );

    // Preserve the original createdAt timestamp
    return updatedRecord.copyWith(createdAt: existingRecord.createdAt);
  }
}
