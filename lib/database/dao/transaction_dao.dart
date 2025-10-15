import '../database_schema.dart';
import '../../models/transaction.dart' as models;
import 'base_dao.dart';

class TransactionDao extends BaseDao<models.Transaction> {
  @override
  String get tableName => DatabaseSchema.tableTransactions;

  @override
  models.Transaction fromMap(Map<String, dynamic> map) {
    return models.Transaction(
      id: map[DatabaseSchema.transactionsId] as String,
      accountId: map[DatabaseSchema.transactionsAccountId] as String,
      categoryId: map[DatabaseSchema.transactionsCategoryId] as String,
      paymentSourceId:
          map[DatabaseSchema.transactionsPaymentSourceId] as String,
      amount: (map[DatabaseSchema.transactionsAmount] as num).toDouble(),
      description: map[DatabaseSchema.transactionsDescription] as String? ?? '',
      type: map[DatabaseSchema.transactionsType] as String,
      transactionDate: map[DatabaseSchema.transactionsTransactionDate] as int,
      createdAt: map[DatabaseSchema.transactionsCreatedAt] as int,
      updatedAt: map[DatabaseSchema.transactionsUpdatedAt] as int,
      isActive: map[DatabaseSchema.transactionsIsActive] as int,
      createdBy: map[DatabaseSchema.transactionsCreatedBy] as String,
    );
  }

  @override
  Map<String, dynamic> toMap(models.Transaction transaction) {
    return {
      DatabaseSchema.transactionsId: transaction.id,
      DatabaseSchema.transactionsAccountId: transaction.accountId,
      DatabaseSchema.transactionsCategoryId: transaction.categoryId,
      DatabaseSchema.transactionsPaymentSourceId: transaction.paymentSourceId,
      DatabaseSchema.transactionsAmount: transaction.amount,
      DatabaseSchema.transactionsDescription: transaction.description,
      DatabaseSchema.transactionsType: transaction.type,
      DatabaseSchema.transactionsTransactionDate: transaction.transactionDate,
      DatabaseSchema.transactionsCreatedAt: transaction.createdAt,
      DatabaseSchema.transactionsUpdatedAt: transaction.updatedAt,
      DatabaseSchema.transactionsIsActive: transaction.isActive,
      DatabaseSchema.transactionsCreatedBy: transaction.createdBy,
    };
  }

  /// Get transactions by account ID
  Future<List<models.Transaction>> getByAccountId(String accountId) async {
    return await getWhere(
      where:
          '${DatabaseSchema.transactionsAccountId} = ? AND ${DatabaseSchema.transactionsIsActive} = 1',
      whereArgs: [accountId],
      orderBy: '${DatabaseSchema.transactionsTransactionDate} DESC',
    );
  }

  /// Get transactions by category ID
  Future<List<models.Transaction>> getByCategoryId(String categoryId) async {
    return await getWhere(
      where:
          '${DatabaseSchema.transactionsCategoryId} = ? AND ${DatabaseSchema.transactionsIsActive} = 1',
      whereArgs: [categoryId],
      orderBy: '${DatabaseSchema.transactionsTransactionDate} DESC',
    );
  }

  /// Get transactions by payment source ID
  Future<List<models.Transaction>> getByPaymentSourceId(
    String paymentSourceId,
  ) async {
    return await getWhere(
      where:
          '${DatabaseSchema.transactionsPaymentSourceId} = ? AND ${DatabaseSchema.transactionsIsActive} = 1',
      whereArgs: [paymentSourceId],
      orderBy: '${DatabaseSchema.transactionsTransactionDate} DESC',
    );
  }

  /// Get transactions by user ID (created by)
  Future<List<models.Transaction>> getByUserId(String userId) async {
    return await getWhere(
      where:
          '${DatabaseSchema.transactionsCreatedBy} = ? AND ${DatabaseSchema.transactionsIsActive} = 1',
      whereArgs: [userId],
      orderBy: '${DatabaseSchema.transactionsTransactionDate} DESC',
    );
  }

  /// Get transactions by type (income/expense)
  Future<List<models.Transaction>> getByType(String type) async {
    return await getWhere(
      where:
          '${DatabaseSchema.transactionsType} = ? AND ${DatabaseSchema.transactionsIsActive} = 1',
      whereArgs: [type],
      orderBy: '${DatabaseSchema.transactionsTransactionDate} DESC',
    );
  }

  /// Get transactions by date range
  Future<List<models.Transaction>> getByDateRange(
    int startDate,
    int endDate,
  ) async {
    return await getWhere(
      where:
          '${DatabaseSchema.transactionsTransactionDate} >= ? AND ${DatabaseSchema.transactionsTransactionDate} <= ? AND ${DatabaseSchema.transactionsIsActive} = 1',
      whereArgs: [startDate, endDate],
      orderBy: '${DatabaseSchema.transactionsTransactionDate} DESC',
    );
  }

