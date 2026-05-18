import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:atlas/core/api/api_service.dart';
import 'package:atlas/models/product_model.dart';
import 'package:atlas/widgets/app_dialogs.dart';

class CartController extends GetxController {
  // Cart items logic with quantity
  var cartItems = <Map<String, dynamic>>[].obs;

  void addItem(Map<String, dynamic> item, {int initialQuantity = 1}) {
    // Check if item already exists in cart (using title as simple ID for mock)
    int existingIndex = cartItems.indexWhere((element) => element['title'] == item['title']);

    if (existingIndex != -1) {
      // Add to existing quantity
      var existingItem = Map<String, dynamic>.from(cartItems[existingIndex]);
      existingItem['quantity'] = (existingItem['quantity'] ?? 1) + initialQuantity;
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
      AppDialogs.showRemovedFromCart();
    }
  }

  /// Returns the current cart quantity for the product, or 0 if not in cart.
  int getQuantity(dynamic id, String title) {
    final item = cartItems.firstWhereOrNull(
      (e) => (id != null && e['id']?.toString() == id.toString()) || e['title'] == title,
    );
    return item != null ? ((item['quantity'] as num?)?.toInt() ?? 1) : 0;
  }

  /// Adds item to cart if not present, otherwise increments quantity.
  void addOrIncrement(Map<String, dynamic> item) {
    final id = item['id'];
    final title = item['title'] as String? ?? '';
    int index = cartItems.indexWhere(
      (e) => (id != null && e['id']?.toString() == id.toString()) || e['title'] == title,
    );
    if (index != -1) {
      var existing = Map<String, dynamic>.from(cartItems[index]);
      existing['quantity'] = ((existing['quantity'] as num?)?.toInt() ?? 1) + 1;
      cartItems[index] = existing;
    } else {
      final newItem = Map<String, dynamic>.from(item);
      newItem['quantity'] = 1;
      cartItems.add(newItem);
      AppDialogs.showAddedToCart();
    }
  }

  /// Increments (+1) or decrements (-1) a cart item by product id/title.
  /// Removes item from cart if quantity drops to 0.
  void changeQuantityByProduct(dynamic id, String title, int delta) {
    int index = cartItems.indexWhere(
      (e) => (id != null && e['id']?.toString() == id.toString()) || e['title'] == title,
    );
    if (index == -1) return;
    var item = Map<String, dynamic>.from(cartItems[index]);
    int newQty = ((item['quantity'] as num?)?.toInt() ?? 1) + delta;
    if (newQty <= 0) {
      cartItems.removeAt(index);
      AppDialogs.showRemovedFromCart();
    } else {
      item['quantity'] = newQty;
      cartItems[index] = item;
    }
  }

  void clearCart() {
    cartItems.clear();
  }

  double get totalPrice => cartItems.fold(0.0, (sum, item) {
        double price = (item['price'] is int) ? (item['price'] as int).toDouble() : (item['price'] as double);
        int quantity = item['quantity'] ?? 1;
        return sum + (price * quantity);
      });
}

class FavoritesController extends GetxController {
  final _api = ApiService();

  var favoriteItems = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  String get _deviceId {
    final storage = Get.find<GetStorage>();
    var id = storage.read<String>('device_id');
    if (id == null) {
      id = 'atlas-${DateTime.now().millisecondsSinceEpoch}';
      storage.write('device_id', id);
    }
    return id;
  }

  @override
  void onInit() {
    super.onInit();
    fetchFavourites();
  }

  Future<void> fetchFavourites() async {
    isLoading.value = true;
    try {
      final products = await _api.getFavourites(_deviceId);
      favoriteItems.value = products.map(_toMap).toList();
    } catch (e) {
      print('[Favourites] Load failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool isFavorited(dynamic id, dynamic title) {
    final parsed = _toIntId(id);
    if (parsed != null) {
      return favoriteItems.any((item) => _toIntId(item['id']) == parsed);
    }
    return favoriteItems.any((item) => item['title'] == title);
  }

  Future<void> toggleFavorite(Map<String, dynamic> item) async {
    final rawId = item['id'];
    final productId = _toIntId(rawId);
    final existing = productId != null ? favoriteItems.indexWhere((e) => _toIntId(e['id']) == productId) : favoriteItems.indexWhere((e) => e['title'] == item['title']);

    if (existing != -1) {
      // Optimistic remove
      final removed = favoriteItems[existing];
      favoriteItems.removeAt(existing);
      AppDialogs.showRemovedFromFavorites();
      if (productId != null) {
        try {
          await _api.removeFavourite(_deviceId, productId);
        } catch (e) {
          // Roll back on failure
          favoriteItems.insert(existing, removed);
          if (e is DioException) {
            print('[Favourites] Remove failed: ${e.response?.statusCode} ${e.response?.data}');
          } else {
            print('[Favourites] Remove failed: $e');
          }
        }
      }
    } else {
      // Optimistic add
      favoriteItems.add(item);
      if (productId != null) {
        try {
          await _api.addFavourite(_deviceId, productId);
        } catch (e) {
          // Roll back on failure
          favoriteItems.removeWhere((e) => _toIntId(e['id']) == productId);
          if (e is DioException) {
            print('[Favourites] Add failed: ${e.response?.statusCode} ${e.response?.data}');
          } else {
            print('[Favourites] Add failed: $e');
          }
        }
      }
    }
  }

  int? _toIntId(dynamic id) {
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }

  Map<String, dynamic> _toMap(ProductModel p) => {
        'id': p.id,
        'title': p.name,
        'name_tk': p.nameTk,
        'name_ru': p.nameRu,
        'imageUrl': p.image ?? '',
        'price': p.price,
        'rating': p.rating,
      };
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
