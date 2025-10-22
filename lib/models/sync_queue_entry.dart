/// Model for tracking pending transaction sync operations
class SyncQueueEntry {
  final String id; // UUID string
  final String transactionId; // Reference to transaction
  final String operation; // CREATE, UPDATE, DELETE
  final int retryCount; // Number of retry attempts
  final String? lastError; // Error message from last failed attempt
  final int createdAt; // milliseconds since epoch in UTC

  SyncQueueEntry({
    required this.id,
    required this.transactionId,
    required this.operation,
    required this.retryCount,
    this.lastError,
    required this.createdAt,
  });

  /// Factory constructor to create SyncQueueEntry from JSON
  factory SyncQueueEntry.fromJson(Map<String, dynamic> json) {
    return SyncQueueEntry(
      id: json['id'] as String,
      transactionId: json['transaction_id'] as String,
      operation: json['operation'] as String,
      retryCount: json['retry_count'] as int,
      lastError: json['last_error'] as String?,
      createdAt: json['created_at'] as int,
    );
  }

  /// Convert SyncQueueEntry to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'operation': operation,
      'retry_count': retryCount,
      'last_error': lastError,
      'created_at': createdAt,
    };
  }

  /// Create a copy with updated fields
  SyncQueueEntry copyWith({
    String? id,
    String? transactionId,
    String? operation,
    int? retryCount,
    String? lastError,
    int? createdAt,
  }) {
    return SyncQueueEntry(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      operation: operation ?? this.operation,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get created date as DateTime
  DateTime get createdDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt, isUtc: true);

  /// Check if entry is valid
  bool get isValid {
    return id.isNotEmpty &&
        transactionId.isNotEmpty &&
        operation.isNotEmpty &&
        retryCount >= 0 &&
        createdAt > 0;
  }

  @override
  String toString() {
    return 'SyncQueueEntry{id: $id, transactionId: $transactionId, operation: $operation, retryCount: $retryCount, createdAt: $createdAt}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncQueueEntry &&
        other.id == id &&
        other.transactionId == transactionId &&
        other.operation == operation &&
        other.retryCount == retryCount &&
        other.lastError == lastError &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      transactionId,
      operation,
      retryCount,
      lastError,
      createdAt,
    );
  }
}

/// Sync operation types
class SyncOperation {
  static const String create = 'CREATE';
  static const String update = 'UPDATE';
  static const String delete = 'DELETE';

  /// Get all valid operations
  static List<String> get allOperations => [create, update, delete];

  /// Check if operation is valid
  static bool isValid(String operation) => allOperations.contains(operation);
}

