import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/payment_source.dart';
import '../database_schema.dart';
import 'base_dao.dart';

/// Data Access Object for PaymentSource operations
class PaymentSourceDao extends BaseDao<PaymentSource> {
  @override
  String get tableName => DatabaseSchema.tablePaymentSources;

  @override
  PaymentSource fromMap(Map<String, dynamic> map) {
    return PaymentSource(
      id: map[DatabaseSchema.paymentSourcesId] as String,
      name: map[DatabaseSchema.paymentSourcesName] as String,
      description: map[DatabaseSchema.paymentSourcesDescription] as String,
      icon: _iconFromString(map[DatabaseSchema.paymentSourcesIcon] as String),
      color: _colorFromString(
        map[DatabaseSchema.paymentSourcesColor] as String,
      ),
      isDefault: (map[DatabaseSchema.paymentSourcesIsDefault] as int) == 1,
      createdBy: map[DatabaseSchema.paymentSourcesCreatedBy] as String,
      createdAt: map[DatabaseSchema.paymentSourcesCreatedAt] as int,
      updatedAt: map[DatabaseSchema.paymentSourcesUpdatedAt] as int,
      accessTo: _parseStringList(
        map[DatabaseSchema.paymentSourcesAccessTo] as String,
      ),
    );
  }

  @override
  Map<String, dynamic> toMap(PaymentSource paymentSource) {
    return {
      DatabaseSchema.paymentSourcesId: paymentSource.id,
      DatabaseSchema.paymentSourcesName: paymentSource.name,
      DatabaseSchema.paymentSourcesDescription: paymentSource.description,
      DatabaseSchema.paymentSourcesIcon: _iconToString(paymentSource.icon),
      DatabaseSchema.paymentSourcesColor: _colorToString(paymentSource.color),
      DatabaseSchema.paymentSourcesIsDefault: paymentSource.isDefault ? 1 : 0,
      DatabaseSchema.paymentSourcesCreatedBy: paymentSource.createdBy,
      DatabaseSchema.paymentSourcesCreatedAt: paymentSource.createdAt,
      DatabaseSchema.paymentSourcesUpdatedAt: paymentSource.updatedAt,
      DatabaseSchema.paymentSourcesAccessTo: _stringifyList(
        paymentSource.accessTo,
      ),
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

  /// Convert string to IconData
  IconData _iconFromString(String iconName) {
    switch (iconName) {
      case 'credit_card':
        return Icons.credit_card;
      case 'credit_card_outlined':
        return Icons.credit_card_outlined;
      case 'qr_code':
        return Icons.qr_code;
      case 'money':
        return Icons.money;
      case 'account_balance':
        return Icons.account_balance;
      case 'wallet':
        return Icons.wallet;
      case 'more_horiz':
        return Icons.more_horiz;
      case 'payment':
        return Icons.payment;
      default:
        return Icons.payment;
    }
  }

  /// Convert IconData to string
  String _iconToString(IconData icon) {
    if (icon == Icons.credit_card) return 'credit_card';
    if (icon == Icons.credit_card_outlined) return 'credit_card_outlined';
    if (icon == Icons.qr_code) return 'qr_code';
    if (icon == Icons.money) return 'money';
    if (icon == Icons.account_balance) return 'account_balance';
    if (icon == Icons.wallet) return 'wallet';
    if (icon == Icons.more_horiz) return 'more_horiz';
    if (icon == Icons.payment) return 'payment';
    return 'payment';
  }

  /// Convert string to Color
  Color _colorFromString(String colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'brown':
        return Colors.brown;
      case 'indigo':
        return Colors.indigo;
      case 'purple':
        return Colors.purple;
      case 'grey':
        return Colors.grey;
      case 'red':
        return Colors.red;
      case 'teal':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  /// Convert Color to string
  String _colorToString(Color color) {
    if (color == Colors.blue) return 'blue';
    if (color == Colors.green) return 'green';
    if (color == Colors.orange) return 'orange';
    if (color == Colors.brown) return 'brown';
    if (color == Colors.indigo) return 'indigo';
    if (color == Colors.purple) return 'purple';
    if (color == Colors.grey) return 'grey';
    if (color == Colors.red) return 'red';
    if (color == Colors.teal) return 'teal';
    return 'blue';
  }

  /// Get default payment sources
  Future<List<PaymentSource>> getDefaultPaymentSources() async {
    return await getWhere(
      where: '${DatabaseSchema.paymentSourcesIsDefault} = ?',
      whereArgs: [1],
      orderBy: '${DatabaseSchema.paymentSourcesName} ASC',
    );
  }

  /// Get custom payment sources (non-default)
  Future<List<PaymentSource>> getCustomPaymentSources() async {
    return await getWhere(
      where: '${DatabaseSchema.paymentSourcesIsDefault} = ?',
      whereArgs: [0],
      orderBy: '${DatabaseSchema.paymentSourcesName} ASC',
    );
  }

  /// Get payment sources created by user
  Future<List<PaymentSource>> getPaymentSourcesCreatedBy(String userId) async {
    return await getWhere(
      where: '${DatabaseSchema.paymentSourcesCreatedBy} = ?',
      whereArgs: [userId],
      orderBy: '${DatabaseSchema.paymentSourcesName} ASC',
    );
  }

  /// Get payment sources accessible to user
  Future<List<PaymentSource>> getPaymentSourcesAccessibleTo(
    String userId,
  ) async {
    return await getWhere(
      where:
          '${DatabaseSchema.paymentSourcesIsDefault} = ? OR ${DatabaseSchema.paymentSourcesCreatedBy} = ? OR ${DatabaseSchema.paymentSourcesAccessTo} LIKE ?',
      whereArgs: [1, userId, '%"$userId"%'],
      orderBy:
          '${DatabaseSchema.paymentSourcesIsDefault} DESC, ${DatabaseSchema.paymentSourcesName} ASC',
    );
  }

  /// Search payment sources by name
  Future<List<PaymentSource>> searchPaymentSources(String query) async {
    final searchQuery = '%$query%';
    return await getWhere(
      where: '${DatabaseSchema.paymentSourcesName} LIKE ?',
      whereArgs: [searchQuery],
      orderBy:
          '${DatabaseSchema.paymentSourcesIsDefault} DESC, ${DatabaseSchema.paymentSourcesName} ASC',
    );
  }

  /// Update payment source details
  Future<int> updatePaymentSourceDetails(
    String paymentSourceId, {
    String? name,
    String? description,
    IconData? icon,
    Color? color,
  }) async {
    final Map<String, dynamic> updates = {
      DatabaseSchema.paymentSourcesUpdatedAt: DateTime.now()
          .toUtc()
          .millisecondsSinceEpoch,
    };

    if (name != null) updates[DatabaseSchema.paymentSourcesName] = name;
    if (description != null) {
      updates[DatabaseSchema.paymentSourcesDescription] = description;
    }
    if (icon != null) {
      updates[DatabaseSchema.paymentSourcesIcon] = _iconToString(icon);
    }
    if (color != null) {
      updates[DatabaseSchema.paymentSourcesColor] = _colorToString(color);
    }

    if (updates.length == 1) return 0; // Only timestamp was added

    final db = await database;
    return await db.update(
      tableName,
      updates,
      where: '${DatabaseSchema.paymentSourcesId} = ?',
      whereArgs: [paymentSourceId],
    );
  }

  /// Add user access to payment source
  Future<int> addUserAccess(String paymentSourceId, String userId) async {
    final paymentSource = await getById(paymentSourceId);
    if (paymentSource == null) return 0;

    final accessTo = List<String>.from(paymentSource.accessTo);
    if (!accessTo.contains(userId)) {
      accessTo.add(userId);

      final db = await database;
      return await db.update(
        tableName,
        {
          DatabaseSchema.paymentSourcesAccessTo: _stringifyList(accessTo),
          DatabaseSchema.paymentSourcesUpdatedAt: DateTime.now()
              .toUtc()
              .millisecondsSinceEpoch,
        },
        where: '${DatabaseSchema.paymentSourcesId} = ?',
        whereArgs: [paymentSourceId],
      );
    }
    return 0;
  }

  /// Remove user access from payment source
  Future<int> removeUserAccess(String paymentSourceId, String userId) async {
    final paymentSource = await getById(paymentSourceId);
    if (paymentSource == null) return 0;

    final accessTo = List<String>.from(paymentSource.accessTo);
    if (accessTo.contains(userId)) {
      accessTo.remove(userId);

      final db = await database;
      return await db.update(
        tableName,
        {
          DatabaseSchema.paymentSourcesAccessTo: _stringifyList(accessTo),
          DatabaseSchema.paymentSourcesUpdatedAt: DateTime.now()
              .toUtc()
              .millisecondsSinceEpoch,
        },
        where: '${DatabaseSchema.paymentSourcesId} = ?',
        whereArgs: [paymentSourceId],
      );
    }
    return 0;
  }

  /// Check if user can access payment source
  Future<bool> canUserAccessPaymentSource(
    String userId,
    String paymentSourceId,
  ) async {
    final paymentSource = await getById(paymentSourceId);
    if (paymentSource == null) return false;

    return paymentSource.isDefault ||
        paymentSource.createdBy == userId ||
        paymentSource.accessTo.contains(userId);
  }

  /// Get payment source statistics
  Future<Map<String, dynamic>> getPaymentSourceStats() async {
    final db = await database;

    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM $tableName',
    );
    final defaultResult = await db.rawQuery(
      'SELECT COUNT(*) as default_count FROM $tableName WHERE ${DatabaseSchema.paymentSourcesIsDefault} = 1',
    );

    return {
      'total': totalResult.first['total'] as int,
      'default': defaultResult.first['default_count'] as int,
      'custom':
          (totalResult.first['total'] as int) -
          (defaultResult.first['default_count'] as int),
    };
  }

  /// Update payment source timestamp
  Future<int> updateTimestamp(String paymentSourceId) async {
    final db = await database;
    return await db.update(
      tableName,
      {
        DatabaseSchema.paymentSourcesUpdatedAt: DateTime.now()
            .toUtc()
            .millisecondsSinceEpoch,
      },
      where: '${DatabaseSchema.paymentSourcesId} = ?',
      whereArgs: [paymentSourceId],
    );
  }
}
