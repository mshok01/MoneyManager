/// Model representing a summary of transactions for a specific time period
class TransactionSummary {
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final int transactionCount;

  const TransactionSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.transactionCount,
  });

  /// Factory constructor to create an empty summary
  factory TransactionSummary.empty() {
    return const TransactionSummary(
      totalIncome: 0.0,
      totalExpenses: 0.0,
      balance: 0.0,
      transactionCount: 0,
    );
  }

  /// Check if this summary has any transactions
  bool get hasTransactions => transactionCount > 0;

  /// Check if this summary has income
  bool get hasIncome => totalIncome > 0;

  /// Check if this summary has expenses
  bool get hasExpenses => totalExpenses > 0;

  /// Check if the balance is positive
  bool get isPositiveBalance => balance > 0;

  /// Check if the balance is negative
  bool get isNegativeBalance => balance < 0;

  /// Check if the balance is zero
  bool get isZeroBalance => balance == 0;

  /// Get formatted income string
  String get formattedIncome => totalIncome.toStringAsFixed(2);

  /// Get formatted expenses string
  String get formattedExpenses => totalExpenses.toStringAsFixed(2);

  /// Get formatted balance string
  String get formattedBalance => balance.toStringAsFixed(2);

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'balance': balance,
      'transactionCount': transactionCount,
    };
  }

  /// Create from JSON
  factory TransactionSummary.fromJson(Map<String, dynamic> json) {
    return TransactionSummary(
      totalIncome: (json['totalIncome'] as num).toDouble(),
      totalExpenses: (json['totalExpenses'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
      transactionCount: json['transactionCount'] as int,
    );
  }

  /// Create a copy with updated fields
  TransactionSummary copyWith({
    double? totalIncome,
    double? totalExpenses,
    double? balance,
    int? transactionCount,
  }) {
    return TransactionSummary(
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      balance: balance ?? this.balance,
      transactionCount: transactionCount ?? this.transactionCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionSummary &&
        other.totalIncome == totalIncome &&
        other.totalExpenses == totalExpenses &&
        other.balance == balance &&
        other.transactionCount == transactionCount;
  }

  @override
  int get hashCode {
    return Object.hash(
      totalIncome,
      totalExpenses,
      balance,
      transactionCount,
    );
  }

  @override
  String toString() {
    return 'TransactionSummary(totalIncome: $totalIncome, totalExpenses: $totalExpenses, balance: $balance, transactionCount: $transactionCount)';
  }
}
