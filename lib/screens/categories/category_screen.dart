import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../models/category_item.dart';
import '../../providers/category_providers.dart';
import '../../services/category_service.dart';
import 'add_category_screen.dart';
import 'edit_category_screen.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  bool _isSyncing = false;

  Future<void> _handleSync() async {
    if (_isSyncing) return;

    setState(() => _isSyncing = true);

    try {
      // Fetch categories from backend
      await CategoryService.instance.fetchCategoriesFromBackend();

      // Refresh the providers
      // ignore: unused_result
      ref.refresh(incomeCategoriesProvider);
      // ignore: unused_result
      ref.refresh(expenseCategoriesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.syncCompleted),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.failedToSync(e.toString()),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final incomeCategoriesAsync = ref.watch(incomeCategoriesProvider);
    final expenseCategoriesAsync = ref.watch(expenseCategoriesProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categories),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          if (_isSyncing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: _handleSync,
              tooltip: l10n.syncCategories,
            ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddCategory(context),
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
              return SafeArea(
                child: DefaultTabController(
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

  void _navigateToAddCategory(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddCategoryScreen()));
  }

  void _showEditCategoryDialog(
    CategoryItem category,
    String type,
    BuildContext context,
    WidgetRef ref,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            EditCategoryScreen(category: category, categoryType: type),
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
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteCategory(category, type, context, ref);
            },
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(
    CategoryItem category,
    String type,
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      // Delete category via service (offline-first)
      await CategoryService.instance.deleteCategory(category.id);

      // Invalidate the appropriate provider to refresh data
      if (type == 'income') {
        ref.invalidate(incomeCategoriesProvider);
      } else {
        ref.invalidate(expenseCategoriesProvider);
      }

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category \'${category.name}\' deleted successfully'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToLoadCategories(e.toString())),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
