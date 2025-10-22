class Device {
  final String id;
  final String platformType; // 'android' or 'ios'
  final String os;
  final String osVersion;
  final String countryCode;
  final String countryName;
  final int createdAt; // milliseconds since epoch in UTC
  final int updatedAt; // milliseconds since epoch in UTC
  final String userId; // initially empty, filled when user is created
  final int lastOpenedAt; // milliseconds since epoch in UTC
  final String appVersion;
  final int appBuildNumber;
  final String deviceManufacturer;
  final String langCode; // language code
  final String timezone;
  final int timezoneOffset; // offset in minutes
  final String fcmToken; // Firebase Cloud Messaging token

  Device({
    required this.id,
    required this.platformType,
    required this.os,
    required this.osVersion,
    required this.countryCode,
    required this.countryName,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.lastOpenedAt,
    required this.appVersion,
    required this.appBuildNumber,
    required this.deviceManufacturer,
    required this.langCode,
    required this.timezone,
    required this.timezoneOffset,
    required this.fcmToken,
  });

  /// Factory constructor to create Device from JSON
  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as String? ?? '',
      platformType: json['platformType'] as String? ?? '',
      os: json['os'] as String? ?? '',
      osVersion: json['osVersion'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '',
      countryName: json['countryName'] as String? ?? '',
      createdAt: json['createdAt'] as int? ?? 0,
      updatedAt: json['updatedAt'] as int? ?? 0,
      userId: json['userId'] as String? ?? '',
      lastOpenedAt: json['lastOpenedAt'] as int? ?? 0,
      appVersion: json['appVersion'] as String? ?? '',
      appBuildNumber: json['appBuildNumber'] as int? ?? 0,
      deviceManufacturer: json['deviceManufacturer'] as String? ?? '',
      langCode: json['langCode'] as String? ?? '',
      timezone: json['timezone'] as String? ?? '',
      timezoneOffset: json['timezoneOffset'] as int? ?? 0,
      fcmToken: json['fcmToken'] as String? ?? '',
    );
  }

  /// Convert Device to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'platformType': platformType,
      'os': os,
      'osVersion': osVersion,
      'countryCode': countryCode,
      'countryName': countryName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'userId': userId,
      'lastOpenedAt': lastOpenedAt,
      'appVersion': appVersion,
      'appBuildNumber': appBuildNumber,
      'deviceManufacturer': deviceManufacturer,
      'langCode': langCode,
      'timezone': timezone,
      'timezoneOffset': timezoneOffset,
      'fcmToken': fcmToken,
    };
  }

  /// Create a copy with updated fields
  Device copyWith({
    String? id,
    String? platformType,
    String? os,
    String? osVersion,
    String? countryCode,
    String? countryName,
    int? createdAt,
    int? updatedAt,
    String? userId,
    int? lastOpenedAt,
    String? appVersion,
    int? appBuildNumber,
    String? deviceManufacturer,
    String? langCode,
    String? timezone,
    int? timezoneOffset,
    String? fcmToken,
  }) {
    return Device(
      id: id ?? this.id,
      platformType: platformType ?? this.platformType,
      os: os ?? this.os,
      osVersion: osVersion ?? this.osVersion,
      countryCode: countryCode ?? this.countryCode,
      countryName: countryName ?? this.countryName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      appVersion: appVersion ?? this.appVersion,
      appBuildNumber: appBuildNumber ?? this.appBuildNumber,
      deviceManufacturer: deviceManufacturer ?? this.deviceManufacturer,
      langCode: langCode ?? this.langCode,
      timezone: timezone ?? this.timezone,
      timezoneOffset: timezoneOffset ?? this.timezoneOffset,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  /// Update the lastOpenedAt timestamp to current time
  Device updateLastOpenedAt() {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    return copyWith(lastOpenedAt: now, updatedAt: now);
  }

  /// Update the userId field
  Device updateUserId(String newUserId) {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    return copyWith(userId: newUserId, updatedAt: now);
  }

  /// Update the FCM token field
  Device updateFcmToken(String newFcmToken) {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    return copyWith(fcmToken: newFcmToken, updatedAt: now);
  }

  /// Check if the device record has a valid user ID
  bool get hasUserId => userId.isNotEmpty;

  /// Check if this is a new device record (created recently)
  bool get isNewDevice {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final timeDifference = now - createdAt;
    // Consider device as new if created within last 5 minutes
    return timeDifference < (5 * 60 * 1000);
  }

  /// Get a human-readable string representation
  @override
  String toString() {
    return 'DeviceRecord{id: $id, platformType: $platformType, os: $os $osVersion, '
        'country: $countryName ($countryCode), userId: $userId, '
        'appVersion: $appVersion+$appBuildNumber, manufacturer: $deviceManufacturer, '
        'lang: $langCode, timezone: $timezone ($timezoneOffset min)}';
  }

  /// Check equality based on device ID
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Device && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
