class Transaction {
  final String id; // UUID string
  final String accountId; // Reference to account
  final String categoryId; // Reference to category
  final String paymentSourceId; // Reference to payment source
  final double amount; // Transaction amount (in account's base currency)
  final String description; // Transaction description
  final String type; // 'income' or 'expense'
  final int transactionDate; // Transaction date in milliseconds since epoch (UTC)
  final int createdAt; // milliseconds since epoch in UTC
  final int updatedAt; // milliseconds since epoch in UTC
  final int isActive; // 1 for active, 0 for deleted/inactive
  final String createdBy; // userId who created this transaction

  Transaction({
    required this.id,
    required this.accountId,
    required this.categoryId,
    required this.paymentSourceId,
    required this.amount,
    required this.description,
    required this.type,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.createdBy,
  });

  /// Factory constructor to create Transaction from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      categoryId: json['categoryId'] as String,
      paymentSourceId: json['paymentSourceId'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      type: json['type'] as String,
      transactionDate: json['transactionDate'] as int,
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int,
      isActive: json['isActive'] as int,
      createdBy: json['createdBy'] as String,
    );
  }

  /// Convert Transaction to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'categoryId': categoryId,
      'paymentSourceId': paymentSourceId,
      'amount': amount,
      'description': description,
      'type': type,
      'transactionDate': transactionDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isActive': isActive,
      'createdBy': createdBy,
    };
  }

  /// Create a copy with updated fields
  Transaction copyWith({
    String? id,
    String? accountId,
    String? categoryId,
    String? paymentSourceId,
    double? amount,
    String? description,
    String? type,
    int? transactionDate,
    int? createdAt,
    int? updatedAt,
    int? isActive,
    String? createdBy,
  }) {
    return Transaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      paymentSourceId: paymentSourceId ?? this.paymentSourceId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      type: type ?? this.type,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  /// Update the updatedAt timestamp to current time (UTC)
  Transaction updateTimestamp() {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    return copyWith(updatedAt: now);
  }

  /// Check if transaction is active
  bool get isTransactionActive => isActive == 1;

  /// Check if transaction has a valid amount
  bool get hasValidAmount => amount > 0;

  /// Check if transaction has a description
  bool get hasDescription => description.trim().isNotEmpty;

  /// Check if transaction type is valid
  bool get hasValidType => type == 'income' || type == 'expense';

  /// Get transaction date as DateTime
  DateTime get transactionDateTime => DateTime.fromMillisecondsSinceEpoch(transactionDate, isUtc: true);

  /// Get created date as DateTime
  DateTime get createdDateTime => DateTime.fromMillisecondsSinceEpoch(createdAt, isUtc: true);

  /// Get updated date as DateTime
  DateTime get updatedDateTime => DateTime.fromMillisecondsSinceEpoch(updatedAt, isUtc: true);

  /// Check if transaction is income
  bool get isIncome => type == 'income';

  /// Check if transaction is expense
  bool get isExpense => type == 'expense';

  /// Validate transaction data
  bool get isValid {
    return id.isNotEmpty &&
        accountId.isNotEmpty &&
        categoryId.isNotEmpty &&
        paymentSourceId.isNotEmpty &&
        hasValidAmount &&
        hasValidType &&
        transactionDate > 0 &&
        createdAt > 0 &&
        updatedAt > 0 &&
        (isActive == 0 || isActive == 1) &&
        createdBy.isNotEmpty;
  }

  @override
  String toString() {
    return 'Transaction{id: $id, accountId: $accountId, amount: $amount, type: $type, description: $description, transactionDate: $transactionDate, isActive: $isActive, createdBy: $createdBy}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.accountId == accountId &&
        other.categoryId == categoryId &&
        other.paymentSourceId == paymentSourceId &&
        other.amount == amount &&
        other.description == description &&
        other.type == type &&
        other.transactionDate == transactionDate &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isActive == isActive &&
        other.createdBy == createdBy;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      accountId,
      categoryId,
      paymentSourceId,
      amount,
      description,
      type,
      transactionDate,
      createdAt,
      updatedAt,
      isActive,
      createdBy,
    );
  }
}

/// Transaction type constants
class TransactionType {
  static const String income = 'income';
  static const String expense = 'expense';
  
  /// Get all valid transaction types
  static List<String> get allTypes => [income, expense];
  
  /// Check if type is valid
  static bool isValid(String type) => allTypes.contains(type);
}
