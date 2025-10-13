import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // Lists to hold both default and custom categories
  final List<CategoryItem> _incomeCategories = [
    CategoryItem(
      id: 'income_salary',
      name: 'Salary',
      description: 'Regular employment income, wages',
      icon: Icons.work,
      color: Colors.green,
      isDefault: true,
      createdBy: '', // Empty for default categories
      createdAt: 1735669800000, // January 1st, 2025
      updatedAt: 1735669800000, // January 1st, 2025
      accessTo: [], // Empty list for default categories
    ),
    CategoryItem(
      id: 'income_freelance',
      name: 'Freelance',
      description: 'Freelance work, consulting, gig economy',
      icon: Icons.person_outline,
      color: Colors.lightGreen,
      isDefault: true,
      createdBy: '', // Empty for default categories
      createdAt: 1735669800000, // January 1st, 2025
      updatedAt: 1735669800000, // January 1st, 2025
      accessTo: [], // Empty list for default categories
    ),
    CategoryItem(
      id: 'income_business',
      name: 'Business',
      description: 'Business income, self-employment',
      icon: Icons.business,
      color: Colors.blue,
      isDefault: true,
      createdBy: '', // Empty for default categories
      createdAt: 1735669800000, // January 1st, 2025
      updatedAt: 1735669800000, // January 1st, 2025
      accessTo: [], // Empty list for default categories
    ),
    CategoryItem(
      id: 'income_investment',
      name: 'Investment Returns',
      description: 'Dividends, interest, capital gains',
      icon: Icons.trending_up,
      color: Colors.orange,
      isDefault: true,
      createdBy: '', // Empty for default categories
      createdAt: 1735669800000, // January 1st, 2025
      updatedAt: 1735669800000, // January 1st, 2025
      accessTo: [], // Empty list for default categories
    ),
    CategoryItem(
      id: 'income_gifts',
      name: 'Gifts Received',
      description: 'Money gifts, cash presents',
      icon: Icons.card_giftcard,
      color: Colors.purple,
      isDefault: true,
      createdBy: '', // Empty for default categories
      createdAt: 1735669800000, // January 1st, 2025
      updatedAt: 1735669800000, // January 1st, 2025
      accessTo: [], // Empty list for default categories
    ),
    CategoryItem(
      id: 'income_other',
      name: 'Other Income',
      description: 'Refunds, bonuses, miscellaneous income',
      icon: Icons.attach_money,
      color: Colors.teal,
      isDefault: true,
      createdBy: '', // Empty for default categories
      createdAt: 1735669800000, // January 1st, 2025
      updatedAt: 1735669800000, // January 1st, 2025
      accessTo: [], // Empty list for default categories
    ),
  ];

  // Default expense categories
  final List<CategoryItem> _expenseCategories = [
    CategoryItem(
      id: 'expense_food',
      name: 'Food & Dining',
      description: 'Groceries, restaurants, takeout',
      icon: Icons.restaurant,
      color: Colors.red,
      isDefault: true,
      createdBy: '', // Empty for default categories
      createdAt: 1735669800000, // January 1st, 2025
      updatedAt: 1735669800000, // January 1st, 2025
      accessTo: [], // Empty list for default categories
    ),
    CategoryItem(
      id: 'expense_transport',
      name: 'Transportation',
      description: 'Gas, public transport, car maintenance',
      icon: Icons.directions_car,
      color: Colors.orange,
      isDefault: true,
      createdBy: '', // Empty for default categories
      createdAt: 1735669800000, // January 1st, 2025
      updatedAt: 1735669800000, // January 1st, 2025
      accessTo: [], // Empty list for default categories
    ),
    CategoryItem(
      id: 'expense_utilities',
      name: 'Utilities',
      description: 'Electricity, water, internet, phone',
      icon: Icons.electrical_services,
      color: Colors.amber,
      isDefault: true,
      createdBy: '', // Empty for default categories
      createdAt: 1735669800000, // January 1st, 2025
      updatedAt: 1735669800000, // January 1st, 2025
      accessTo: [], // Empty list for default categories
    ),
    CategoryItem(
      id: 'expense_housing',
      name: 'Housing',
      description: 'Rent, mortgage, home maintenance',
      icon: Icons.home,
      color: Colors.brown,
      isDefault: true,
      createdBy: '', // Empty for default categories
      createdAt: 1735669800000, // January 1st, 2025
      updatedAt: 1735669800000, // January 1st, 2025
      accessTo: [], // Empty list for default categories
    ),
    CategoryItem(
      id: 'expense_entertainment',
      name: 'Entertainment',
      description: 'Movies, games, subscriptions, hobbies',
      icon: Icons.movie,
      color: Colors.pink,
      isDefault: true,
      createdBy: '', // Empty for default categories
      createdAt: 1735669800000, // January 1st, 2025
      updatedAt: 1735669800000, // January 1st, 2025
      accessTo: [], // Empty list for default categories
    ),
    CategoryItem(
      id: 'expense_healthcare',
      name: 'Healthcare',
      description: 'Medical, dental, pharmacy, fitness',
      icon: Icons.local_hospital,
      color: Colors.teal,
      isDefault: true,
      createdBy: '', // Empty for default categories
      createdAt: 1735669800000, // January 1st, 2025
      updatedAt: 1735669800000, // January 1st, 2025
      accessTo: [], // Empty list for default categories
    ),
    CategoryItem(
      id: 'expense_shopping',
      name: 'Shopping',
      description: 'Clothing, electronics, personal items',
      icon: Icons.shopping_bag,
      color: Colors.purple,
      isDefault: true,
      createdBy: '', // Empty for default categories
      createdAt: 1735669800000, // January 1st, 2025
      updatedAt: 1735669800000, // January 1st, 2025
      accessTo: [], // Empty list for default categories
    ),
    CategoryItem(
      id: 'expense_financial',
      name: 'Financial',
      description: 'Insurance, taxes, debt payments, savings',
      icon: Icons.account_balance,
      color: Colors.indigo,
      isDefault: true,
      createdBy: '', // Empty for default categories
      createdAt: 1735669800000, // January 1st, 2025
      updatedAt: 1735669800000, // January 1st, 2025
      accessTo: [], // Empty list for default categories
    ),
    CategoryItem(
      id: 'expense_other',
      name: 'Other Expenses',
      description: 'Miscellaneous and uncategorized expenses',
      icon: Icons.more_horiz,
      color: Colors.grey,
      isDefault: true,
      createdBy: '', // Empty for default categories
      createdAt: 1735669800000, // January 1st, 2025
      updatedAt: 1735669800000, // January 1st, 2025
      accessTo: [], // Empty list for default categories
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categories),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCategoryDialog,
            tooltip: l10n.addCategory,
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(
                0.6,
              ),
              indicatorColor: theme.colorScheme.primary,
              tabs: const [
                Tab(icon: Icon(Icons.trending_up), text: 'Income'),
                Tab(icon: Icon(Icons.trending_down), text: 'Expenses'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildCategoryList(_incomeCategories, 'Income'),
                  _buildCategoryList(_expenseCategories, 'Expenses'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<CategoryItem> categories, String type) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: category.color.withOpacity(0.2),
              child: Icon(category.icon, color: category.color),
            ),
            title: Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              category.description,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) =>
                  _handleCategoryAction(value, category, type),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleCategoryAction(
    String action,
    CategoryItem category,
    String type,
  ) {
    switch (action) {
      case 'edit':
        _showEditCategoryDialog(category, type);
        break;
      case 'delete':
        _showDeleteCategoryDialog(category, type);
        break;
    }
  }

  void _showAddCategoryDialog() {
    final l10n = AppLocalizations.of(context)!;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedType = 'Income'; // Default to Income
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.addCategory),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Category Title Input
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: l10n.categoryTitle,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.pleaseEnterTitle;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category Description Input
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: l10n.categoryDescription,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.pleaseEnterDescription;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category Type Selection
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.categoryType,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        RadioListTile<String>(
                          title: Text(l10n.income),
                          value: 'Income',
                          groupValue: selectedType,
                          onChanged: (value) {
                            setState(() {
                              selectedType = value!;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: Text(l10n.expense),
                          value: 'Expense',
                          groupValue: selectedType,
                          onChanged: (value) {
                            setState(() {
                              selectedType = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => _saveNewCategory(
                titleController.text,
                descriptionController.text,
                selectedType,
                formKey,
              ),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _saveNewCategory(
    String title,
    String description,
    String type,
    GlobalKey<FormState> formKey,
  ) {
    final l10n = AppLocalizations.of(context)!;

    if (!formKey.currentState!.validate()) {
      return;
    }

    // Create new category with default icon and color
    final nowMillis = DateTime.now().millisecondsSinceEpoch;
    final newCategory = CategoryItem(
      id: 'custom_$nowMillis',
      name: title.trim(),
      description: description.trim(),
      icon: _getDefaultIconForCategory(title.trim()),
      color: _getDefaultColorForCategory(type),
      isDefault: false,
      createdBy: 'user', // User identifier for custom categories
      createdAt: nowMillis,
      updatedAt: nowMillis,
      accessTo: [
        'user123',
        'user456',
      ], // List of user IDs who can access this category
    );

    // Add to appropriate list
    setState(() {
      if (type == 'Income') {
        _incomeCategories.add(newCategory);
      } else {
        _expenseCategories.add(newCategory);
      }
    });

    // Close dialog
    Navigator.of(context).pop();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.categoryAdded(title.trim())),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  IconData _getDefaultIconForCategory(String title) {
    // Simple logic to assign icons based on category name
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('food') || lowerTitle.contains('dining')) {
      return Icons.restaurant;
    } else if (lowerTitle.contains('transport') || lowerTitle.contains('car')) {
      return Icons.directions_car;
    } else if (lowerTitle.contains('house') || lowerTitle.contains('home')) {
      return Icons.home;
    } else if (lowerTitle.contains('health') ||
        lowerTitle.contains('medical')) {
      return Icons.local_hospital;
    } else if (lowerTitle.contains('work') || lowerTitle.contains('salary')) {
      return Icons.work;
    } else if (lowerTitle.contains('business')) {
      return Icons.business;
    } else if (lowerTitle.contains('investment')) {
      return Icons.trending_up;
    } else {
      return Icons.category; // Default icon
    }
  }

  Color _getDefaultColorForCategory(String type) {
    if (type == 'Income') {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  void _showEditCategoryDialog(CategoryItem category, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit ${category.name} functionality coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteCategoryDialog(CategoryItem category, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Delete ${category.name} functionality coming soon!',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

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
}
