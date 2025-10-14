import 'preferences_service.dart';

/// Service to manage nudge states and track user interactions with onboarding hints
class NudgeService {
  static NudgeService? _instance;
  static NudgeService get instance {
    _instance ??= NudgeService._();
    return _instance!;
  }

  NudgeService._();

  PreferencesService? _preferencesService;
  bool _isInitialized = false;

  // Nudge type constants
  static const String welcomeNudge = 'welcome_nudge';
  static const String accountRenameNudge = 'account_rename_nudge';
  static const String currencyChangeNudge = 'currency_change_nudge';
  static const String multipleAccountsNudge = 'multiple_accounts_nudge';
  static const String categoryCustomizationNudge = 'category_customization_nudge';

  /// Initialize the nudge service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _preferencesService = await PreferencesService.getInstance();
      _isInitialized = true;
    } catch (e) {
      print('NudgeService initialization error: $e');
      _isInitialized = true; // Mark as initialized to prevent retry loops
    }
  }

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Check if a specific nudge has been shown
  bool hasNudgeBeenShown(String nudgeType) {
    if (!_isInitialized) return false;
    return _preferencesService?.getBool('nudge_shown_$nudgeType') ?? false;
  }

  /// Check if a specific nudge has been dismissed
  bool hasNudgeBeenDismissed(String nudgeType) {
    if (!_isInitialized) return false;
    return _preferencesService?.getBool('nudge_dismissed_$nudgeType') ?? false;
  }

  /// Check if a nudge should be shown (not shown before and not dismissed)
  bool shouldShowNudge(String nudgeType) {
    return !hasNudgeBeenShown(nudgeType) && !hasNudgeBeenDismissed(nudgeType);
  }

  /// Mark a nudge as shown
  Future<void> markNudgeAsShown(String nudgeType) async {
    if (!_isInitialized) return;
    await _preferencesService?.setBool('nudge_shown_$nudgeType', true);
  }

  /// Mark a nudge as dismissed
  Future<void> markNudgeAsDismissed(String nudgeType) async {
    if (!_isInitialized) return;
    await _preferencesService?.setBool('nudge_dismissed_$nudgeType', true);
  }

  /// Mark a nudge as both shown and dismissed (for explicit dismissal)
  Future<void> dismissNudge(String nudgeType) async {
    await markNudgeAsShown(nudgeType);
    await markNudgeAsDismissed(nudgeType);
  }

  /// Reset a specific nudge (for testing or re-showing)
  Future<void> resetNudge(String nudgeType) async {
    if (!_isInitialized) return;
    await _preferencesService?.remove('nudge_shown_$nudgeType');
    await _preferencesService?.remove('nudge_dismissed_$nudgeType');
  }

  /// Reset all nudges (for testing or complete reset)
  Future<void> resetAllNudges() async {
    if (!_isInitialized) return;
    
    final nudgeTypes = [
      welcomeNudge,
      accountRenameNudge,
      currencyChangeNudge,
      multipleAccountsNudge,
      categoryCustomizationNudge,
    ];

    for (final nudgeType in nudgeTypes) {
      await resetNudge(nudgeType);
    }
  }

  /// Get the count of nudges shown
  int getNudgesShownCount() {
    if (!_isInitialized) return 0;
    
    final nudgeTypes = [
      welcomeNudge,
      accountRenameNudge,
      currencyChangeNudge,
      multipleAccountsNudge,
      categoryCustomizationNudge,
    ];

    return nudgeTypes.where((nudgeType) => hasNudgeBeenShown(nudgeType)).length;
  }

  /// Get the count of nudges dismissed
  int getNudgesDismissedCount() {
    if (!_isInitialized) return 0;
    
    final nudgeTypes = [
      welcomeNudge,
      accountRenameNudge,
      currencyChangeNudge,
      multipleAccountsNudge,
      categoryCustomizationNudge,
    ];

    return nudgeTypes.where((nudgeType) => hasNudgeBeenDismissed(nudgeType)).length;
  }

  /// Check if this is the user's first time opening the app (no nudges shown)
  bool get isFirstTimeUser => getNudgesShownCount() == 0;

  /// Check if user has completed the basic onboarding nudges
  bool get hasCompletedBasicOnboarding {
    return hasNudgeBeenShown(welcomeNudge) && 
           (hasNudgeBeenDismissed(welcomeNudge) || hasNudgeBeenShown(accountRenameNudge));
  }

  /// Get nudge statistics for debugging
  Map<String, dynamic> getNudgeStatistics() {
    return {
      'isFirstTimeUser': isFirstTimeUser,
      'hasCompletedBasicOnboarding': hasCompletedBasicOnboarding,
      'nudgesShownCount': getNudgesShownCount(),
      'nudgesDismissedCount': getNudgesDismissedCount(),
      'welcomeNudge': {
        'shown': hasNudgeBeenShown(welcomeNudge),
        'dismissed': hasNudgeBeenDismissed(welcomeNudge),
      },
      'accountRenameNudge': {
        'shown': hasNudgeBeenShown(accountRenameNudge),
        'dismissed': hasNudgeBeenDismissed(accountRenameNudge),
      },
      'currencyChangeNudge': {
        'shown': hasNudgeBeenShown(currencyChangeNudge),
        'dismissed': hasNudgeBeenDismissed(currencyChangeNudge),
      },
      'multipleAccountsNudge': {
        'shown': hasNudgeBeenShown(multipleAccountsNudge),
        'dismissed': hasNudgeBeenDismissed(multipleAccountsNudge),
      },
      'categoryCustomizationNudge': {
        'shown': hasNudgeBeenShown(categoryCustomizationNudge),
        'dismissed': hasNudgeBeenDismissed(categoryCustomizationNudge),
      },
    };
  }

  /// Smart nudge scheduling - determine which nudge to show next
  String? getNextNudgeToShow() {
    // Priority order for nudges
    final nudgePriority = [
      welcomeNudge,
      accountRenameNudge,
      currencyChangeNudge,
      multipleAccountsNudge,
      categoryCustomizationNudge,
    ];

    for (final nudgeType in nudgePriority) {
      if (shouldShowNudge(nudgeType)) {
        return nudgeType;
      }
    }

    return null; // No more nudges to show
  }

  /// Check if any nudges are pending
  bool get hasNudgesPending => getNextNudgeToShow() != null;
}
