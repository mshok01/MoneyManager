import 'package:flutter/material.dart';

class PaymentSource {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isDefault;
  final String createdBy;
  final int createdAt;
  final int updatedAt;
  final List<String> accessTo;

  PaymentSource({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.isDefault,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.accessTo,
  });

  // Factory constructor to create PaymentSource from JSON
  factory PaymentSource.fromJson(Map<String, dynamic> json) {
    return PaymentSource(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: _iconFromString(json['icon'] as String),
      color: _colorFromString(json['color'] as String),
      isDefault: json['isDefault'] as bool,
      createdBy: json['createdBy'] as String,
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int,
      accessTo: List<String>.from(json['accessTo'] as List),
    );
  }

  // Convert PaymentSource to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': _iconToString(icon),
      'color': _colorToString(color),
      'isDefault': isDefault,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'accessTo': accessTo,
    };
  }

  // Helper method to convert string to IconData
  static IconData _iconFromString(String iconName) {
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

  // Helper method to convert IconData to string
  static String _iconToString(IconData icon) {
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

  // Helper method to convert string to Color
  static Color _colorFromString(String colorName) {
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

  // Helper method to convert Color to string
  static String _colorToString(Color color) {
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

  // Create a copy with updated fields
  PaymentSource copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    Color? color,
    bool? isDefault,
    String? createdBy,
    int? createdAt,
    int? updatedAt,
    List<String>? accessTo,
  }) {
    return PaymentSource(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      accessTo: accessTo ?? this.accessTo,
    );
  }
}
