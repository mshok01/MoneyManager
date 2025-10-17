import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Service to handle Firebase initialization and FCM token management
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  static FirebaseService get instance => _instance;
  FirebaseService._internal();

  FirebaseMessaging? _messaging;
  String? _fcmToken;
  bool _isInitialized = false;

  /// Get the current FCM token
  String? get fcmToken => _fcmToken;

  /// Check if Firebase is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize Firebase and FCM (without requesting permissions)
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Firebase
      await Firebase.initializeApp();
      debugPrint('Firebase initialized successfully');

      // Initialize Firebase Messaging
      _messaging = FirebaseMessaging.instance;

      // Set up token refresh listener (works without permissions)
      _setupTokenRefreshListener();

      _isInitialized = true;
      debugPrint(
        'FirebaseService initialized successfully (permissions not requested yet)',
      );
    } catch (e) {
      debugPrint('Failed to initialize Firebase: $e');
      // Don't throw error to prevent app crash
      // Firebase features will be disabled but app will continue to work
    }
  }

  /// Request notification permission (call this when user opts in for notifications)
  Future<bool> requestNotificationPermission() async {
    if (!_isInitialized || _messaging == null) {
      debugPrint('Firebase not initialized, cannot request permission');
      return false;
    }

    try {
      final settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint(
        'Notification permission status: ${settings.authorizationStatus}',
      );

      // If permission granted, get FCM token
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await _getFcmToken();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Failed to request notification permission: $e');
      return false;
    }
  }

  /// Get FCM token
  Future<String?> _getFcmToken() async {
    try {
      _fcmToken = await _messaging!.getToken();
      debugPrint('FCM Token: $_fcmToken');
      return _fcmToken;
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
      return null;
    }
  }

  /// Set up token refresh listener
  void _setupTokenRefreshListener() {
    try {
      _messaging!.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token refreshed: $newToken');
        _fcmToken = newToken;
        // Notify listeners that token has changed
        _onTokenRefresh?.call(newToken);
      });
    } catch (e) {
      debugPrint('Failed to set up token refresh listener: $e');
    }
  }

  /// Callback for token refresh
  void Function(String)? _onTokenRefresh;

  /// Set callback for when FCM token is refreshed
  void setOnTokenRefresh(void Function(String) callback) {
    _onTokenRefresh = callback;
  }

  /// Manually refresh FCM token
  Future<String?> refreshToken() async {
    if (!_isInitialized || _messaging == null) {
      debugPrint('Firebase not initialized, cannot refresh token');
      return null;
    }

    try {
      // Delete current token and get a new one
      await _messaging!.deleteToken();
      return await _getFcmToken();
    } catch (e) {
      debugPrint('Failed to refresh FCM token: $e');
      return null;
    }
  }

  /// Get current FCM token (only returns existing token, doesn't fetch new one)
  Future<String?> getCurrentToken() async {
    if (!_isInitialized || _messaging == null) {
      debugPrint('Firebase not initialized, cannot get token');
      return null;
    }

    // Only return existing token, don't fetch new one without permissions
    return _fcmToken;
  }

  /// Get FCM token after requesting permissions (call this after user grants permission)
  Future<String?> getTokenWithPermission() async {
    if (!_isInitialized || _messaging == null) {
      debugPrint('Firebase not initialized, cannot get token');
      return null;
    }

    if (_fcmToken != null) {
      return _fcmToken;
    }

    return await _getFcmToken();
  }

  /// Check if FCM token exists
  bool hasToken() {
    return _fcmToken != null && _fcmToken!.isNotEmpty;
  }

  /// Clear FCM token (for logout scenarios)
  Future<void> clearToken() async {
    try {
      if (_messaging != null) {
        await _messaging!.deleteToken();
      }
      _fcmToken = null;
      debugPrint('FCM token cleared');
    } catch (e) {
      debugPrint('Failed to clear FCM token: $e');
    }
  }

  /// Handle background messages (static method required by Firebase)
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Handling background message: ${message.messageId}');
    // Handle background message here
  }

  /// Set up foreground message handling
  void setupForegroundMessageHandling() {
    if (!_isInitialized || _messaging == null) return;

    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Received foreground message: ${message.messageId}');
        // Handle foreground message here
        _onForegroundMessage?.call(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Message opened app: ${message.messageId}');
        // Handle message that opened the app
        _onMessageOpenedApp?.call(message);
      });
    } catch (e) {
      debugPrint('Failed to set up foreground message handling: $e');
    }
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
    if (!_isInitialized || _messaging == null) return;

    try {
      await _messaging!.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Failed to subscribe to topic $topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (!_isInitialized || _messaging == null) return;

    try {
      await _messaging!.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Failed to unsubscribe from topic $topic: $e');
    }
  }

  /// Get initial message (if app was opened from notification)
  Future<RemoteMessage?> getInitialMessage() async {
    if (!_isInitialized || _messaging == null) return null;

    try {
      return await _messaging!.getInitialMessage();
    } catch (e) {
      debugPrint('Failed to get initial message: $e');
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
