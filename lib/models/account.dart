class Account {
  final String id; // UUID string
  final String name; // Account name (e.g., "Home", "Office", "Apartment")
  final String description; // Account description (optional)
  final String pic; // Account picture URL (optional)
  final int createdAt; // milliseconds since epoch in UTC
  final int updatedAt; // milliseconds since epoch in UTC
  final int isActive; // 1 for active, 0 for inactive
  final String createdBy; // userId who created this account
  final List<String> members; // list of user ids part of this account
  final List<String> admins; // list of user ids as admin of this account
  final String
  baseCurrency; // Account's base currency code (e.g., 'USD', 'EUR')
  final String
  baseCurrencyName; // Account's base currency name (e.g., 'US Dollar', 'Euro')

  Account({
    required this.id,
    required this.name,
    required this.description,
    required this.pic,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.createdBy,
    required this.members,
    required this.admins,
    required this.baseCurrency,
    required this.baseCurrencyName,
  });

  /// Factory constructor to create Account from JSON
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      pic: json['pic'] as String? ?? '',
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int,
      isActive: json['isActive'] as int,
      createdBy: json['createdBy'] as String,
      members: List<String>.from(json['members'] as List? ?? []),
      admins: List<String>.from(json['admins'] as List? ?? []),
      baseCurrency: json['baseCurrency'] as String? ?? '',
      baseCurrencyName: json['baseCurrencyName'] as String? ?? '',
    );
  }

  /// Convert Account to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pic': pic,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isActive': isActive,
      'createdBy': createdBy,
      'members': members,
      'admins': admins,
      'baseCurrency': baseCurrency,
      'baseCurrencyName': baseCurrencyName,
    };
  }

  /// Create a copy with updated fields
  Account copyWith({
    String? id,
    String? name,
    String? description,
    String? pic,
    int? createdAt,
    int? updatedAt,
    int? isActive,
    String? createdBy,
    List<String>? members,
    List<String>? admins,
    String? baseCurrency,
    String? baseCurrencyName,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      pic: pic ?? this.pic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      members: members ?? this.members,
      admins: admins ?? this.admins,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      baseCurrencyName: baseCurrencyName ?? this.baseCurrencyName,
    );
  }

  /// Update the updatedAt timestamp to current time (UTC)
  Account updateTimestamp() {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    return copyWith(updatedAt: now);
  }

  /// Check if account is active
  bool get isAccountActive => isActive == 1;

  /// Check if account has a valid name
  bool get hasValidName => name.trim().isNotEmpty;

  /// Check if account has a picture
  bool get hasPicture => pic.isNotEmpty;

  /// Check if user is a member of this account
  bool isMember(String userId) {
    return members.contains(userId);
  }

  /// Check if user is an admin of this account
  bool isAdmin(String userId) {
    return admins.contains(userId);
  }

  /// Check if user is the creator of this account
  bool isCreator(String userId) {
    return createdBy == userId;
  }

  /// Check if user has admin privileges (either admin or creator)
  bool hasAdminPrivileges(String userId) {
    return isAdmin(userId) || isCreator(userId);
  }

  /// Get total number of members
  int get memberCount => members.length;

  /// Get total number of admins
  int get adminCount => admins.length;

  /// Add a member to the account
  Account addMember(String userId) {
    if (isMember(userId)) return this;
    final updatedMembers = List<String>.from(members)..add(userId);
    return copyWith(members: updatedMembers).updateTimestamp();
  }

  /// Remove a member from the account
  Account removeMember(String userId) {
    if (!isMember(userId)) return this;
    final updatedMembers = List<String>.from(members)..remove(userId);
    // Also remove from admins if they were an admin
    final updatedAdmins = List<String>.from(admins)..remove(userId);
    return copyWith(
      members: updatedMembers,
      admins: updatedAdmins,
    ).updateTimestamp();
  }

  /// Add an admin to the account
  Account addAdmin(String userId) {
    if (isAdmin(userId)) return this;
    // Ensure user is also a member
    Account updatedAccount = this;
    if (!isMember(userId)) {
      updatedAccount = addMember(userId);
    }
    final updatedAdmins = List<String>.from(updatedAccount.admins)..add(userId);
    return updatedAccount.copyWith(admins: updatedAdmins).updateTimestamp();
  }

  /// Remove an admin from the account
  Account removeAdmin(String userId) {
    if (!isAdmin(userId)) return this;
    final updatedAdmins = List<String>.from(admins)..remove(userId);
    return copyWith(admins: updatedAdmins).updateTimestamp();
  }

  /// Validate account data
  bool get isValid {
    return id.isNotEmpty &&
        hasValidName &&
        createdAt > 0 &&
        updatedAt > 0 &&
        (isActive == 0 || isActive == 1) &&
        createdBy.isNotEmpty &&
        members.isNotEmpty && // Account must have at least one member
        members.contains(createdBy); // Creator must be a member
  }

  @override
  String toString() {
    return 'Account{id: $id, name: $name, description: $description, pic: $pic, isActive: $isActive, createdBy: $createdBy, members: ${members.length}, admins: ${admins.length}, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Account &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.pic == pic &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isActive == isActive &&
        other.createdBy == createdBy &&
        _listEquals(other.members, members) &&
        _listEquals(other.admins, admins);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      pic,
      createdAt,
      updatedAt,
      isActive,
      createdBy,
      Object.hashAll(members),
      Object.hashAll(admins),
    );
  }

  /// Helper method to compare lists
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
