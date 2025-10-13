class User {
  final String id; // UUID string
  final int createdAt; // milliseconds since epoch in UTC
  final int updatedAt; // milliseconds since epoch in UTC
  final int isActive; // 1 for active, 0 for inactive
  final String email; // user email address
  final String name; // user display name
  final String profilePic; // profile picture URL or path

  User({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.email,
    required this.name,
    required this.profilePic,
  });

  /// Factory constructor to create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int,
      isActive: json['isActive'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      profilePic: json['profilePic'] as String,
    );
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isActive': isActive,
      'email': email,
      'name': name,
      'profilePic': profilePic,
    };
  }

  /// Create a copy with updated fields
  User copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    int? isActive,
    String? email,
    String? name,
    String? profilePic,
  }) {
    return User(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      email: email ?? this.email,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
    );
  }

  /// Update the updatedAt timestamp to current time (UTC)
  User updateTimestamp() {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    return copyWith(updatedAt: now);
  }

  /// Check if user is active
  bool get isUserActive => isActive == 1;

  /// Check if user has a valid email
  bool get hasValidEmail => email.isNotEmpty && email.contains('@');

  /// Check if user has a name
  bool get hasName => name.isNotEmpty;

  /// Check if user has a profile picture
  bool get hasProfilePic => profilePic.isNotEmpty;

  /// Validate user data
  bool get isValid {
    return id.isNotEmpty &&
        createdAt > 0 &&
        updatedAt > 0 &&
        (isActive == 0 || isActive == 1) &&
        hasValidEmail &&
        hasName;
  }

  @override
  String toString() {
    return 'User{id: $id, email: $email, name: $name, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isActive == isActive &&
        other.email == email &&
        other.name == name &&
        other.profilePic == profilePic;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      createdAt,
      updatedAt,
      isActive,
      email,
      name,
      profilePic,
    );
  }
}
