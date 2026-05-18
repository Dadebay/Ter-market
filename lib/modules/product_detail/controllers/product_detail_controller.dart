import 'package:get/get.dart';
import 'package:atlas/core/api/api_service.dart';
import 'package:atlas/models/product_model.dart';

class ProductDetailController extends GetxController {
  final _api = ApiService();

  // Current image index for carousel
  var selectedImage = 0.obs;

  // Loaded product
  var product = Rxn<ProductModel>();
  var isLoading = true.obs;
  var hasError = false.obs;

  void changeImage(int index) {
    selectedImage.value = index;
  }

  Future<void> loadProduct(int id) async {
    isLoading.value = true;
    hasError.value = false;
    selectedImage.value = 0;
    try {
      product.value = await _api.getProductById(id);
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}
