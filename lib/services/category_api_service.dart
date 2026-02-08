import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:money_manager/services/firebase_auth_service.dart';
import '../models/category_item.dart';
import 'logging_service.dart';
import '../config/api_config.dart';

/// Service to handle category API calls to the backend
class CategoryApiService {
  static final CategoryApiService _instance = CategoryApiService._internal();
  static CategoryApiService get instance => _instance;
  CategoryApiService._internal();

  static final _log = LoggingService.getLogger('CategoryApiService');

  // Backend base URL - should be configured from environment

  /// Get all categories for the current user (requires JWT)
  /// Returns list of categories accessible to the user
  Future<List<CategoryItem>> getCategories() async {
    _log.entering('getCategories');
    try {
      final jwtToken = await FirebaseAuthService.instance.getIdToken();
      if (jwtToken == null || jwtToken.isEmpty) {
        throw Exception('Failed to get JWT token');
      }

      _log.d('Fetching categories from backend');

      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/categories'),
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
          'Categories retrieved successfully, count: ${jsonResponse.length}',
        );
        return jsonResponse
            .map((cat) => CategoryItem.fromJson(cat as Map<String, dynamic>))
            .toList();
      } else {
        final errorBody = response.body;
        _log.e('Failed to get categories: $errorBody');
        throw Exception('Failed to get categories: ${response.statusCode}');
      }
    } catch (e) {
      _log.e('Exception during getCategories', error: e);
      rethrow;
    }
  }

  /// Create a new category (requires JWT)
  Future<CategoryItem> createCategory({
    required String name,
    required String description,
    required String icon,
    required String color,
    required int categoryType, // 0 for expense, 1 for income
    required String createdBy,
    List<String>? accessTo,
    required String id,
  }) async {
    _log.entering('createCategory');
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
        'categoryType': categoryType,
        'createdBy': createdBy,
        'isDefault': false,
        'isActive': 1,
        'id': id,
        if (accessTo != null) 'accessTo': accessTo,
      };

      _log.d('Sending create category request to backend');
      _log.d('Request body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/categories'),
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
        _log.d('Category created successfully: ${jsonResponse['id']}');
        return CategoryItem.fromJson(jsonResponse);
      } else {
        final errorBody = response.body;
        _log.e('Failed to create category: $errorBody');
        throw Exception('Failed to create category: ${response.statusCode}');
      }
    } catch (e) {
      _log.e('Exception during createCategory', error: e);
      rethrow;
    }
  }

  /// Delete a category (requires JWT)
  Future<void> deleteCategory({
    required String categoryId,
    required String userId,
  }) async {
    _log.entering('deleteCategory');
    try {
      final jwtToken = await FirebaseAuthService.instance.getIdToken();
      if (jwtToken == null || jwtToken.isEmpty) {
        throw Exception('Failed to get JWT token');
      }

      final requestBody = {'userId': userId};

      _log.d('Sending delete category request to backend');

      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}/categories/$categoryId'),
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
        _log.e('Failed to delete category: $errorBody');
        throw Exception('Failed to delete category: ${response.statusCode}');
      }

      _log.d('Category deleted successfully');
    } catch (e) {
      _log.e('Exception during deleteCategory', error: e);
      rethrow;
    }
  }

  /// Update category name (requires JWT)
  Future<CategoryItem> updateCategoryName({
    required String categoryId,
    required String userId,
    required String name,
  }) async {
    _log.entering('updateCategoryName');
    try {
      final jwtToken = await FirebaseAuthService.instance.getIdToken();
      if (jwtToken == null || jwtToken.isEmpty) {
        throw Exception('Failed to get JWT token');
      }

      final requestBody = {'userId': userId, 'name': name};

      _log.d('Sending update category name request to backend');

      final response = await http
          .patch(
            Uri.parse('${ApiConfig.baseUrl}/categories/$categoryId/name'),
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
        _log.d('Category name updated successfully');
        return CategoryItem.fromJson(jsonResponse);
      } else {
        final errorBody = response.body;
        _log.e('Failed to update category name: $errorBody');
        throw Exception(
          'Failed to update category name: ${response.statusCode}',
        );
      }
    } catch (e) {
      _log.e('Exception during updateCategoryName', error: e);
      rethrow;
    }
  }

  /// Update category description (requires JWT)
  Future<CategoryItem> updateCategoryDescription({
    required String categoryId,
    required String userId,
    required String description,
  }) async {
    _log.entering('updateCategoryDescription');
    try {
      final jwtToken = await FirebaseAuthService.instance.getIdToken();
      if (jwtToken == null || jwtToken.isEmpty) {
        throw Exception('Failed to get JWT token');
      }

      final requestBody = {'userId': userId, 'description': description};

      _log.d('Sending update category description request to backend');

      final response = await http
          .patch(
            Uri.parse(
              '${ApiConfig.baseUrl}/categories/$categoryId/description',
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
        _log.d('Category description updated successfully');
        return CategoryItem.fromJson(jsonResponse);
      } else {
        final errorBody = response.body;
        _log.e('Failed to update category description: $errorBody');
        throw Exception(
          'Failed to update category description: ${response.statusCode}',
        );
      }
    } catch (e) {
      _log.e('Exception during updateCategoryDescription', error: e);
      rethrow;
    }
  }

  /// Update category icon (requires JWT)
  Future<CategoryItem> updateCategoryIcon({
    required String categoryId,
    required String userId,
    required String icon,
  }) async {
    _log.entering('updateCategoryIcon');
    try {
      final jwtToken = await FirebaseAuthService.instance.getIdToken();
      if (jwtToken == null || jwtToken.isEmpty) {
        throw Exception('Failed to get JWT token');
      }

      final requestBody = {'userId': userId, 'icon': icon};

      _log.d('Sending update category icon request to backend');

      final response = await http
          .patch(
            Uri.parse('${ApiConfig.baseUrl}/categories/$categoryId/icon'),
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
        _log.d('Category icon updated successfully');
        return CategoryItem.fromJson(jsonResponse);
      } else {
        final errorBody = response.body;
        _log.e('Failed to update category icon: $errorBody');
        throw Exception(
          'Failed to update category icon: ${response.statusCode}',
        );
      }
    } catch (e) {
      _log.e('Exception during updateCategoryIcon', error: e);
      rethrow;
    }
  }

  /// Update category color (requires JWT)
  Future<CategoryItem> updateCategoryColor({
    required String categoryId,
    required String userId,
    required String color,
  }) async {
    _log.entering('updateCategoryColor');
    try {
      final jwtToken = await FirebaseAuthService.instance.getIdToken();
      if (jwtToken == null || jwtToken.isEmpty) {
        throw Exception('Failed to get JWT token');
      }

      final requestBody = {'userId': userId, 'color': color};

      _log.d('Sending update category color request to backend');

      final response = await http
          .patch(
            Uri.parse('${ApiConfig.baseUrl}/categories/$categoryId/color'),
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
        _log.d('Category color updated successfully');
        return CategoryItem.fromJson(jsonResponse);
      } else {
        final errorBody = response.body;
        _log.e('Failed to update category color: $errorBody');
        throw Exception(
          'Failed to update category color: ${response.statusCode}',
        );
      }
    } catch (e) {
      _log.e('Exception during updateCategoryColor', error: e);
      rethrow;
    }
  }

  /// Update category accessTo (requires JWT)
  Future<CategoryItem> updateCategoryAccessTo({
    required String categoryId,
    required String userId,
    required List<String> accessTo,
  }) async {
    _log.entering('updateCategoryAccessTo');
    try {
      final jwtToken = await FirebaseAuthService.instance.getIdToken();
      if (jwtToken == null || jwtToken.isEmpty) {
        throw Exception('Failed to get JWT token');
      }

      final requestBody = {'userId': userId, 'accessTo': accessTo};

      _log.d('Sending update category accessTo request to backend');

      final response = await http
          .patch(
            Uri.parse('${ApiConfig.baseUrl}/categories/$categoryId/accessTo'),
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
        _log.d('Category accessTo updated successfully');
        return CategoryItem.fromJson(jsonResponse);
      } else {
        final errorBody = response.body;
        _log.e('Failed to update category accessTo: $errorBody');
        throw Exception(
          'Failed to update category accessTo: ${response.statusCode}',
        );
      }
    } catch (e) {
      _log.e('Exception during updateCategoryAccessTo', error: e);
      rethrow;
    }
  }

  /// Update category with all fields (requires JWT)
  Future<CategoryItem> updateCategory({
    required String categoryId,
    required String userId,
    String? name,
    String? description,
    String? icon,
    String? color,
    List<String>? accessTo,
  }) async {
    _log.entering('updateCategory');
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

      _log.d('Sending update category request to backend');
      _log.d('Request body: ${jsonEncode(requestBody)}');

      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/categories/$categoryId'),
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
        _log.d('Category updated successfully');
        return CategoryItem.fromJson(jsonResponse);
      } else {
        final errorBody = response.body;
        _log.e('Failed to update category: $errorBody');
        throw Exception('Failed to update category: ${response.statusCode}');
      }
    } catch (e) {
      _log.e('Exception during updateCategory', error: e);
      rethrow;
    }
  }
}
