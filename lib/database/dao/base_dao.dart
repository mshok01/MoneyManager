import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';

/// Base Data Access Object class with common database operations
abstract class BaseDao<T> {
  /// Get database instance
  Future<Database> get database async => await DatabaseHelper.instance.database;

  /// Table name for this DAO
  String get tableName;

  /// Convert database row to model object
  T fromMap(Map<String, dynamic> map);

  /// Convert model object to database map
  Map<String, dynamic> toMap(T item);

  /// Insert a new record
  Future<String> insert(T item) async {
    final db = await database;
    final map = toMap(item);
    await db.insert(
      tableName,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return map['id'] as String;
  }

  /// Insert multiple records in a transaction
  Future<List<String>> insertBatch(List<T> items) async {
    final db = await database;
    final List<String> ids = [];

    await db.transaction((txn) async {
      for (final item in items) {
        final map = toMap(item);
        await txn.insert(
          tableName,
          map,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        ids.add(map['id'] as String);
      }
    });

    return ids;
  }

  /// Update an existing record
  Future<int> update(T item, String id) async {
    final db = await database;
    return await db.update(
      tableName,
      toMap(item),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete a record by ID
  Future<int> delete(String id) async {
    final db = await database;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  /// Delete multiple records by IDs
  Future<int> deleteBatch(List<String> ids) async {
    if (ids.isEmpty) return 0;

    final db = await database;
    final placeholders = List.filled(ids.length, '?').join(',');
    return await db.delete(
      tableName,
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }

  /// Get a record by ID
  Future<T?> getById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return fromMap(maps.first);
    }
    return null;
  }

  /// Get all records
  Future<List<T>> getAll() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return maps.map((map) => fromMap(map)).toList();
  }

  /// Get records with custom where clause
  Future<List<T>> getWhere({
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  /// Count records
  Future<int> count({String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    final result = await db.query(
      tableName,
      columns: ['COUNT(*) as count'],
      where: where,
      whereArgs: whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Check if record exists
  Future<bool> exists(String id) async {
    final count = await this.count(where: 'id = ?', whereArgs: [id]);
    return count > 0;
  }

  /// Execute raw query
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  /// Execute raw update/insert/delete
  Future<int> rawExecute(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawUpdate(sql, arguments);
  }

  /// Execute operations in a transaction
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  /// Clear all records from table
  Future<int> clear() async {
    final db = await database;
    return await db.delete(tableName);
  }

  /// Get records by multiple IDs
  Future<List<T>> getByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final db = await database;
    final placeholders = List.filled(ids.length, '?').join(',');
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    return maps.map((map) => fromMap(map)).toList();
  }

  /// Upsert (insert or update) a record
  Future<String> upsert(T item) async {
    final map = toMap(item);
    final id = map['id'] as String;

    if (await exists(id)) {
      await update(item, id);
    } else {
      await insert(item);
    }

    return id;
  }

  /// Batch upsert multiple records
  Future<List<String>> upsertBatch(List<T> items) async {
    final db = await database;
    final List<String> ids = [];

    await db.transaction((txn) async {
      for (final item in items) {
        final map = toMap(item);
        final id = map['id'] as String;

        await txn.insert(
          tableName,
          map,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        ids.add(id);
      }
    });

    return ids;
  }
}
