import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:money_manager/services/firebase_auth_service.dart';
import '../models/user.dart';
import 'logging_service.dart';
import '../config/api_config.dart';

/// Service to handle user API calls to the backend
class UserApiService {
  static final UserApiService _instance = UserApiService._internal();
  static UserApiService get instance => _instance;
  UserApiService._internal();

  static final _log = LoggingService.getLogger('UserApiService');

  // Backend base URL - should be configured from environment

  /// Update user name (PATCH /users/:id/name)
  /// Requires JWT authentication
  Future<User> updateUserName({
    required String userId,
    required String name,
  }) async {
    _log.entering('updateUserName');
    try {
      final jwtToken = await FirebaseAuthService.instance.getIdToken();
      if (jwtToken == null || jwtToken.isEmpty) {
        throw Exception('Failed to get JWT token');
      }

      final requestBody = {'name': name};

      _log.d('Sending update user name request to backend');
      _log.d('Request body: ${jsonEncode(requestBody)}');

      final response = await http
          .patch(
            Uri.parse('${ApiConfig.baseUrl}/users/$userId/name'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $jwtToken',
            },
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

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        _log.d('User name updated successfully');
        return User.fromJson(jsonResponse);
      } else {
        final errorBody = response.body;
        _log.e('Failed to update user name: $errorBody');
        throw Exception('Failed to update user name: ${response.statusCode}');
      }
    } catch (e) {
      _log.e('Exception during updateUserName', error: e);
      rethrow;
    }
  }

  /// Update user email (PATCH /users/:id/email)
  /// Requires JWT authentication
  Future<User> updateUserEmail({
    required String userId,
    required String email,
  }) async {
    _log.entering('updateUserEmail');
    try {
      final jwtToken = await FirebaseAuthService.instance.getIdToken();
      if (jwtToken == null || jwtToken.isEmpty) {
        throw Exception('Failed to get JWT token');
      }

      final requestBody = {'email': email};

      _log.d('Sending update user email request to backend');
      _log.d('Request body: ${jsonEncode(requestBody)}');

      final response = await http
          .patch(
            Uri.parse('${ApiConfig.baseUrl}/users/$userId/email'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $jwtToken',
            },
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

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        _log.d('User email updated successfully');
        return User.fromJson(jsonResponse);
      } else {
        final errorBody = response.body;
        _log.e('Failed to update user email: $errorBody');
        throw Exception('Failed to update user email: ${response.statusCode}');
      }
    } catch (e) {
      _log.e('Exception during updateUserEmail', error: e);
      rethrow;
    }
  }

  /// Update user profile picture (PATCH /users/:id/profilePic)
  /// Requires JWT authentication
  Future<User> updateUserProfilePic({
    required String userId,
    required String profilePic,
  }) async {
    _log.entering('updateUserProfilePic');
    try {
      final jwtToken = await FirebaseAuthService.instance.getIdToken();
      if (jwtToken == null || jwtToken.isEmpty) {
        throw Exception('Failed to get JWT token');
      }

      final requestBody = {'profilePic': profilePic};

      _log.d('Sending update user profile picture request to backend');
      _log.d('Request body: ${jsonEncode(requestBody)}');

      final response = await http
          .patch(
            Uri.parse('${ApiConfig.baseUrl}/users/$userId/profilePic'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $jwtToken',
            },
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

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        _log.d('User profile picture updated successfully');
        return User.fromJson(jsonResponse);
      } else {
        final errorBody = response.body;
        _log.e('Failed to update user profile picture: $errorBody');
        throw Exception(
          'Failed to update user profile picture: ${response.statusCode}',
        );
      }
    } catch (e) {
      _log.e('Exception during updateUserProfilePic', error: e);
      rethrow;
    }
  }

  /// Update user currency (PATCH /users/:id/currency)
  /// Requires JWT authentication
  Future<User> updateUserCurrency({
    required String userId,
    required String currencyCode,
    String? currencyName,
  }) async {
    _log.entering('updateUserCurrency');
    try {
      final jwtToken = await FirebaseAuthService.instance.getIdToken();
      if (jwtToken == null || jwtToken.isEmpty) {
        throw Exception('Failed to get JWT token');
      }

      final requestBody = {
        'currencyCode': currencyCode,
        if (currencyName != null) 'currencyName': currencyName,
      };

      _log.d('Sending update user currency request to backend');
      _log.d('Request body: ${jsonEncode(requestBody)}');

      final response = await http
          .patch(
            Uri.parse('${ApiConfig.baseUrl}/users/$userId/currency'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $jwtToken',
            },
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

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        _log.d('User currency updated successfully');
        return User.fromJson(jsonResponse);
      } else {
        final errorBody = response.body;
        _log.e('Failed to update user currency: $errorBody');
        throw Exception(
          'Failed to update user currency: ${response.statusCode}',
        );
      }
    } catch (e) {
      _log.e('Exception during updateUserCurrency', error: e);
      rethrow;
    }
  }

  /// Delete user account (DELETE /users/:id)
  /// Requires JWT authentication
  /// Permanently deletes the user from the backend
  Future<void> deleteUser({required String userId}) async {
    _log.entering('deleteUser');
    try {
      final jwtToken = await FirebaseAuthService.instance.getIdToken();
      if (jwtToken == null || jwtToken.isEmpty) {
        throw Exception('Failed to get JWT token');
      }

      _log.d('Sending delete user request to backend for user ID: $userId');

      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}/users/$userId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $jwtToken',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              _log.e('Request timeout');
              throw Exception('Request timeout');
            },
          );

      _log.d('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        _log.d('User deleted successfully');
      } else {
        final errorBody = response.body;
        _log.e('Failed to delete user: $errorBody');
        throw Exception('Failed to delete user: ${response.statusCode}');
      }
    } catch (e) {
      _log.e('Exception during deleteUser', error: e);
      rethrow;
    }
  }
}
