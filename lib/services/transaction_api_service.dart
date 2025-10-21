import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import 'logging_service.dart';

/// Service to handle transaction API calls to the backend
class TransactionApiService {
  static final TransactionApiService _instance =
      TransactionApiService._internal();
  static TransactionApiService get instance => _instance;
  TransactionApiService._internal();

  static final _log = LoggingService.getLogger('TransactionApiService');

  // Backend base URL - should be configured from environment
  static const String _baseUrl = 'http://192.168.1.4:8080/api/v1';
  static const String _apiKey = '60FDDA';

  /// Add a transaction to the backend
  /// This method is called asynchronously and doesn't wait for response
  Future<void> addTransaction({required Transaction transaction}) async {
    _log.entering('addTransaction');
    try {
      final requestBody = {
        'id': transaction.id,
        'accountId': transaction.accountId,
        'categoryId': transaction.categoryId,
        'paymentSourceId': transaction.paymentSourceId,
        'amount': transaction.amount,
        'description': transaction.description,
        'type': transaction.type,
        'transactionDate': transaction.transactionDate,
        'isActive': transaction.isActive,
        'createdBy': transaction.createdBy,
      };

      _log.d('Sending add transaction request to backend');
      _log.d('Request body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/transactions'),
            headers: {'Content-Type': 'application/json', 'X-API-Key': _apiKey},
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
        _log.d('Transaction added successfully to backend');
      } else {
        final errorBody = response.body;
        _log.e('Failed to add transaction: $errorBody');
        // Don't throw - we want this to fail silently since local DB already has it
      }
    } catch (e) {
      _log.e('Exception during add transaction', error: e);
      // Don't throw - we want this to fail silently since local DB already has it
    }
  }

  /// Update a transaction on the backend
  /// This method is called asynchronously and doesn't wait for response
  Future<void> updateTransaction({
    required String transactionId,
    required Transaction transaction,
  }) async {
    _log.entering('updateTransaction');
    try {
      final requestBody = {
        'categoryId': transaction.categoryId,
        'paymentSourceId': transaction.paymentSourceId,
        'amount': transaction.amount,
        'description': transaction.description,
        'type': transaction.type,
        'transactionDate': transaction.transactionDate,
        'isActive': transaction.isActive,
        'createdBy': transaction.createdBy,
      };

      _log.d('Sending update transaction request to backend');
      _log.d('Request body: ${jsonEncode(requestBody)}');

      final response = await http
          .put(
            Uri.parse('$_baseUrl/transactions/$transactionId'),
            headers: {'Content-Type': 'application/json', 'X-API-Key': _apiKey},
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
        _log.d('Transaction updated successfully on backend');
      } else {
        final errorBody = response.body;
        _log.e('Failed to update transaction: $errorBody');
        // Don't throw - we want this to fail silently since local DB already has it
      }
    } catch (e) {
      _log.e('Exception during update transaction', error: e);
      // Don't throw - we want this to fail silently since local DB already has it
    }
  }

  /// Delete a transaction from the backend
  /// This method is called asynchronously and doesn't wait for response
  Future<void> deleteTransaction({
    required String transactionId,
    required String createdBy,
  }) async {
    _log.entering('deleteTransaction');
    try {
      final requestBody = {'createdBy': createdBy};

      _log.d('Sending delete transaction request to backend');

      final response = await http
          .delete(
            Uri.parse('$_baseUrl/transactions/$transactionId'),
            headers: {'Content-Type': 'application/json', 'X-API-Key': _apiKey},
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
        _log.d('Transaction deleted successfully from backend');
      } else {
        final errorBody = response.body;
        _log.e('Failed to delete transaction: $errorBody');
        // Don't throw - we want this to fail silently since local DB already has it
      }
    } catch (e) {
      _log.e('Exception during delete transaction', error: e);
      // Don't throw - we want this to fail silently since local DB already has it
    }
  }

  /// Fetch transactions by account ID and timestamp
  /// Returns up to 50 transactions before the given timestamp in decreasing order
  Future<List<Transaction>> getTransactionsByAccountAndTimestamp({
    required String accountId,
    required int timestamp,
    required String jwtToken,
  }) async {
    _log.entering('getTransactionsByAccountAndTimestamp');
    try {
      final requestBody = {'accountId': accountId, 'timestamp': timestamp};

      _log.d(
        'Fetching transactions for account: $accountId, timestamp: $timestamp',
      );
      _log.d('Request body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/transactions/by-account-timestamp'),
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
        final List<dynamic> jsonList = jsonDecode(response.body);
        final transactions = jsonList
            .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
            .toList();
        _log.d('Successfully fetched ${transactions.length} transactions');
        _log.exiting(
          'getTransactionsByAccountAndTimestamp',
          transactions.length,
        );
        return transactions;
      } else {
        final errorBody = response.body;
        _log.e('Failed to fetch transactions: $errorBody');
        _log.exiting('getTransactionsByAccountAndTimestamp', 0);
        return [];
      }
    } catch (e) {
      _log.e('Exception during fetch transactions', error: e);
      _log.exiting('getTransactionsByAccountAndTimestamp', null);
      return [];
    }
  }
}
