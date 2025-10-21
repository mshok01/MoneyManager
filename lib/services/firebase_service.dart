import 'dart:ffi';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:money_manager/firebase_options.dart';
import 'logging_service.dart';

/// Service to handle Firebase initialization and FCM token management
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  static FirebaseService get instance => _instance;
  FirebaseService._internal();

  // Logger instance for this service
  static final _log = LoggingService.getLogger('FirebaseService');

  FirebaseMessaging? _messaging;
  String? _fcmToken;
  bool _isInitialized = false;

  /// Get the current FCM token
  String? get fcmToken => _fcmToken;

  /// Check if Firebase is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize Firebase and FCM (without requesting permissions)
  Future<void> initialize() async {
    _log.entering('initialize');

    if (_isInitialized) {
      _log.d('Firebase already initialized, skipping');
      return;
    }

    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _log.i('Firebase initialized successfully');

      // Initialize Firebase Messaging
      _messaging = FirebaseMessaging.instance;
      _log.d('Firebase Messaging instance created');

      // Set up token refresh listener (works without permissions)
      _setupTokenRefreshListener();

      _isInitialized = true;
      _log.i(
        'FirebaseService initialized successfully (permissions not requested yet)',
      );
    } catch (e) {
      _log.e('Failed to initialize Firebase', error: e);
      // Don't throw error to prevent app crash
      // Firebase features will be disabled but app will continue to work
    }

    _log.exiting('initialize');
  }

  /// Request notification permission (call this when user opts in for notifications)
  Future<bool> requestNotificationPermission() async {
    _log.entering('requestNotificationPermission');

    if (!_isInitialized || _messaging == null) {
      _log.w('Firebase not initialized, cannot request permission');
      return false;
    }

    try {
      _log.d('Requesting notification permissions');
      final settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      _log.i('Notification permission status: ${settings.authorizationStatus}');

      // If permission granted, get FCM token
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        _log.d('Permission granted, fetching FCM token');
        await _getFcmToken();
        _log.exiting('requestNotificationPermission', true);
        return true;
      }

      _log.w('Notification permission denied: ${settings.authorizationStatus}');
      _log.exiting('requestNotificationPermission', false);
      return false;
    } catch (e) {
      _log.e('Failed to request notification permission', error: e);
      _log.exiting('requestNotificationPermission', false);
      return false;
    }
  }

  /// Get FCM token
  Future<String?> _getFcmToken() async {
    _log.entering('_getFcmToken');

    try {
      _fcmToken = await _messaging!.getToken();
      _log.i('FCM Token obtained successfully');
      _log.d('FCM Token: $_fcmToken');
      _log.exiting('_getFcmToken', _fcmToken != null);
      return _fcmToken;
    } catch (e) {
      _log.e('Failed to get FCM token', error: e);
      _log.exiting('_getFcmToken', null);
      return null;
    }
  }

  /// Set up token refresh listener
  void _setupTokenRefreshListener() {
    _log.entering('_setupTokenRefreshListener');

    try {
      _messaging!.onTokenRefresh.listen((newToken) {
        _log.i('FCM Token refreshed');
        _log.d('New FCM Token: $newToken');
        _fcmToken = newToken;
        // Notify listeners that token has changed
        _onTokenRefresh?.call(newToken);
      });
      _log.d('Token refresh listener set up successfully');
    } catch (e) {
      _log.e('Failed to set up token refresh listener', error: e);
    }

    _log.exiting('_setupTokenRefreshListener');
  }

  /// Callback for token refresh
  void Function(String)? _onTokenRefresh;

  /// Set callback for when FCM token is refreshed
  void setOnTokenRefresh(void Function(String) callback) {
    _onTokenRefresh = callback;
  }

  /// Manually refresh FCM token
  Future<String?> refreshToken() async {
    _log.entering('refreshToken');

    if (!_isInitialized || _messaging == null) {
      _log.w('Firebase not initialized, cannot refresh token');
      return null;
    }

    try {
      _log.d('Deleting current FCM token');
      // Delete current token and get a new one
      await _messaging!.deleteToken();
      _log.d('Current token deleted, fetching new token');
      final newToken = await _getFcmToken();
      _log.exiting('refreshToken', newToken != null);
      return newToken;
    } catch (e) {
      _log.e('Failed to refresh FCM token', error: e);
      _log.exiting('refreshToken', null);
      return null;
    }
  }

  /// Get current FCM token (only returns existing token, doesn't fetch new one)
  Future<String?> getCurrentToken() async {
    _log.entering('getCurrentToken');

    if (!_isInitialized || _messaging == null) {
      _log.w('Firebase not initialized, cannot get token');
      return null;
    }

    _log.d(
      'Returning existing FCM token: ${_fcmToken != null ? 'available' : 'null'}',
    );
    // Only return existing token, don't fetch new one without permissions
    _log.exiting('getCurrentToken', _fcmToken != null);
    return _fcmToken;
  }

  /// Get FCM token after requesting permissions (call this after user grants permission)
  Future<String?> getTokenWithPermission() async {
    _log.entering('getTokenWithPermission');

    if (!_isInitialized || _messaging == null) {
      _log.w('Firebase not initialized, cannot get token');
      return null;
    }

    if (_fcmToken != null) {
      _log.d('Returning existing FCM token');
      _log.exiting('getTokenWithPermission', true);
      return _fcmToken;
    }

    _log.d('No existing token, fetching new one');
    final token = await _getFcmToken();
    _log.exiting('getTokenWithPermission', token != null);
    return token;
  }

  /// Check if FCM token exists
  bool hasToken() {
    return _fcmToken != null && _fcmToken!.isNotEmpty;
  }

  /// Clear FCM token (for logout scenarios)
  Future<void> clearToken() async {
    _log.entering('clearToken');

    try {
      if (_messaging != null) {
        _log.d('Deleting FCM token from Firebase');
        await _messaging!.deleteToken();
      }
      _fcmToken = null;
      _log.i('FCM token cleared successfully');
    } catch (e) {
      _log.e('Failed to clear FCM token', error: e);
    }

    _log.exiting('clearToken');
  }

  /// Handle background messages (static method required by Firebase)
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    // Note: Cannot use instance logger in static method, using direct logging
    final log = LoggingService.getLogger('FirebaseService.Background');
    log.i('Handling background message: ${message.messageId}');
    log.d('Background message data: ${message.data}');
    // Handle background message here
  }

  /// Set up foreground message handling
  void setupForegroundMessageHandling() {
    _log.entering('setupForegroundMessageHandling');

    if (!_isInitialized || _messaging == null) {
      _log.w('Firebase not initialized, cannot set up message handling');
      return;
    }

    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _log.i('Received foreground message: ${message.messageId}');
        _log.d('Foreground message data: ${message.data}');
        // Handle foreground message here
        _onForegroundMessage?.call(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _log.i('Message opened app: ${message.messageId}');
        _log.d('App-opening message data: ${message.data}');
        // Handle message that opened the app
        _onMessageOpenedApp?.call(message);
      });

      _log.d('Foreground message handling set up successfully');
    } catch (e) {
      _log.e('Failed to set up foreground message handling', error: e);
    }

    _log.exiting('setupForegroundMessageHandling');
  }

  /// Callbacks for message handling
  void Function(RemoteMessage)? _onForegroundMessage;
  void Function(RemoteMessage)? _onMessageOpenedApp;

  /// Set callback for foreground messages
  void setOnForegroundMessage(void Function(RemoteMessage) callback) {
    _onForegroundMessage = callback;
  }

  /// Set callback for messages that opened the app
  void setOnMessageOpenedApp(void Function(RemoteMessage) callback) {
    _onMessageOpenedApp = callback;
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    _log.entering('subscribeToTopic', {'topic': topic});

    if (!_isInitialized || _messaging == null) {
      _log.w('Firebase not initialized, cannot subscribe to topic');
      return;
    }

    try {
      await _messaging!.subscribeToTopic(topic);
      _log.i('Subscribed to topic: $topic');
    } catch (e) {
      _log.e('Failed to subscribe to topic $topic', error: e);
    }

    _log.exiting('subscribeToTopic');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    _log.entering('unsubscribeFromTopic', {'topic': topic});

    if (!_isInitialized || _messaging == null) {
      _log.w('Firebase not initialized, cannot unsubscribe from topic');
      return;
    }

    try {
      await _messaging!.unsubscribeFromTopic(topic);
      _log.i('Unsubscribed from topic: $topic');
    } catch (e) {
      _log.e('Failed to unsubscribe from topic $topic', error: e);
    }

    _log.exiting('unsubscribeFromTopic');
  }

  /// Get initial message (if app was opened from notification)
  Future<RemoteMessage?> getInitialMessage() async {
    _log.entering('getInitialMessage');

    if (!_isInitialized || _messaging == null) {
      _log.w('Firebase not initialized, cannot get initial message');
      return null;
    }

    try {
      final message = await _messaging!.getInitialMessage();
      if (message != null) {
        _log.i('Initial message found: ${message.messageId}');
        _log.d('Initial message data: ${message.data}');
      } else {
        _log.d('No initial message found');
      }
      _log.exiting('getInitialMessage', message != null);
      return message;
    } catch (e) {
      _log.e('Failed to get initial message', error: e);
      _log.exiting('getInitialMessage', null);
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    _onTokenRefresh = null;
    _onForegroundMessage = null;
    _onMessageOpenedApp = null;
  }
}
