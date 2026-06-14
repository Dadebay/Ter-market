import 'package:get/get.dart';
import 'package:atlas/core/api/api_service.dart';
import 'package:atlas/models/category_model.dart';

class CategoryController extends GetxController {
  final _api = ApiService();

  var categories = <CategoryModel>[].obs;
  var allSubCategories = <SubCategoryModel>[].obs; // flat cache for search
  var isLoading = true.obs;
  var hasError = false.obs;

  // Accordion state
  var expandedIds = <int>[].obs;
  var subCategoriesMap = <int, List<SubCategoryModel>>{}.obs;
  var loadingSubCatIds = <int>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      // Fetch categories AND all subcategories in parallel for instant cache
      final results = await Future.wait([
        _api.getCategories(),
        _api.getSubCategories(),
      ]);
      final cats = results[0] as List<CategoryModel>;
      cats.sort((a, b) => a.order != b.order ? a.order.compareTo(b.order) : a.id.compareTo(b.id));
      categories.value = cats;

      final subs = results[1] as List<SubCategoryModel>;
      subs.sort((a, b) => a.order != b.order ? a.order.compareTo(b.order) : a.id.compareTo(b.id));
      allSubCategories.value = subs;
      // Pre-build subCategoriesMap from cache (already sorted)
      final map = <int, List<SubCategoryModel>>{};
      for (final sub in subs) {
        (map[sub.categoryId] ??= []).add(sub);
      }
      subCategoriesMap.value = map;
      subCategoriesMap.refresh();
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleCategory(int categoryId) async {
    if (expandedIds.contains(categoryId)) {
      expandedIds.remove(categoryId);
      return;
    }
    expandedIds.add(categoryId);
    // Already pre-cached on startup — expand instantly
    if (subCategoriesMap.containsKey(categoryId)) return;

    // Fallback: fetch individually if somehow not in cache
    loadingSubCatIds.add(categoryId);
    try {
      final subs = await _api.getSubCategories(categoryId: categoryId);
      subCategoriesMap[categoryId] = subs;
      subCategoriesMap.refresh();
      final existingIds = allSubCategories.map((s) => s.id).toSet();
      allSubCategories.addAll(subs.where((s) => !existingIds.contains(s.id)));
    } catch (_) {
      subCategoriesMap[categoryId] = [];
      subCategoriesMap.refresh();
    } finally {
      loadingSubCatIds.remove(categoryId);
    }
  }
}
