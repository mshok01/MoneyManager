import '../../models/user.dart';
import '../database_schema.dart';
import 'base_dao.dart';

/// Data Access Object for User operations
class UserDao extends BaseDao<User> {
  @override
  String get tableName => DatabaseSchema.tableUsers;

  @override
  User fromMap(Map<String, dynamic> map) {
    return User(
      id: map[DatabaseSchema.usersId] as String,
      createdAt: map[DatabaseSchema.usersCreatedAt] as int,
      updatedAt: map[DatabaseSchema.usersUpdatedAt] as int,
      isActive: map[DatabaseSchema.usersIsActive] as int,
      email: map[DatabaseSchema.usersEmail] as String,
      name: map[DatabaseSchema.usersName] as String,
      profilePic: map[DatabaseSchema.usersProfilePic] as String,
      currencyCode: map[DatabaseSchema.usersCurrencyCode] as String,
      currencyName: map[DatabaseSchema.usersCurrencyName] as String,
    );
  }

  @override
  Map<String, dynamic> toMap(User user) {
    return {
      DatabaseSchema.usersId: user.id,
      DatabaseSchema.usersCreatedAt: user.createdAt,
      DatabaseSchema.usersUpdatedAt: user.updatedAt,
      DatabaseSchema.usersIsActive: user.isActive,
      DatabaseSchema.usersEmail: user.email,
      DatabaseSchema.usersName: user.name,
      DatabaseSchema.usersProfilePic: user.profilePic,
      DatabaseSchema.usersCurrencyCode: user.currencyCode,
      DatabaseSchema.usersCurrencyName: user.currencyName,
    };
  }

  /// Get user by email
  Future<User?> getByEmail(String email) async {
    final users = await getWhere(
      where: '${DatabaseSchema.usersEmail} = ?',
      whereArgs: [email],
      limit: 1,
    );
    return users.isNotEmpty ? users.first : null;
  }

  /// Get active users
  Future<List<User>> getActiveUsers() async {
    return await getWhere(
      where: '${DatabaseSchema.usersIsActive} = ?',
      whereArgs: [1],
      orderBy: '${DatabaseSchema.usersName} ASC',
    );
  }

  /// Get users by currency
  Future<List<User>> getUsersByCurrency(String currencyCode) async {
    return await getWhere(
      where: '${DatabaseSchema.usersCurrencyCode} = ?',
      whereArgs: [currencyCode],
      orderBy: '${DatabaseSchema.usersName} ASC',
    );
  }

  /// Search users by name or email
  Future<List<User>> searchUsers(String query) async {
    final searchQuery = '%$query%';
    return await getWhere(
      where:
          '(${DatabaseSchema.usersName} LIKE ? OR ${DatabaseSchema.usersEmail} LIKE ?) AND ${DatabaseSchema.usersIsActive} = ?',
      whereArgs: [searchQuery, searchQuery, 1],
      orderBy: '${DatabaseSchema.usersName} ASC',
    );
  }

  /// Update user activity status
  Future<int> updateActiveStatus(String userId, bool isActive) async {
    final db = await database;
    return await db.update(
      tableName,
      {
        DatabaseSchema.usersIsActive: isActive ? 1 : 0,
        DatabaseSchema.usersUpdatedAt: DateTime.now()
            .toUtc()
            .millisecondsSinceEpoch,
      },
      where: '${DatabaseSchema.usersId} = ?',
      whereArgs: [userId],
    );
  }

  /// Update user profile
  Future<int> updateProfile(
    String userId, {
    String? name,
    String? email,
    String? profilePic,
  }) async {
    final Map<String, dynamic> updates = {
      DatabaseSchema.usersUpdatedAt: DateTime.now()
          .toUtc()
          .millisecondsSinceEpoch,
    };

    if (name != null) updates[DatabaseSchema.usersName] = name;
    if (email != null) updates[DatabaseSchema.usersEmail] = email;
    if (profilePic != null)
      updates[DatabaseSchema.usersProfilePic] = profilePic;

    if (updates.length == 1) return 0; // Only timestamp was added

    final db = await database;
    return await db.update(
      tableName,
      updates,
      where: '${DatabaseSchema.usersId} = ?',
      whereArgs: [userId],
    );
  }

  /// Update user currency
  Future<int> updateCurrency(
    String userId,
    String currencyCode,
    String currencyName,
  ) async {
    final db = await database;
    return await db.update(
      tableName,
      {
        DatabaseSchema.usersCurrencyCode: currencyCode,
        DatabaseSchema.usersCurrencyName: currencyName,
        DatabaseSchema.usersUpdatedAt: DateTime.now()
            .toUtc()
            .millisecondsSinceEpoch,
      },
      where: '${DatabaseSchema.usersId} = ?',
      whereArgs: [userId],
    );
  }

  /// Check if email exists
  Future<bool> emailExists(String email, {String? excludeUserId}) async {
    String where = '${DatabaseSchema.usersEmail} = ?';
    List<dynamic> whereArgs = [email];

    if (excludeUserId != null) {
      where += ' AND ${DatabaseSchema.usersId} != ?';
      whereArgs.add(excludeUserId);
    }

    final count = await this.count(where: where, whereArgs: whereArgs);
    return count > 0;
  }

  /// Get users created in date range
  Future<List<User>> getUsersCreatedInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await getWhere(
      where: '${DatabaseSchema.usersCreatedAt} BETWEEN ? AND ?',
      whereArgs: [
        startDate.toUtc().millisecondsSinceEpoch,
        endDate.toUtc().millisecondsSinceEpoch,
      ],
      orderBy: '${DatabaseSchema.usersCreatedAt} DESC',
    );
  }

  /// Get users updated since date
  Future<List<User>> getUsersUpdatedSince(DateTime date) async {
    return await getWhere(
      where: '${DatabaseSchema.usersUpdatedAt} > ?',
      whereArgs: [date.toUtc().millisecondsSinceEpoch],
      orderBy: '${DatabaseSchema.usersUpdatedAt} DESC',
    );
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStats() async {
    final db = await database;

    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM $tableName',
    );
    final activeResult = await db.rawQuery(
      'SELECT COUNT(*) as active FROM $tableName WHERE ${DatabaseSchema.usersIsActive} = 1',
    );
    final currencyResult = await db.rawQuery('''
      SELECT ${DatabaseSchema.usersCurrencyCode}, COUNT(*) as count 
      FROM $tableName 
      WHERE ${DatabaseSchema.usersIsActive} = 1 
      GROUP BY ${DatabaseSchema.usersCurrencyCode}
      ORDER BY count DESC
    ''');

    return {
      'total': totalResult.first['total'] as int,
      'active': activeResult.first['active'] as int,
      'inactive':
          (totalResult.first['total'] as int) -
          (activeResult.first['active'] as int),
      'currencies': currencyResult,
    };
  }

  /// Soft delete user (mark as inactive)
  Future<int> softDelete(String userId) async {
    return await updateActiveStatus(userId, false);
  }

  /// Restore soft deleted user
  Future<int> restore(String userId) async {
    return await updateActiveStatus(userId, true);
  }

  /// Update user timestamp
  Future<int> updateTimestamp(String userId) async {
    final db = await database;
    return await db.update(
      tableName,
      {
        DatabaseSchema.usersUpdatedAt: DateTime.now()
            .toUtc()
            .millisecondsSinceEpoch,
      },
      where: '${DatabaseSchema.usersId} = ?',
      whereArgs: [userId],
    );
  }
}
