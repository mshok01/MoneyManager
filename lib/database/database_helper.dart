import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_schema.dart';

class DatabaseHelper {
  static const String _databaseName = DatabaseSchema.databaseName;
  static const int _databaseVersion = DatabaseSchema.databaseVersion;

  // Table names
  static const String tableUsers = DatabaseSchema.tableUsers;
  static const String tableAccounts = DatabaseSchema.tableAccounts;
  static const String tableCategories = DatabaseSchema.tableCategories;
  static const String tablePaymentSources = DatabaseSchema.tablePaymentSources;

  // Singleton pattern
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._();

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  /// Get database instance
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Configure database settings
  Future<void> _onConfigure(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    await _createUsersTable(db);
    await _createAccountsTable(db);
    await _createCategoriesTable(db);
    await _createPaymentSourcesTable(db);
    await _createIndexes(db);

    // Note: Default data migration will be handled by DatabaseService after initialization
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    // For now, we'll just recreate all tables
    if (oldVersion < newVersion) {
      await _dropAllTables(db);
      await _onCreate(db, newVersion);
    }
  }

  /// Create users table
  Future<void> _createUsersTable(Database db) async {
    await db.execute(DatabaseSchema.createUsersTable);
  }

  /// Create accounts table
  Future<void> _createAccountsTable(Database db) async {
    await db.execute(DatabaseSchema.createAccountsTable);
  }

  /// Create categories table
  Future<void> _createCategoriesTable(Database db) async {
    await db.execute(DatabaseSchema.createCategoriesTable);
  }

  /// Create payment_sources table
  Future<void> _createPaymentSourcesTable(Database db) async {
    await db.execute(DatabaseSchema.createPaymentSourcesTable);
  }

  /// Create database indexes for better performance
  Future<void> _createIndexes(Database db) async {
    for (final indexStatement in DatabaseSchema.createIndexStatements) {
      await db.execute(indexStatement);
    }
  }

  /// Drop all tables (used for migrations)
  Future<void> _dropAllTables(Database db) async {
    for (final dropStatement in DatabaseSchema.dropTableStatements) {
      await db.execute(dropStatement);
    }
  }

  /// Close database connection
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Delete database (useful for testing)
  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  /// Check if database exists
  Future<bool> databaseExists() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    return await databaseFactory.databaseExists(path);
  }

  /// Get database path
  Future<String> getDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, _databaseName);
  }

  /// Execute raw SQL query
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  /// Execute raw SQL command
  Future<int> rawExecute(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawUpdate(sql, arguments);
  }

  /// Begin transaction
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }
}
