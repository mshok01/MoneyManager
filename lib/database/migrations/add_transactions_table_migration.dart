import 'package:sqflite/sqflite.dart';
import '../database_schema.dart';

/// Migration to add transactions table
class AddTransactionsTableMigration {
  static const int version = 3; // Increment database version
  
  /// Apply the migration - create transactions table
  static Future<void> migrate(Database db) async {
    // Create transactions table
    await db.execute(DatabaseSchema.createTransactionsTable);
    
    // Create indexes for transactions table
    await db.execute('CREATE INDEX idx_transactions_account_id ON ${DatabaseSchema.tableTransactions} (${DatabaseSchema.transactionsAccountId})');
    await db.execute('CREATE INDEX idx_transactions_category_id ON ${DatabaseSchema.tableTransactions} (${DatabaseSchema.transactionsCategoryId})');
    await db.execute('CREATE INDEX idx_transactions_payment_source_id ON ${DatabaseSchema.tableTransactions} (${DatabaseSchema.transactionsPaymentSourceId})');
    await db.execute('CREATE INDEX idx_transactions_created_by ON ${DatabaseSchema.tableTransactions} (${DatabaseSchema.transactionsCreatedBy})');
    await db.execute('CREATE INDEX idx_transactions_type ON ${DatabaseSchema.tableTransactions} (${DatabaseSchema.transactionsType})');
    await db.execute('CREATE INDEX idx_transactions_date ON ${DatabaseSchema.tableTransactions} (${DatabaseSchema.transactionsTransactionDate})');
    await db.execute('CREATE INDEX idx_transactions_is_active ON ${DatabaseSchema.tableTransactions} (${DatabaseSchema.transactionsIsActive})');
    await db.execute('CREATE INDEX idx_transactions_account_date ON ${DatabaseSchema.tableTransactions} (${DatabaseSchema.transactionsAccountId}, ${DatabaseSchema.transactionsTransactionDate})');
  }
  
  /// Rollback the migration - drop transactions table
  static Future<void> rollback(Database db) async {
    await db.execute('DROP TABLE IF EXISTS ${DatabaseSchema.tableTransactions}');
  }
}
