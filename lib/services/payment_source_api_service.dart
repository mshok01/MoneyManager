import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:money_manager/services/firebase_auth_service.dart';
import '../models/payment_source.dart';
import 'logging_service.dart';
import '../config/api_config.dart';

/// Service to handle payment source API calls to the backend
class PaymentSourceApiService {
  static final PaymentSourceApiService _instance =
      PaymentSourceApiService._internal();
  static PaymentSourceApiService get instance => _instance;
  PaymentSourceApiService._internal();

  static final _log = LoggingService.getLogger('PaymentSourceApiService');

  // Backend base URL - should be configured from environment

  /// Get all payment sources for the current user (requires JWT)
  /// Returns list of payment sources accessible to the user
  Future<List<PaymentSource>> getPaymentSources() async {
    _log.entering('getPaymentSources');
    try {
      final jwtToken = await FirebaseAuthService.instance.getIdToken();
      if (jwtToken == null || jwtToken.isEmpty) {
        throw Exception('Failed to get JWT token');
      }

      _log.d('Fetching payment sources from backend');

      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/paymentSources'),
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
        final jsonResponse = jsonDecode(response.body) as List<dynamic>;
        _log.d(
          'Payment sources retrieved successfully, count: ${jsonResponse.length}',
        );
        return jsonResponse
            .map((ps) => PaymentSource.fromJson(ps as Map<String, dynamic>))
            .toList();
      } else {
        final errorBody = response.body;
        _log.e('Failed to get payment sources: $errorBody');
        throw Exception(
          'Failed to get payment sources: ${response.statusCode}',
        );
      }
    } catch (e) {
      _log.e('Exception during getPaymentSources', error: e);
      rethrow;
    }
  }

  /// Create a new payment source (requires JWT)
  Future<PaymentSource> createPaymentSource({
    required String name,
    required String description,
    required String icon,
    required String color,
    required String createdBy,
    List<String>? accessTo,
    required String id,
  }) async {
    _log.entering('createPaymentSource');
    try {
      final jwtToken = await FirebaseAuthService.instance.getIdToken();
      if (jwtToken == null || jwtToken.isEmpty) {
        throw Exception('Failed to get JWT token');
      }

      final requestBody = {
        'name': name,
        'description': description,
        'icon': icon,
        'color': color,
        'createdBy': createdBy,
        'isDefault': false,
        'isActive': 1,
        'id': id,
        if (accessTo != null) 'accessTo': accessTo,
      };

      _log.d('Sending create payment source request to backend');
      _log.d('Request body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/paymentSources'),
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

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        _log.d('Payment source created successfully: ${jsonResponse['id']}');
        return PaymentSource.fromJson(jsonResponse);
      } else {
        final errorBody = response.body;
        _log.e('Failed to create payment source: $errorBody');
        throw Exception(
          'Failed to create payment source: ${response.statusCode}',
        );
      }
    } catch (e) {
      _log.e('Exception during createPaymentSource', error: e);
      rethrow;
    }
  }

  /// Bulk create payment sources (requires JWT)
  Future<Map<String, dynamic>> bulkCreatePaymentSources({
    required List<Map<String, dynamic>> paymentSources,
  }) async {
    _log.entering('bulkCreatePaymentSources');
    try {
      final jwtToken = await FirebaseAuthService.instance.getIdToken();
      if (jwtToken == null || jwtToken.isEmpty) {
        throw Exception('Failed to get JWT token');
      }

      final requestBody = {'paymentSources': paymentSources};

      _log.d('Sending bulk create payment sources request to backend');
      _log.d('Request body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/paymentSources/bulk'),
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

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        _log.d(
          'Bulk create payment sources completed: ${jsonResponse['createdCount']} created, ${jsonResponse['failedCount']} failed',
        );
        return jsonResponse;
      } else {
        final errorBody = response.body;
        _log.e('Failed to bulk create payment sources: $errorBody');
        throw Exception(
          'Failed to bulk create payment sources: ${response.statusCode}',
        );
      }
    } catch (e) {
      _log.e('Exception during bulkCreatePaymentSources', error: e);
      rethrow;
    }
  }

  /// Delete a payment source (requires JWT)
  Future<void> deletePaymentSource({
    required String paymentSourceId,
    required String userId,
  }) async {
    _log.entering('deletePaymentSource');
    try {
      final jwtToken = await FirebaseAuthService.instance.getIdToken();
      if (jwtToken == null || jwtToken.isEmpty) {
        throw Exception('Failed to get JWT token');
      }

      final requestBody = {'userId': userId};

      _log.d('Sending delete payment source request to backend');

      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}/paymentSources/$paymentSourceId'),
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

      if (response.statusCode != 200) {
        final errorBody = response.body;
        _log.e('Failed to delete payment source: $errorBody');
        throw Exception(
          'Failed to delete payment source: ${response.statusCode}',
        );
      }

      _log.d('Payment source deleted successfully');
    } catch (e) {
      _log.e('Exception during deletePaymentSource', error: e);
      rethrow;
    }
  }

  /// Update payment source name (requires JWT)
  Future<PaymentSource> updatePaymentSourceName({
    required String paymentSourceId,
    required String userId,
    required String name,
  }) async {
    _log.entering('updatePaymentSourceName');
    try {
      final jwtToken = await FirebaseAuthService.instance.getIdToken();
      if (jwtToken == null || jwtToken.isEmpty) {
        throw Exception('Failed to get JWT token');
      }

      final requestBody = {'userId': userId, 'name': name};

      _log.d('Sending update payment source name request to backend');

      final response = await http
          .patch(
            Uri.parse(
              '${ApiConfig.baseUrl}/paymentSources/$paymentSourceId/name',
            ),
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
        _log.d('Payment source name updated successfully');
        return PaymentSource.fromJson(jsonResponse);
      } else {
        final errorBody = response.body;
        _log.e('Failed to update payment source name: $errorBody');
        throw Exception(
          'Failed to update payment source name: ${response.statusCode}',
        );
      }
    } catch (e) {
      _log.e('Exception during updatePaymentSourceName', error: e);
      rethrow;
    }
  }

  /// Update payment source description (requires JWT)
  Future<PaymentSource> updatePaymentSourceDescription({
    required String paymentSourceId,
    required String userId,
    required String description,
  }) async {
    _log.entering('updatePaymentSourceDescription');
    try {
      final jwtToken = await FirebaseAuthService.instance.getIdToken();
      if (jwtToken == null || jwtToken.isEmpty) {
        throw Exception('Failed to get JWT token');
      }

      final requestBody = {'userId': userId, 'description': description};

      _log.d('Sending update payment source description request to backend');

      final response = await http
          .patch(
            Uri.parse(
              '${ApiConfig.baseUrl}/paymentSources/$paymentSourceId/description',
            ),
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
        _log.d('Payment source description updated successfully');
        return PaymentSource.fromJson(jsonResponse);
      } else {
        final errorBody = response.body;
        _log.e('Failed to update payment source description: $errorBody');
        throw Exception(
          'Failed to update payment source description: ${response.statusCode}',
        );
      }
    } catch (e) {
      _log.e('Exception during updatePaymentSourceDescription', error: e);
      rethrow;
    }
  }

  /// Update payment source icon (requires JWT)
  Future<PaymentSource> updatePaymentSourceIcon({
    required String paymentSourceId,
    required String userId,
    required String icon,
  }) async {
    _log.entering('updatePaymentSourceIcon');
    try {
      final jwtToken = await FirebaseAuthService.instance.getIdToken();
      if (jwtToken == null || jwtToken.isEmpty) {
        throw Exception('Failed to get JWT token');
      }

      final requestBody = {'userId': userId, 'icon': icon};

      _log.d('Sending update payment source icon request to backend');

      final response = await http
          .patch(
            Uri.parse(
              '${ApiConfig.baseUrl}/paymentSources/$paymentSourceId/icon',
            ),
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
        _log.d('Payment source icon updated successfully');
        return PaymentSource.fromJson(jsonResponse);
      } else {
        final errorBody = response.body;
        _log.e('Failed to update payment source icon: $errorBody');
        throw Exception(
          'Failed to update payment source icon: ${response.statusCode}',
        );
      }
    } catch (e) {
      _log.e('Exception during updatePaymentSourceIcon', error: e);
      rethrow;
    }
  }

  /// Update payment source color (requires JWT)
  Future<PaymentSource> updatePaymentSourceColor({
    required String paymentSourceId,
    required String userId,
    required String color,
  }) async {
    _log.entering('updatePaymentSourceColor');
    try {
      final jwtToken = await FirebaseAuthService.instance.getIdToken();
      if (jwtToken == null || jwtToken.isEmpty) {
        throw Exception('Failed to get JWT token');
      }

      final requestBody = {'userId': userId, 'color': color};

      _log.d('Sending update payment source color request to backend');

      final response = await http
          .patch(
            Uri.parse(
              '${ApiConfig.baseUrl}/paymentSources/$paymentSourceId/color',
            ),
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
        _log.d('Payment source color updated successfully');
        return PaymentSource.fromJson(jsonResponse);
      } else {
        final errorBody = response.body;
        _log.e('Failed to update payment source color: $errorBody');
        throw Exception(
          'Failed to update payment source color: ${response.statusCode}',
        );
      }
    } catch (e) {
      _log.e('Exception during updatePaymentSourceColor', error: e);
      rethrow;
    }
  }

  /// Update payment source accessTo (requires JWT)
  Future<PaymentSource> updatePaymentSourceAccessTo({
    required String paymentSourceId,
    required String userId,
    required List<String> accessTo,
  }) async {
    _log.entering('updatePaymentSourceAccessTo');
    try {
      final jwtToken = await FirebaseAuthService.instance.getIdToken();
      if (jwtToken == null || jwtToken.isEmpty) {
        throw Exception('Failed to get JWT token');
      }

      final requestBody = {'userId': userId, 'accessTo': accessTo};

      _log.d('Sending update payment source accessTo request to backend');

      final response = await http
          .patch(
            Uri.parse(
              '${ApiConfig.baseUrl}/paymentSources/$paymentSourceId/accessTo',
            ),
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
        _log.d('Payment source accessTo updated successfully');
        return PaymentSource.fromJson(jsonResponse);
      } else {
        final errorBody = response.body;
        _log.e('Failed to update payment source accessTo: $errorBody');
        throw Exception(
          'Failed to update payment source accessTo: ${response.statusCode}',
        );
      }
    } catch (e) {
      _log.e('Exception during updatePaymentSourceAccessTo', error: e);
      rethrow;
    }
  }

  /// Update payment source with all fields (requires JWT)
  Future<PaymentSource> updatePaymentSource({
    required String paymentSourceId,
    required String userId,
    String? name,
    String? description,
    String? icon,
    String? color,
    List<String>? accessTo,
  }) async {
    _log.entering('updatePaymentSource');
    try {
      final jwtToken = await FirebaseAuthService.instance.getIdToken();
      if (jwtToken == null || jwtToken.isEmpty) {
        throw Exception('Failed to get JWT token');
      }

      final requestBody = {
        'userId': userId,
        'name': name,
        'description': description,
        'icon': icon,
        'color': color,
        'accessTo': accessTo,
      };

      _log.d('Sending update payment source request to backend');
      _log.d('Request body: ${jsonEncode(requestBody)}');

      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/paymentSources/$paymentSourceId'),
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
        _log.d('Payment source updated successfully');
        return PaymentSource.fromJson(jsonResponse);
      } else {
        final errorBody = response.body;
        _log.e('Failed to update payment source: $errorBody');
        throw Exception(
          'Failed to update payment source: ${response.statusCode}',
        );
      }
    } catch (e) {
      _log.e('Exception during updatePaymentSource', error: e);
      rethrow;
    }
  }
}
