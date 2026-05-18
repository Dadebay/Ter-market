import 'package:get/get.dart';
import 'package:atlas/core/api/api_service.dart';
import 'package:atlas/models/category_model.dart';

class CategoryController extends GetxController {
  final _api = ApiService();

  var categories = <CategoryModel>[].obs;
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
      categories.value = await _api.getCategories();
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
    if (subCategoriesMap.containsKey(categoryId)) return;

    loadingSubCatIds.add(categoryId);
    try {
      final subs = await _api.getSubCategories(categoryId: categoryId);
      subCategoriesMap[categoryId] = subs;
      subCategoriesMap.refresh();
    } catch (_) {
      subCategoriesMap[categoryId] = [];
      subCategoriesMap.refresh();
    } finally {
      loadingSubCatIds.remove(categoryId);
    }
  }
}
