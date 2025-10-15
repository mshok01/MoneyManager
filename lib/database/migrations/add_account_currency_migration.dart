import 'package:sqflite/sqflite.dart';
import '../database_schema.dart';

/// Migration to add currency fields to accounts table
class AddAccountCurrencyMigration {
  static const int version = 2; // Increment database version
  
  /// Apply the migration - add currency columns to accounts table
  static Future<void> migrate(Database db) async {
    // Add baseCurrency column with default empty string
    await db.execute('''
      ALTER TABLE ${DatabaseSchema.tableAccounts} 
      ADD COLUMN ${DatabaseSchema.accountsBaseCurrency} TEXT NOT NULL DEFAULT ''
    ''');
    
    // Add baseCurrencyName column with default empty string
    await db.execute('''
      ALTER TABLE ${DatabaseSchema.tableAccounts} 
      ADD COLUMN ${DatabaseSchema.accountsBaseCurrencyName} TEXT NOT NULL DEFAULT ''
    ''');
    
    // Update existing accounts to use USD as default currency
    // In a real app, you might want to detect user's locale or ask them
    await db.execute('''
      UPDATE ${DatabaseSchema.tableAccounts} 
      SET ${DatabaseSchema.accountsBaseCurrency} = 'USD',
          ${DatabaseSchema.accountsBaseCurrencyName} = 'US Dollar'
      WHERE ${DatabaseSchema.accountsBaseCurrency} = '' 
         OR ${DatabaseSchema.accountsBaseCurrency} IS NULL
    ''');
  }
  
  /// Rollback the migration - remove currency columns from accounts table
  /// Note: SQLite doesn't support DROP COLUMN, so this would require recreating the table
  static Future<void> rollback(Database db) async {
    // Create new table without currency columns
    await db.execute('''
      CREATE TABLE ${DatabaseSchema.tableAccounts}_backup (
        ${DatabaseSchema.accountsId} TEXT PRIMARY KEY,
        ${DatabaseSchema.accountsName} TEXT NOT NULL,
        ${DatabaseSchema.accountsDescription} TEXT NOT NULL DEFAULT '',
        ${DatabaseSchema.accountsPic} TEXT NOT NULL DEFAULT '',
        ${DatabaseSchema.accountsCreatedAt} INTEGER NOT NULL,
        ${DatabaseSchema.accountsUpdatedAt} INTEGER NOT NULL,
        ${DatabaseSchema.accountsIsActive} INTEGER NOT NULL DEFAULT 1,
        ${DatabaseSchema.accountsCreatedBy} TEXT NOT NULL,
        ${DatabaseSchema.accountsMembers} TEXT NOT NULL DEFAULT '[]',
        ${DatabaseSchema.accountsAdmins} TEXT NOT NULL DEFAULT '[]',
        FOREIGN KEY (${DatabaseSchema.accountsCreatedBy}) REFERENCES ${DatabaseSchema.tableUsers} (${DatabaseSchema.usersId}) ON DELETE CASCADE
      )
    ''');
    
    // Copy data without currency columns
    await db.execute('''
      INSERT INTO ${DatabaseSchema.tableAccounts}_backup 
      SELECT ${DatabaseSchema.accountsId}, 
             ${DatabaseSchema.accountsName}, 
             ${DatabaseSchema.accountsDescription}, 
             ${DatabaseSchema.accountsPic}, 
             ${DatabaseSchema.accountsCreatedAt}, 
             ${DatabaseSchema.accountsUpdatedAt}, 
             ${DatabaseSchema.accountsIsActive}, 
             ${DatabaseSchema.accountsCreatedBy}, 
             ${DatabaseSchema.accountsMembers}, 
             ${DatabaseSchema.accountsAdmins}
      FROM ${DatabaseSchema.tableAccounts}
    ''');
    
    // Drop original table and rename backup
    await db.execute('DROP TABLE ${DatabaseSchema.tableAccounts}');
    await db.execute('ALTER TABLE ${DatabaseSchema.tableAccounts}_backup RENAME TO ${DatabaseSchema.tableAccounts}');
  }
}
