import 'dart:convert';
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

/// Service to handle authentication API calls to the backend
class AuthApiService {
  static final AuthApiService _instance = AuthApiService._internal();
  static AuthApiService get instance => _instance;
  AuthApiService._internal();

  static final _log = LoggingService.getLogger('AuthApiService');

  // Backend base URL - should be configured from environment
  static const String _baseUrl = 'http://192.168.1.3:8080/api/v1';

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
}
