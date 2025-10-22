import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../models/category_item.dart';
import '../../providers/category_providers.dart';
import '../../services/category_service.dart';

class EditCategoryScreen extends ConsumerStatefulWidget {
  final CategoryItem category;
  final String categoryType; // 'income' or 'expense'

  const EditCategoryScreen({
    super.key,
    required this.category,
    required this.categoryType,
  });

  @override
  ConsumerState<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends ConsumerState<EditCategoryScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.category.name);
    _descriptionController = TextEditingController(
      text: widget.category.description,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editCategory),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Title Input
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.categoryTitle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.categoryDescription,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterDescription;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _updateCategory,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              l10n.save,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateCategory() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Update category via service (offline-first)
      await CategoryService.instance.updateCategory(
        widget.category.id,
        name: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      // Invalidate the appropriate provider to refresh data
      if (widget.categoryType == 'income') {
        ref.invalidate(incomeCategoriesProvider);
      } else {
        ref.invalidate(expenseCategoriesProvider);
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Category \'${_titleController.text.trim()}\' updated successfully',
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        // Pop back to category screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToLoadCategories(e.toString())),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
