class DailySummary {
  final int year;
  final int month;
  final int day;
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final int transactionCount;

  DailySummary({
    required this.year,
    required this.month,
    required this.day,
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.transactionCount,
  });

  // Helper methods
  String get dayName {
    final date = DateTime(year, month, day);
    const dayNames = [
      'Monday',
      'Tuesday', 
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return dayNames[date.weekday - 1];
  }

  String get shortDayName {
    final date = DateTime(year, month, day);
    const shortDayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return shortDayNames[date.weekday - 1];
  }

  String get formattedDate {
    return '$day/${month.toString().padLeft(2, '0')}/$year';
  }

  String get formattedDayDate {
    return '$dayName, $day';
  }

  DateTime get date {
    return DateTime(year, month, day);
  }

  Map<String, int> get dayDateRange {
    final startOfDay = DateTime(year, month, day).toUtc();
    final endOfDay = DateTime(year, month, day, 23, 59, 59, 999).toUtc();
    
    return {
      'start': startOfDay.millisecondsSinceEpoch,
      'end': endOfDay.millisecondsSinceEpoch,
    };
  }

  // Boolean checks
  bool get hasTransactions => transactionCount > 0;
  bool get isPositiveBalance => balance > 0;
  bool get isNegativeBalance => balance < 0;
  bool get isZeroBalance => balance == 0;

  @override
  String toString() {
    return 'DailySummary(year: $year, month: $month, day: $day, '
        'totalIncome: $totalIncome, totalExpenses: $totalExpenses, '
        'balance: $balance, transactionCount: $transactionCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailySummary &&
        other.year == year &&
        other.month == month &&
        other.day == day &&
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
      day,
      totalIncome,
      totalExpenses,
      balance,
      transactionCount,
    );
  }
}