  /// Get transactions by account and date range
  Future<List<models.Transaction>> getByAccountAndDateRange(
    String accountId,
    int startDate,
    int endDate,
  ) async {
    return await getWhere(
      where:
          '${DatabaseSchema.transactionsAccountId} = ? AND ${DatabaseSchema.transactionsTransactionDate} >= ? AND ${DatabaseSchema.transactionsTransactionDate} <= ? AND ${DatabaseSchema.transactionsIsActive} = 1',
      whereArgs: [accountId, startDate, endDate],
      orderBy: '${DatabaseSchema.transactionsTransactionDate} DESC',
    );
  }

  /// Get account balance (sum of all transactions)
  Future<double> getAccountBalance(String accountId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT 
        SUM(CASE WHEN ${DatabaseSchema.transactionsType} = '${DatabaseSchema.transactionTypeIncome}' 
            THEN ${DatabaseSchema.transactionsAmount} 
            ELSE -${DatabaseSchema.transactionsAmount} 
        END) as balance
      FROM $tableName 
      WHERE ${DatabaseSchema.transactionsAccountId} = ? 
        AND ${DatabaseSchema.transactionsIsActive} = 1
    ''',
      [accountId],
    );

    if (result.isNotEmpty && result.first['balance'] != null) {
      return (result.first['balance'] as num).toDouble();
    }
    return 0.0;
  }

  /// Get total income for account
  Future<double> getAccountIncome(String accountId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(${DatabaseSchema.transactionsAmount}) as total_income
      FROM $tableName 
      WHERE ${DatabaseSchema.transactionsAccountId} = ? 
        AND ${DatabaseSchema.transactionsType} = '${DatabaseSchema.transactionTypeIncome}'
        AND ${DatabaseSchema.transactionsIsActive} = 1
    ''',
      [accountId],
    );

    if (result.isNotEmpty && result.first['total_income'] != null) {
      return (result.first['total_income'] as num).toDouble();
    }
    return 0.0;
  }

  /// Get total expenses for account
  Future<double> getAccountExpenses(String accountId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(${DatabaseSchema.transactionsAmount}) as total_expenses
      FROM $tableName 
      WHERE ${DatabaseSchema.transactionsAccountId} = ? 
        AND ${DatabaseSchema.transactionsType} = '${DatabaseSchema.transactionTypeExpense}'
        AND ${DatabaseSchema.transactionsIsActive} = 1
    ''',
      [accountId],
    );

    if (result.isNotEmpty && result.first['total_expenses'] != null) {
      return (result.first['total_expenses'] as num).toDouble();
    }
    return 0.0;
  }

  /// Search transactions by description
  Future<List<models.Transaction>> searchByDescription(String query) async {
    return await getWhere(
      where:
          '${DatabaseSchema.transactionsDescription} LIKE ? AND ${DatabaseSchema.transactionsIsActive} = 1',
      whereArgs: ['%$query%'],
      orderBy: '${DatabaseSchema.transactionsTransactionDate} DESC',
    );
  }

  /// Get recent transactions (limit)
  Future<List<models.Transaction>> getRecent(int limit) async {
    return await getWhere(
      where: '${DatabaseSchema.transactionsIsActive} = 1',
      whereArgs: [],
      orderBy: '${DatabaseSchema.transactionsTransactionDate} DESC',
      limit: limit,
    );
  }

  /// Get recent transactions for account
  Future<List<models.Transaction>> getRecentForAccount(
    String accountId,
    int limit,
  ) async {
    return await getWhere(
      where:
          '${DatabaseSchema.transactionsAccountId} = ? AND ${DatabaseSchema.transactionsIsActive} = 1',
      whereArgs: [accountId],
      orderBy: '${DatabaseSchema.transactionsTransactionDate} DESC',
      limit: limit,
    );
  }

  /// Soft delete transaction
  Future<int> softDelete(String transactionId) async {
    final db = await database;
    return await db.update(
      tableName,
      {
        DatabaseSchema.transactionsIsActive: 0,
        DatabaseSchema.transactionsUpdatedAt: DateTime.now()
            .toUtc()
            .millisecondsSinceEpoch,
      },
      where: '${DatabaseSchema.transactionsId} = ?',
      whereArgs: [transactionId],
    );
  }

  /// Get transaction count for account
  Future<int> getTransactionCount(String accountId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM $tableName 
      WHERE ${DatabaseSchema.transactionsAccountId} = ? 
        AND ${DatabaseSchema.transactionsIsActive} = 1
    ''',
      [accountId],
    );

    if (result.isNotEmpty) {
      return result.first['count'] as int;
    }
    return 0;
  }
}
