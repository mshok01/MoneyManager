import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _currencyKey = 'selected_currency';
  static const String _isOnboardingCompleteKey = 'is_onboarding_complete';
  
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
  
  // Clear all preferences (useful for testing or reset)
  Future<void> clearAll() async {
    await _preferences!.clear();
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
}
