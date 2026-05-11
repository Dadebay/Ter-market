import 'package:get/get.dart';
import 'package:atlas/core/api/api_service.dart';
import 'package:atlas/models/product_model.dart';

class ProductController extends GetxController {
  final _api = ApiService();

  var discountedProducts = <ProductModel>[].obs;
  var newProducts = <ProductModel>[].obs;
  var listProducts = <ProductModel>[].obs;

  var isLoadingDiscounted = true.obs;
  var isLoadingNew = true.obs;
  var isLoadingList = true.obs;

  var hasErrorDiscounted = false.obs;
  var hasErrorNew = false.obs;
  var hasErrorList = false.obs;

  var searchQuery = ''.obs;
  var selectedCategoryId = Rxn<int>();
  var selectedSubCategoryId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    fetchDiscountedProducts();
    fetchNewProducts();
  }

  Future<void> fetchDiscountedProducts() async {
    isLoadingDiscounted.value = true;
    hasErrorDiscounted.value = false;
    try {
      final result = await _api.getProducts(ordering: '-price', limit: 10);
      discountedProducts.value = result.results;
    } catch (_) {
      hasErrorDiscounted.value = true;
    } finally {
      isLoadingDiscounted.value = false;
    }
  }

  Future<void> fetchNewProducts() async {
    isLoadingNew.value = true;
    hasErrorNew.value = false;
    try {
      final result = await _api.getProducts(ordering: '-created_at', limit: 10);
      newProducts.value = result.results;
    } catch (_) {
      hasErrorNew.value = true;
    } finally {
      isLoadingNew.value = false;
    }
  }

  Future<void> fetchProductList({
    int? categoryId,
    int? subCategoryId,
    String? search,
    String? ordering,
    int? limit,
    int? offset,
  }) async {
    isLoadingList.value = true;
    hasErrorList.value = false;
    try {
      final result = await _api.getProducts(
        categoryId: categoryId,
        subCategoryId: subCategoryId,
        search: search,
        ordering: ordering,
        limit: limit,
        offset: offset,
      );
      listProducts.value = result.results;
    } catch (_) {
      hasErrorList.value = true;
    } finally {
      isLoadingList.value = false;
    }
  }
}
