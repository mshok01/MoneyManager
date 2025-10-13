# Device Record Management

The Device Record Management system automatically collects and stores device information when the app is first opened, and updates it on subsequent launches. This system is essential for analytics, user support, and app functionality.

## Overview

The system consists of several components:

- **Device Model**: Data structure for device information
- **DeviceInfoService**: Collects device information using platform APIs
- **DeviceRecordService**: Orchestrates device record lifecycle
- **PreferencesService**: Handles persistent storage
- **DeviceRecordUtils**: Utility functions for common operations
- **DeviceRecordErrorHandler**: Error handling and fallback mechanisms

## Device Record Fields

The `Device` model contains the following fields:

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | String | Unique device identifier (UUID) | `"550e8400-e29b-41d4-a716-446655440000"` |
| `platformType` | String | Platform type | `"android"` or `"ios"` |
| `os` | String | Operating system name | `"Android"` or `"iOS"` |
| `osVersion` | String | OS version details | `"Android 13 (API 33)"` |
| `countryCode` | String | Country code | `"US"` |
| `countryName` | String | Country name | `"United States"` |
| `createdAt` | int | Creation timestamp (UTC milliseconds) | `1640995200000` |
| `updatedAt` | int | Last update timestamp (UTC milliseconds) | `1640995200000` |
| `userId` | String | Associated user ID (initially empty) | `"user_123"` |
| `lastOpenedAt` | int | Last app open timestamp (UTC milliseconds) | `1640995200000` |
| `appVersion` | String | App version | `"1.0.0"` |
| `appBuildNumber` | String | App build number | `"1"` |
| `deviceManufacturer` | String | Device manufacturer | `"Google"` |
| `langCode` | String | Language code | `"en"` |
| `timezone` | String | Device timezone | `"America/New_York"` |
| `timezoneOffset` | int | Timezone offset in minutes | `-300` |

## Initialization

The device record system is automatically initialized in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.instance.initialize();
  await DataService.instance.initialize();
  await DeviceRecordService.instance.initialize(); // Device record initialization
  runApp(const MoneyManagerApp());
}
```

### What happens during initialization:

1. **Dependencies Setup**: Initializes PreferencesService and DeviceInfoService
2. **Load Existing Record**: Attempts to load existing device record from SharedPreferences
3. **Create New Record**: If no record exists, collects device info and creates new record
4. **Update Timestamps**: Updates `lastOpenedAt` timestamp
5. **Error Handling**: Falls back to safe defaults if any step fails

## Usage Examples

### Basic Operations

```dart
import 'package:money_manager/utils/device_record_utils.dart';

// Get current device record
Device? record = DeviceRecordUtils.getCurrentDeviceRecord();

// Check if this is first time user
bool isFirstTime = DeviceRecordUtils.isFirstTimeUser();

// Get device ID for analytics
String? deviceId = DeviceRecordUtils.getDeviceId();

// Get platform type
String? platform = DeviceRecordUtils.getPlatformType(); // "android" or "ios"
```

### User Management

```dart
// When user signs up or logs in
await DeviceRecordUtils.setUserId('user_123');

// When user logs out
await DeviceRecordUtils.clearUserId();

// Check if device has associated user
bool hasUser = DeviceRecordUtils.hasUser();
```

### Device Information

```dart
// Get specific device information
String? manufacturer = DeviceRecordUtils.getDeviceManufacturer();
String? osVersion = DeviceRecordUtils.getOSVersion();
String? countryCode = DeviceRecordUtils.getCountryCode();
String? languageCode = DeviceRecordUtils.getLanguageCode();

// Get formatted device info for display
String deviceInfo = DeviceRecordUtils.getFormattedDeviceInfo();
print(deviceInfo);
```

### Advanced Operations

```dart
// Refresh device record with current information
await DeviceRecordUtils.refreshDeviceRecord();

// Export device record for backup
Map<String, dynamic>? exportData = DeviceRecordUtils.exportDeviceRecord();

// Import device record from backup
await DeviceRecordUtils.importDeviceRecord(exportData);

// Get device record as JSON for API calls
Map<String, dynamic>? jsonData = DeviceRecordUtils.getDeviceRecordJson();
```

## Direct Service Usage

For advanced use cases, you can use the services directly:

### DeviceRecordService

```dart
import 'package:money_manager/services/device_record_service.dart';

final service = DeviceRecordService.instance;

// Check if service is initialized
bool isReady = service.isInitialized;

// Get current device record
Device? record = service.currentDeviceRecord;

// Update user ID
await service.updateUserId('new_user_456');

// Update last opened timestamp
await service.updateLastOpenedAt();

// Get device record summary for debugging
String summary = service.getDeviceRecordSummary();
```

### PreferencesService

```dart
import 'package:money_manager/services/preferences_service.dart';

final prefs = await PreferencesService.getInstance();

// Save device record
await prefs.setDeviceRecord(deviceRecord);

// Load device record
Device? record = prefs.getDeviceRecord();

// Check if device record exists
bool exists = prefs.hasDeviceRecord();

// Clear device record
await prefs.clearDeviceRecord();
```

## Error Handling

The system includes comprehensive error handling:

### Automatic Fallbacks

- If device info collection fails, fallback values are used
- If storage fails, the app continues without crashing
- Corrupted data is automatically cleared and recreated

### Error Types Handled

1. **Device Info Collection Errors**: Platform API failures
2. **Storage Errors**: SharedPreferences failures
3. **Network Errors**: Future API integration
4. **Permission Errors**: Device access permissions
5. **JSON Parsing Errors**: Corrupted stored data

### Custom Error Handling

```dart
import 'package:money_manager/utils/device_record_error_handler.dart';

// Handle specific errors
try {
  await DeviceRecordUtils.setUserId('user_123');
} catch (e) {
  String userMessage = DeviceRecordErrorHandler.getUserFriendlyErrorMessage(e);
  // Show user-friendly error message
}
```

## Testing

The system includes comprehensive unit tests:

```bash
# Run device record tests
flutter test test/device_record_test.dart

# Run preferences service tests (includes device record tests)
flutter test test/preferences_service_test.dart

# Run all tests
flutter test
```

## Dependencies

The device record system uses the following packages:

- `device_info_plus`: Platform-specific device information
- `package_info_plus`: App version and build information
- `timezone`: Timezone data and calculations
- `shared_preferences`: Persistent storage
- `uuid`: Unique identifier generation

## Privacy Considerations

- Device records contain no personally identifiable information
- User ID is only set when user explicitly creates an account
- All data is stored locally on the device
- No automatic data transmission to external servers

## Troubleshooting

### Common Issues

1. **Device record is null**: Service may not be initialized
2. **Outdated information**: Call `refreshDeviceRecord()` to update
3. **Storage failures**: Check device storage space
4. **Permission errors**: Ensure app has necessary permissions

### Debug Information

```dart
// Get detailed device record information
String summary = DeviceRecordUtils.getDeviceRecordSummary();
print(summary);

// Check service status
bool isInitialized = DeviceRecordService.instance.isInitialized;
print('Service initialized: $isInitialized');
```

## Future Enhancements

Planned improvements include:

- Server synchronization for multi-device users
- Enhanced analytics integration
- Device fingerprinting for security
- Automatic data cleanup policies
- Performance optimizations
