import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device.dart';
import '../models/user.dart';

class PreferencesService {
  static const String _currencyKey = 'selected_currency';
  static const String _isOnboardingCompleteKey = 'is_onboarding_complete';
  static const String _themeKey = 'selected_theme';
  static const String _deviceRecordKey = 'device_record';
  static const String _userRecordKey = 'user_record';
  static const String _selectedAccountKey = 'selected_account_id';

  static PreferencesService? _instance;
  static SharedPreferences? _preferences;

  // Singleton pattern
  static Future<PreferencesService> getInstance() async {
    _instance ??= PreferencesService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  PreferencesService._();

  // Currency preferences
  Future<void> setSelectedCurrency(String currencyCode) async {
    await _preferences!.setString(_currencyKey, currencyCode);
  }

  String? getSelectedCurrency() {
    return _preferences!.getString(_currencyKey);
  }

  Future<void> clearSelectedCurrency() async {
    await _preferences!.remove(_currencyKey);
  }

  // Account selection preferences
  Future<void> setSelectedAccount(String accountId) async {
    await _preferences!.setString(_selectedAccountKey, accountId);
  }

  String? getSelectedAccount() {
    return _preferences!.getString(_selectedAccountKey);
  }

  Future<void> clearSelectedAccount() async {
    await _preferences!.remove(_selectedAccountKey);
  }

  bool hasSelectedAccount() {
    return _preferences!.containsKey(_selectedAccountKey);
  }

  // Onboarding preferences
  Future<void> setOnboardingComplete(bool isComplete) async {
    await _preferences!.setBool(_isOnboardingCompleteKey, isComplete);
  }

  bool isOnboardingComplete() {
    return _preferences!.getBool(_isOnboardingCompleteKey) ?? false;
  }

  Future<void> clearOnboardingStatus() async {
    await _preferences!.remove(_isOnboardingCompleteKey);
  }

  // Theme preferences
  Future<void> setSelectedTheme(String themeMode) async {
    await _preferences!.setString(_themeKey, themeMode);
  }

  String getSelectedTheme() {
    return _preferences!.getString(_themeKey) ?? 'system';
  }

  Future<void> clearSelectedTheme() async {
    await _preferences!.remove(_themeKey);
  }

  // Clear all preferences (useful for testing or reset)
  Future<void> clearAll() async {
    await _preferences!.clear();
  }

  // Generic boolean preferences
  Future<void> setBool(String key, bool value) async {
    await _preferences!.setBool(key, value);
  }

  bool getBool(String key) {
    return _preferences!.getBool(key) ?? false;
  }

  // Generic remove method
  Future<void> remove(String key) async {
    await _preferences!.remove(key);
  }

  // Check if currency is set
  bool hasCurrencySet() {
    return _preferences!.containsKey(_currencyKey);
  }

  // Get all stored preferences (for debugging)
  Map<String, dynamic> getAllPreferences() {
    final keys = _preferences!.getKeys();
    final Map<String, dynamic> preferences = {};

    for (String key in keys) {
      final value = _preferences!.get(key);
      preferences[key] = value;
    }

    return preferences;
  }

  // Device record preferences
  Future<void> setDeviceRecord(Device deviceRecord) async {
    final jsonString = json.encode(deviceRecord.toJson());
    await _preferences!.setString(_deviceRecordKey, jsonString);
  }

  Device? getDeviceRecord() {
    final jsonString = _preferences!.getString(_deviceRecordKey);
    if (jsonString == null) return null;

    try {
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return Device.fromJson(jsonData);
    } catch (e) {
      // If parsing fails, return null and clear the corrupted data
      clearDeviceRecord();
      return null;
    }
  }

  Future<void> clearDeviceRecord() async {
    await _preferences!.remove(_deviceRecordKey);
  }

  bool hasDeviceRecord() {
    return _preferences!.containsKey(_deviceRecordKey);
  }

  // Update specific device record fields
  Future<void> updateDeviceRecordUserId(String userId) async {
    final deviceRecord = getDeviceRecord();
    if (deviceRecord != null) {
      final updatedRecord = deviceRecord.updateUserId(userId);
      await setDeviceRecord(updatedRecord);
    }
  }

  Future<void> updateDeviceRecordLastOpenedAt() async {
    final deviceRecord = getDeviceRecord();
    if (deviceRecord != null) {
      final updatedRecord = deviceRecord.updateLastOpenedAt();
      await setDeviceRecord(updatedRecord);
    }
  }

  // User record preferences
  Future<void> setUserRecord(User userRecord) async {
    final jsonString = json.encode(userRecord.toJson());
    await _preferences!.setString(_userRecordKey, jsonString);
  }

  User? getUserRecord() {
    final jsonString = _preferences!.getString(_userRecordKey);
    if (jsonString == null) return null;

    try {
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return User.fromJson(jsonData);
    } catch (e) {
      // If parsing fails, return null and clear the corrupted data
      clearUserRecord();
      return null;
    }
  }

  Future<void> clearUserRecord() async {
    await _preferences!.remove(_userRecordKey);
  }

  bool hasUserRecord() {
    return _preferences!.containsKey(_userRecordKey);
  }

  /// Update user record with new data
  Future<void> updateUserRecord(User updatedUser) async {
    await setUserRecord(updatedUser);
  }

  /// Update user record timestamp
  Future<void> updateUserRecordTimestamp() async {
    final userRecord = getUserRecord();
    if (userRecord != null) {
      final updatedRecord = userRecord.updateTimestamp();
      await setUserRecord(updatedRecord);
    }
  }
}
