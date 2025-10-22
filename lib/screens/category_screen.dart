import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../models/category_item.dart';
import '../providers/category_providers.dart';
import '../services/category_service.dart';
import '../services/user_service.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomeCategoriesAsync = ref.watch(incomeCategoriesProvider);
    final expenseCategoriesAsync = ref.watch(expenseCategoriesProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categories),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(context, ref),
            tooltip: l10n.addCategory,
          ),
        ],
      ),
      body: incomeCategoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text(l10n.failedToLoadCategories(error.toString()))),
        data: (incomeCategories) {
          return expenseCategoriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Text(l10n.failedToLoadCategories(error.toString())),
            ),
            data: (expenseCategories) {
              return DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      labelColor: theme.colorScheme.primary,
                      unselectedLabelColor: theme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                      indicatorColor: theme.colorScheme.primary,
                      tabs: [
                        Tab(
                          icon: const Icon(Icons.trending_up),
                          text: l10n.income,
                        ),
                        Tab(
                          icon: const Icon(Icons.trending_down),
                          text: l10n.expensesTab,
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildCategoryList(
                            incomeCategories,
                            'income',
                            context,
                            ref,
                          ),
                          _buildCategoryList(
                            expenseCategories,
                            'expense',
                            context,
                            ref,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryList(
    List<CategoryItem> categories,
    String type,
    BuildContext context,
    WidgetRef ref,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: category.color.withValues(alpha: 0.2),
              child: Icon(category.icon, color: category.color),
            ),
            title: Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              category.description,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            trailing: category.isDefault
                ? null // No menu for default categories
                : PopupMenuButton<String>(
                    onSelected: (value) => _handleCategoryAction(
                      value,
                      category,
                      type,
                      context,
                      ref,
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.edit),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.delete),
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
    BuildContext context,
    WidgetRef ref,
  ) {
    switch (action) {
      case 'edit':
        _showEditCategoryDialog(category, type, context, ref);
        break;
      case 'delete':
        _showDeleteCategoryDialog(category, type, context, ref);
        break;
    }
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
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
                context,
                ref,
              ),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveNewCategory(
    String title,
    String description,
    String type,
    GlobalKey<FormState> formKey,
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      // Get current user ID
      final userId = UserService.instance.getUserId();
      if (userId == null || userId.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.noUserLoggedIn)));
        }
        return;
      }

      // Create category via service (offline-first)
      // Service saves locally first, then syncs to backend asynchronously
      await CategoryService.instance.createCategory(
        name: title.trim(),
        description: description.trim(),
        icon: Icons.category,
        color: type == 'Income' ? Colors.green : Colors.blue,
        categoryType: type.toLowerCase(),
        createdBy: userId,
      );

      // Close dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Invalidate the appropriate provider to refresh data
      if (type == 'Income') {
        ref.invalidate(incomeCategoriesProvider);
      } else {
        ref.invalidate(expenseCategoriesProvider);
      }

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.categoryAdded(title.trim())),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToLoadCategories(e.toString())),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showEditCategoryDialog(
    CategoryItem category,
    String type,
    BuildContext context,
    WidgetRef ref,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.editCategoryComingSoon(category.name),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteCategoryDialog(
    CategoryItem category,
    String type,
    BuildContext context,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteCategory),
        content: Text(
          AppLocalizations.of(
            context,
          )!.deleteCategoryConfirmation(category.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(
                      context,
                    )!.deleteCategoryComingSoon(category.name),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }
}
