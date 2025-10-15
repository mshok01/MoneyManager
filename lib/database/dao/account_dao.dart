import 'dart:convert';
import '../../models/account.dart';
import '../database_schema.dart';
import 'base_dao.dart';

/// Data Access Object for Account operations
class AccountDao extends BaseDao<Account> {
  @override
  String get tableName => DatabaseSchema.tableAccounts;

  @override
  Account fromMap(Map<String, dynamic> map) {
    return Account(
      id: map[DatabaseSchema.accountsId] as String,
      name: map[DatabaseSchema.accountsName] as String,
      description: map[DatabaseSchema.accountsDescription] as String,
      pic: map[DatabaseSchema.accountsPic] as String,
      createdAt: map[DatabaseSchema.accountsCreatedAt] as int,
      updatedAt: map[DatabaseSchema.accountsUpdatedAt] as int,
      isActive: map[DatabaseSchema.accountsIsActive] as int,
      createdBy: map[DatabaseSchema.accountsCreatedBy] as String,
      members: _parseStringList(map[DatabaseSchema.accountsMembers] as String),
      admins: _parseStringList(map[DatabaseSchema.accountsAdmins] as String),
      baseCurrency: map[DatabaseSchema.accountsBaseCurrency] as String? ?? '',
      baseCurrencyName:
          map[DatabaseSchema.accountsBaseCurrencyName] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap(Account account) {
    return {
      DatabaseSchema.accountsId: account.id,
      DatabaseSchema.accountsName: account.name,
      DatabaseSchema.accountsDescription: account.description,
      DatabaseSchema.accountsPic: account.pic,
      DatabaseSchema.accountsCreatedAt: account.createdAt,
      DatabaseSchema.accountsUpdatedAt: account.updatedAt,
      DatabaseSchema.accountsIsActive: account.isActive,
      DatabaseSchema.accountsCreatedBy: account.createdBy,
      DatabaseSchema.accountsMembers: _stringifyList(account.members),
      DatabaseSchema.accountsAdmins: _stringifyList(account.admins),
      DatabaseSchema.accountsBaseCurrency: account.baseCurrency,
      DatabaseSchema.accountsBaseCurrencyName: account.baseCurrencyName,
    };
  }

  /// Parse JSON string to List<String>
  List<String> _parseStringList(String jsonString) {
    try {
      final List<dynamic> list = json.decode(jsonString);
      return list.cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// Convert List<String> to JSON string
  String _stringifyList(List<String> list) {
    return json.encode(list);
  }

  /// Get accounts created by user
  Future<List<Account>> getAccountsCreatedBy(String userId) async {
    return await getWhere(
      where:
          '${DatabaseSchema.accountsCreatedBy} = ? AND ${DatabaseSchema.accountsIsActive} = ?',
      whereArgs: [userId, 1],
      orderBy: '${DatabaseSchema.accountsName} ASC',
    );
  }

  /// Get accounts where user is a member
  Future<List<Account>> getAccountsForUser(String userId) async {
    return await getWhere(
      where:
          '${DatabaseSchema.accountsMembers} LIKE ? AND ${DatabaseSchema.accountsIsActive} = ?',
      whereArgs: ['%"$userId"%', 1],
      orderBy: '${DatabaseSchema.accountsName} ASC',
    );
  }

  /// Get accounts where user is an admin
  Future<List<Account>> getAccountsWhereUserIsAdmin(String userId) async {
    return await getWhere(
      where:
          '${DatabaseSchema.accountsAdmins} LIKE ? AND ${DatabaseSchema.accountsIsActive} = ?',
      whereArgs: ['%"$userId"%', 1],
      orderBy: '${DatabaseSchema.accountsName} ASC',
    );
  }

  /// Get active accounts
  Future<List<Account>> getActiveAccounts() async {
    return await getWhere(
      where: '${DatabaseSchema.accountsIsActive} = ?',
      whereArgs: [1],
      orderBy: '${DatabaseSchema.accountsName} ASC',
    );
  }

  /// Search accounts by name
  Future<List<Account>> searchAccountsByName(String query) async {
    final searchQuery = '%$query%';
    return await getWhere(
      where:
          '${DatabaseSchema.accountsName} LIKE ? AND ${DatabaseSchema.accountsIsActive} = ?',
      whereArgs: [searchQuery, 1],
      orderBy: '${DatabaseSchema.accountsName} ASC',
    );
  }

  /// Update account activity status
  Future<int> updateActiveStatus(String accountId, bool isActive) async {
    final db = await database;
    return await db.update(
      tableName,
      {
        DatabaseSchema.accountsIsActive: isActive ? 1 : 0,
        DatabaseSchema.accountsUpdatedAt: DateTime.now()
            .toUtc()
            .millisecondsSinceEpoch,
      },
      where: '${DatabaseSchema.accountsId} = ?',
      whereArgs: [accountId],
    );
  }

  /// Update account details
  Future<int> updateAccountDetails(
    String accountId, {
    String? name,
    String? description,
    String? pic,
  }) async {
    final Map<String, dynamic> updates = {
      DatabaseSchema.accountsUpdatedAt: DateTime.now()
          .toUtc()
          .millisecondsSinceEpoch,
    };

    if (name != null) updates[DatabaseSchema.accountsName] = name;
    if (description != null)
      updates[DatabaseSchema.accountsDescription] = description;
    if (pic != null) updates[DatabaseSchema.accountsPic] = pic;

    if (updates.length == 1) return 0; // Only timestamp was added

    final db = await database;
    return await db.update(
      tableName,
      updates,
      where: '${DatabaseSchema.accountsId} = ?',
      whereArgs: [accountId],
    );
  }

  /// Add member to account
  Future<int> addMember(String accountId, String userId) async {
    final account = await getById(accountId);
    if (account == null) return 0;

    final members = List<String>.from(account.members);
    if (!members.contains(userId)) {
      members.add(userId);

      final db = await database;
      return await db.update(
        tableName,
        {
          DatabaseSchema.accountsMembers: _stringifyList(members),
          DatabaseSchema.accountsUpdatedAt: DateTime.now()
              .toUtc()
              .millisecondsSinceEpoch,
        },
        where: '${DatabaseSchema.accountsId} = ?',
        whereArgs: [accountId],
      );
    }
    return 0;
  }

  /// Remove member from account
  Future<int> removeMember(String accountId, String userId) async {
    final account = await getById(accountId);
    if (account == null) return 0;

    final members = List<String>.from(account.members);
    final admins = List<String>.from(account.admins);

    members.remove(userId);
    admins.remove(userId); // Also remove from admins if present

    final db = await database;
    return await db.update(
      tableName,
      {
        DatabaseSchema.accountsMembers: _stringifyList(members),
        DatabaseSchema.accountsAdmins: _stringifyList(admins),
        DatabaseSchema.accountsUpdatedAt: DateTime.now()
            .toUtc()
            .millisecondsSinceEpoch,
      },
      where: '${DatabaseSchema.accountsId} = ?',
      whereArgs: [accountId],
    );
  }

  /// Add admin to account
  Future<int> addAdmin(String accountId, String userId) async {
    final account = await getById(accountId);
    if (account == null) return 0;

    final members = List<String>.from(account.members);
    final admins = List<String>.from(account.admins);

    // Ensure user is a member first
    if (!members.contains(userId)) {
      members.add(userId);
    }

    // Add to admins if not already
    if (!admins.contains(userId)) {
      admins.add(userId);

      final db = await database;
      return await db.update(
        tableName,
        {
          DatabaseSchema.accountsMembers: _stringifyList(members),
          DatabaseSchema.accountsAdmins: _stringifyList(admins),
          DatabaseSchema.accountsUpdatedAt: DateTime.now()
              .toUtc()
              .millisecondsSinceEpoch,
        },
        where: '${DatabaseSchema.accountsId} = ?',
        whereArgs: [accountId],
      );
    }
    return 0;
  }

  /// Remove admin from account
  Future<int> removeAdmin(String accountId, String userId) async {
    final account = await getById(accountId);
    if (account == null) return 0;

    final admins = List<String>.from(account.admins);
    if (admins.contains(userId)) {
      admins.remove(userId);

      final db = await database;
      return await db.update(
        tableName,
        {
          DatabaseSchema.accountsAdmins: _stringifyList(admins),
          DatabaseSchema.accountsUpdatedAt: DateTime.now()
              .toUtc()
              .millisecondsSinceEpoch,
        },
        where: '${DatabaseSchema.accountsId} = ?',
        whereArgs: [accountId],
      );
    }
    return 0;
  }

  /// Check if user can access account
  Future<bool> canUserAccessAccount(String userId, String accountId) async {
    final account = await getById(accountId);
    return account?.members.contains(userId) ?? false;
  }

  /// Check if user is admin of account
  Future<bool> isUserAdmin(String userId, String accountId) async {
    final account = await getById(accountId);
    return account?.admins.contains(userId) ?? false;
  }

  /// Get account statistics
  Future<Map<String, dynamic>> getAccountStats() async {
    final db = await database;

    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM $tableName',
    );
    final activeResult = await db.rawQuery(
      'SELECT COUNT(*) as active FROM $tableName WHERE ${DatabaseSchema.accountsIsActive} = 1',
    );

    return {
      'total': totalResult.first['total'] as int,
      'active': activeResult.first['active'] as int,
      'inactive':
          (totalResult.first['total'] as int) -
          (activeResult.first['active'] as int),
    };
  }

  /// Soft delete account (mark as inactive)
  Future<int> softDelete(String accountId) async {
    return await updateActiveStatus(accountId, false);
  }

  /// Restore soft deleted account
  Future<int> restore(String accountId) async {
    return await updateActiveStatus(accountId, true);
  }

  /// Update account timestamp
  Future<int> updateTimestamp(String accountId) async {
    final db = await database;
    return await db.update(
      tableName,
      {
        DatabaseSchema.accountsUpdatedAt: DateTime.now()
            .toUtc()
            .millisecondsSinceEpoch,
      },
      where: '${DatabaseSchema.accountsId} = ?',
      whereArgs: [accountId],
    );
  }
}
