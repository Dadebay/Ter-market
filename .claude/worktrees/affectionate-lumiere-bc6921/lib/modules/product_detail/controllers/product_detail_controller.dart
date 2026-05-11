import 'package:get/get.dart';

class ProductDetailController extends GetxController {
  // Current image index for carousel
  var selectedImage = 0.obs;
  
  // Product quantity
  var quantity = 1.obs;

  void changeImage(int index) {
    selectedImage.value = index;
  }

  void increment() {
    quantity.value++;
  }

  void decrement() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }
}
