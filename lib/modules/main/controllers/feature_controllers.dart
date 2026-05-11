import 'dart:ui';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CartController extends GetxController {
  // Cart items logic with quantity
  var cartItems = <Map<String, dynamic>>[].obs;

  void addItem(Map<String, dynamic> item, {int initialQuantity = 1}) {
    // Check if item already exists in cart (using title as simple ID for mock)
    int existingIndex =
        cartItems.indexWhere((element) => element['title'] == item['title']);

    if (existingIndex != -1) {
      // Add to existing quantity
      var existingItem = Map<String, dynamic>.from(cartItems[existingIndex]);
      existingItem['quantity'] =
          (existingItem['quantity'] ?? 1) + initialQuantity;
      cartItems[existingIndex] = existingItem;
    } else {
      // Add new item with specified quantity
      var newItem = Map<String, dynamic>.from(item);
      newItem['quantity'] = initialQuantity;
      cartItems.add(newItem);
    }
  }

  void updateQuantity(int index, int delta) {
    if (index >= 0 && index < cartItems.length) {
      var item = Map<String, dynamic>.from(cartItems[index]);
      int newQuantity = (item['quantity'] ?? 1) + delta;
      if (newQuantity > 0) {
        item['quantity'] = newQuantity;
        cartItems[index] = item;
      } else {
        // Option to remove if quantity becomes 0
        removeItem(index);
      }
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < cartItems.length) {
      cartItems.removeAt(index);
    }
  }

  void clearCart() {
    cartItems.clear();
  }

  double get totalPrice => cartItems.fold(0.0, (sum, item) {
        double price = (item['price'] is int)
            ? (item['price'] as int).toDouble()
            : (item['price'] as double);
        int quantity = item['quantity'] ?? 1;
        return sum + (price * quantity);
      });
}

class FavoritesController extends GetxController {
  // Mock favorites logic
  var favoriteItems = <Map<String, dynamic>>[].obs;

  bool isFavorited(dynamic id, dynamic title) {
    if (id != null) {
      return favoriteItems.any((item) => item['id'] == id);
    }
    return favoriteItems.any((item) => item['title'] == title);
  }

  void toggleFavorite(Map<String, dynamic> item) {
    int existingIndex = -1;
    if (item['id'] != null) {
      existingIndex =
          favoriteItems.indexWhere((element) => element['id'] == item['id']);
    } else {
      existingIndex = favoriteItems
          .indexWhere((element) => element['title'] == item['title']);
    }

    if (existingIndex != -1) {
      favoriteItems.removeAt(existingIndex);
    } else {
      favoriteItems.add(item);
    }
  }
}

class ProfileController extends GetxController {
  // Mock profile info
  var userName = "Myrat Myradow".obs;
  var userPhone = "+993 61 234567".obs;

  // Language state
  var currentLanguage = 'tk'.obs;

  @override
  void onInit() {
    super.onInit();
    final storage = Get.find<GetStorage>();
    currentLanguage.value = storage.read('langCode') ?? 'tk';
  }

  void changeLanguage(String langCode) {
    Get.updateLocale(Locale(langCode));
    currentLanguage.value = langCode;
    Get.find<GetStorage>().write('langCode', langCode);
  }
}
