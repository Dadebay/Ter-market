import 'package:get/get.dart';
import 'package:atlas/core/api/api_service.dart';
import 'package:atlas/models/category_model.dart';

class CategoryController extends GetxController {
  final _api = ApiService();

  var categories = <CategoryModel>[].obs;
  var subCategories = <SubCategoryModel>[].obs;
  var isLoading = true.obs;
  var isSubLoading = false.obs;
  var hasError = false.obs;

  var selectedCategoryId = Rxn<int>();

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
      if (categories.isNotEmpty) {
        selectCategory(categories.first.id);
      }
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectCategory(int id) async {
    selectedCategoryId.value = id;
    isSubLoading.value = true;
    try {
      subCategories.value = await _api.getSubCategories(categoryId: id);
    } catch (_) {
      subCategories.clear();
    } finally {
      isSubLoading.value = false;
    }
  }
}
