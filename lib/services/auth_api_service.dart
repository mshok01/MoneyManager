import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/device.dart';
import '../models/account.dart';
import 'logging_service.dart';

/// Response model for anonymous auth
class AnonymousAuthResponse {
  final User user;
  final Account account;
  final Device device;
  final String authToken;
  final String firebaseToken;

  AnonymousAuthResponse({
    required this.user,
    required this.account,
    required this.device,
    required this.authToken,
    required this.firebaseToken,
  });

  factory AnonymousAuthResponse.fromJson(Map<String, dynamic> json) {
    return AnonymousAuthResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      account: Account.fromJson(json['account'] as Map<String, dynamic>),
      device: Device.fromJson(json['device'] as Map<String, dynamic>),
      authToken: json['authToken'] as String? ?? '',
      firebaseToken: json['firebaseToken'] as String? ?? '',
    );
  }
}

/// Response model for link account (new Google account)
class LinkAccountResponse {
  final User user;

  LinkAccountResponse({required this.user});

  factory LinkAccountResponse.fromJson(Map<String, dynamic> json) {
    return LinkAccountResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// Response model for link existing account (with data migration)
class LinkExistingAccountResponse {
  final User user;
  final String authToken;
  final String firebaseToken;
  final Map<String, dynamic> mergedData;

  LinkExistingAccountResponse({
    required this.user,
    required this.authToken,
    required this.firebaseToken,
    required this.mergedData,
  });

  factory LinkExistingAccountResponse.fromJson(Map<String, dynamic> json) {
    return LinkExistingAccountResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      authToken: json['authToken'] as String? ?? '',
      firebaseToken: json['firebaseToken'] as String? ?? '',
      mergedData: json['mergedData'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// Service to handle authentication API calls to the backend
class AuthApiService {
  static final AuthApiService _instance = AuthApiService._internal();
  static AuthApiService get instance => _instance;
  AuthApiService._internal();

  static final _log = LoggingService.getLogger('AuthApiService');

  // Backend base URL - should be configured from environment
  static const String _baseUrl = 'http://192.168.1.4:8080/api/v1';

  /// Authenticate anonymously with the backend
  /// Sends Firebase ID token and user/device details
  Future<AnonymousAuthResponse> authenticateAnonymously({
    required String firebaseIdToken,
    required String firebaseUid,
    required User userDetails,
    required Device deviceDetails,
    String? fcmToken,
  }) async {
    _log.entering('authenticateAnonymously');
    try {
      final requestBody = {
        'firebaseIdToken': firebaseIdToken,
        'firebaseUid': firebaseUid,
        'user': userDetails.toJson(),
        'device': deviceDetails.toJson(),
        if (fcmToken != null && fcmToken.isNotEmpty) 'fcmToken': fcmToken,
      };

      _log.d('Sending anonymous auth request to backend');
      _log.d('Request body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/anonymous'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              _log.e('Request timeout');
              throw Exception('Request timeout');
            },
          );

      _log.d('Response status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        _log.d('Anonymous auth successful');
        _log.exiting('authenticateAnonymously', true);
        return AnonymousAuthResponse.fromJson(jsonResponse);
      } else {
        final errorBody = response.body;
        _log.e('Anonymous auth failed: $errorBody');
        throw Exception('Failed to authenticate: ${response.statusCode}');
      }
    } catch (e) {
      _log.e('Exception during anonymous auth', error: e);
      _log.exiting('authenticateAnonymously', null);
      rethrow;
    }
  }

  /// Link a new Google account to an anonymous account
  /// Called when user signs in with Google for the first time
  Future<LinkAccountResponse> linkNewGoogleAccount({
    required String anonymousIdToken,
    required String googleEmail,
    required String name,
    required String profilePic,
  }) async {
    _log.entering('linkNewGoogleAccount');
    try {
      final requestBody = {
        'anonymousIdToken': anonymousIdToken,
        'email': googleEmail,
        'name': name,
        'profilePic': profilePic,
      };

      _log.d('Sending link new account request to backend');
      _log.d('Request body: ${jsonEncode(requestBody)}');
      log(requestBody.toString());

      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/link-account'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              _log.e('Request timeout');
              throw Exception('Request timeout');
            },
          );

      _log.d('Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        _log.d('Link new account successful');
        _log.exiting('linkNewGoogleAccount', true);
        return LinkAccountResponse.fromJson(jsonResponse);
      } else {
        final errorBody = response.body;
        _log.e('Link new account failed: $errorBody');
        throw Exception('Failed to link account: ${response.statusCode}');
      }
    } catch (e) {
      _log.e('Exception during link new account', error: e);
      _log.exiting('linkNewGoogleAccount', null);
      rethrow;
    }
  }

  /// Link an existing Google account with data migration
  /// Called when user tries to link with Google account that already has data
  Future<LinkExistingAccountResponse> linkExistingGoogleAccount({
    required String anonymousIdToken,
    required String googleIdToken,
    required String anonymousUserId,
    required String googleUserId,
  }) async {
    _log.entering('linkExistingGoogleAccount');
    try {
      final requestBody = {
        'anonymousIdToken': anonymousIdToken,
        'googleIdToken': googleIdToken,
        'anonymousUserId': anonymousUserId,
        'googleUserId': googleUserId,
      };

      _log.d('Sending link existing account request to backend');
      _log.d('Request body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/link-existing-account'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              _log.e('Request timeout');
              throw Exception('Request timeout');
            },
          );

      _log.d('Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        _log.d('Link existing account successful');
        _log.exiting('linkExistingGoogleAccount', true);
        return LinkExistingAccountResponse.fromJson(jsonResponse);
      } else {
        final errorBody = response.body;
        _log.e('Link existing account failed: $errorBody');
        throw Exception('Failed to link account: ${response.statusCode}');
      }
    } catch (e) {
      _log.e('Exception during link existing account', error: e);
      _log.exiting('linkExistingGoogleAccount', null);
      rethrow;
    }
  }
}
