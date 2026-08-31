import 'package:riverpod/riverpod.dart';
import '../models/category_item.dart';
import '../services/category_service.dart';

/// Provider for CategoryService singleton
final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService.instance;
});

/// Provider to fetch all categories
/// Usage: ref.watch(categoriesProvider)
final categoriesProvider = FutureProvider<List<CategoryItem>>((ref) async {
  final categoryService = ref.watch(categoryServiceProvider);
  return categoryService.getAllCategories();
});

/// Provider to fetch income categories
/// Usage: ref.watch(incomeCategoriesProvider)
final incomeCategoriesProvider = FutureProvider<List<CategoryItem>>((
  ref,
) async {
  final categoryService = ref.watch(categoryServiceProvider);
  return categoryService.getIncomeCategories();
});

/// Provider to fetch expense categories
/// Usage: ref.watch(expenseCategoriesProvider)
final expenseCategoriesProvider = FutureProvider<List<CategoryItem>>((
  ref,
) async {
  final categoryService = ref.watch(categoryServiceProvider);
  return categoryService.getExpenseCategories();
});
