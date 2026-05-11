import 'package:get/get.dart';
import 'package:atlas/core/api/api_service.dart';
import 'package:atlas/models/category_model.dart';

class CategoryController extends GetxController {
  final _api = ApiService();

  var categories = <CategoryModel>[].obs;
  var isLoading = true.obs;
  var hasError = false.obs;

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
}
