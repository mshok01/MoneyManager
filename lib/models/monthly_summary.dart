/// Model representing a summary of transactions for a specific month
class MonthlySummary {
  final int year;
  final int month; // 1-12
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final int transactionCount;

  const MonthlySummary({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.transactionCount,
  });

  /// Factory constructor to create an empty summary for a specific month
  factory MonthlySummary.empty(int year, int month) {
    return MonthlySummary(
      year: year,
      month: month,
      totalIncome: 0.0,
      totalExpenses: 0.0,
      balance: 0.0,
      transactionCount: 0,
    );
  }

  /// Get month name
  String get monthName {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }

  /// Get short month name
  String get shortMonthName {
    const shortMonthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return shortMonthNames[month - 1];
  }

  /// Get formatted month and year
  String get formattedMonthYear => '$monthName $year';

  /// Get short formatted month and year
  String get shortFormattedMonthYear => '$shortMonthName $year';

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

  /// Get the first day of this month as DateTime
  DateTime get firstDayOfMonth => DateTime(year, month, 1);

  /// Get the last day of this month as DateTime
  DateTime get lastDayOfMonth => DateTime(year, month + 1, 0);

  /// Get the date range for this month in UTC milliseconds
  Map<String, int> get monthDateRange {
    final startOfMonth = DateTime(year, month, 1).toUtc();
    final endOfMonth = DateTime(
      year,
      month + 1,
      0,
      23,
      59,
      59,
      999,
    ).toUtc();

    return {
      'start': startOfMonth.millisecondsSinceEpoch,
      'end': endOfMonth.millisecondsSinceEpoch,
    };
  }

  /// Check if this month is the current month
  bool get isCurrentMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Check if this month is in the past
  bool get isPastMonth {
    final now = DateTime.now();
    final thisMonth = DateTime(year, month);
    final currentMonth = DateTime(now.year, now.month);
    return thisMonth.isBefore(currentMonth);
  }

  /// Check if this month is in the future
  bool get isFutureMonth {
    final now = DateTime.now();
    final thisMonth = DateTime(year, month);
    final currentMonth = DateTime(now.year, now.month);
    return thisMonth.isAfter(currentMonth);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'balance': balance,
      'transactionCount': transactionCount,
    };
  }

  /// Create from JSON
  factory MonthlySummary.fromJson(Map<String, dynamic> json) {
    return MonthlySummary(
      year: json['year'] as int,
      month: json['month'] as int,
      totalIncome: (json['totalIncome'] as num).toDouble(),
      totalExpenses: (json['totalExpenses'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
      transactionCount: json['transactionCount'] as int,
    );
  }

  /// Create a copy with updated values
  MonthlySummary copyWith({
    int? year,
    int? month,
    double? totalIncome,
    double? totalExpenses,
    double? balance,
    int? transactionCount,
  }) {
    return MonthlySummary(
      year: year ?? this.year,
      month: month ?? this.month,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      balance: balance ?? this.balance,
      transactionCount: transactionCount ?? this.transactionCount,
    );
  }

  @override
  String toString() {
    return 'MonthlySummary(year: $year, month: $month, income: $totalIncome, expenses: $totalExpenses, balance: $balance, count: $transactionCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MonthlySummary &&
        other.year == year &&
        other.month == month &&
        other.totalIncome == totalIncome &&
        other.totalExpenses == totalExpenses &&
        other.balance == balance &&
        other.transactionCount == transactionCount;
  }

  @override
  int get hashCode {
    return Object.hash(
      year,
      month,
      totalIncome,
      totalExpenses,
      balance,
      transactionCount,
    );
  }
}
