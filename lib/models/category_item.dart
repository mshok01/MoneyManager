import 'package:flutter/material.dart';

class CategoryItem {
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

  CategoryItem({
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

  bool get isIncome => id.startsWith('income_');
  bool get isExpense => !isIncome;

  // Factory constructor to create CategoryItem from JSON
  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: iconFromString(json['icon'] as String),
      color: colorFromString(json['color'] as String),
      isDefault: json['isDefault'] as bool,
      createdBy: json['createdBy'] as String,
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int,
      accessTo: List<String>.from(json['accessTo'] as List),
    );
  }

  // Convert CategoryItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': iconToString(icon),
      'color': colorToString(color),
      'isDefault': isDefault,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'accessTo': accessTo,
    };
  }

  // Helper method to convert string to IconData
  static IconData iconFromString(String iconName) {
    switch (iconName) {
      case 'work':
        return Icons.work;
      case 'person_outline':
        return Icons.person_outline;
      case 'business':
        return Icons.business;
      case 'trending_up':
        return Icons.trending_up;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'attach_money':
        return Icons.attach_money;
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'electrical_services':
        return Icons.electrical_services;
      case 'home':
        return Icons.home;
      case 'movie':
        return Icons.movie;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'account_balance':
        return Icons.account_balance;
      case 'more_horiz':
        return Icons.more_horiz;
      case 'category':
        return Icons.category;
      default:
        return Icons.category;
    }
  }

  // Helper method to convert IconData to string
  static String iconToString(IconData icon) {
    if (icon == Icons.work) return 'work';
    if (icon == Icons.person_outline) return 'person_outline';
    if (icon == Icons.business) return 'business';
    if (icon == Icons.trending_up) return 'trending_up';
    if (icon == Icons.card_giftcard) return 'card_giftcard';
    if (icon == Icons.attach_money) return 'attach_money';
    if (icon == Icons.restaurant) return 'restaurant';
    if (icon == Icons.directions_car) return 'directions_car';
    if (icon == Icons.electrical_services) return 'electrical_services';
    if (icon == Icons.home) return 'home';
    if (icon == Icons.movie) return 'movie';
    if (icon == Icons.local_hospital) return 'local_hospital';
    if (icon == Icons.shopping_bag) return 'shopping_bag';
    if (icon == Icons.account_balance) return 'account_balance';
    if (icon == Icons.more_horiz) return 'more_horiz';
    return 'category';
  }

  // Helper method to convert string to Color
  static Color colorFromString(String colorName) {
    switch (colorName) {
      case 'green':
        return Colors.green;
      case 'lightGreen':
        return Colors.lightGreen;
      case 'blue':
        return Colors.blue;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'teal':
        return Colors.teal;
      case 'red':
        return Colors.red;
      case 'amber':
        return Colors.amber;
      case 'brown':
        return Colors.brown;
      case 'pink':
        return Colors.pink;
      case 'indigo':
        return Colors.indigo;
      case 'grey':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  // Helper method to convert Color to string
  static String colorToString(Color color) {
    if (color == Colors.green) return 'green';
    if (color == Colors.lightGreen) return 'lightGreen';
    if (color == Colors.blue) return 'blue';
    if (color == Colors.orange) return 'orange';
    if (color == Colors.purple) return 'purple';
    if (color == Colors.teal) return 'teal';
    if (color == Colors.red) return 'red';
    if (color == Colors.amber) return 'amber';
    if (color == Colors.brown) return 'brown';
    if (color == Colors.pink) return 'pink';
    if (color == Colors.indigo) return 'indigo';
    if (color == Colors.grey) return 'grey';
    return 'blue';
  }

  // Create a copy with updated fields
  CategoryItem copyWith({
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
    return CategoryItem(
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
