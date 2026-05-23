import 'package:dio/dio.dart';
import 'package:atlas/core/api/api_client.dart';
import 'package:atlas/models/banner_model.dart';
import 'package:atlas/models/brand_model.dart';
import 'package:atlas/models/category_model.dart';
import 'package:atlas/models/product_model.dart';
import 'package:atlas/models/order_model.dart';

class ApiService {
  final Dio _dio = ApiClient.instance;

  // ─── Banners ────────────────────────────────────────────────────────────────
  Future<List<BannerModel>> getBanners() async {
    final response = await _dio.get('banners/');
    print('[ApiService] getBanners raw: ${response.data}');
    final list = _extractList(response.data);
    print('[ApiService] getBanners list length: ${list.length}');
    return list.map((e) => BannerModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ─── Categories ─────────────────────────────────────────────────────────────
  Future<List<CategoryModel>> getCategories() async {
    final response = await _dio.get('categories/');
    final list = _extractList(response.data);
    return list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList().reversed.toList();
  }

  Future<List<BrandModel>> getBrands() async {
    final response = await _dio.get('brends/');
    final list = _extractList(response.data);
    return list.map((e) => BrandModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CategoryModel> getCategoryById(int id) async {
    final response = await _dio.get('categories/$id/');
    return CategoryModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ─── SubCategories ──────────────────────────────────────────────────────────
  Future<List<SubCategoryModel>> getSubCategories({int? categoryId}) async {
    final Map<String, dynamic> params = {};
    if (categoryId != null) params['category'] = categoryId;
    final response = await _dio.get('subcategories/', queryParameters: params);
    final list = _extractList(response.data);
    return list.map((e) => SubCategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ─── Products ───────────────────────────────────────────────────────────────
  Future<PaginatedProducts> getProducts({
    int? categoryId,
    int? subCategoryId,
    int? brandId,
    double? discount,
    String? search,
    String? ordering,
    int? limit,
    int? offset,
  }) async {
    final Map<String, dynamic> params = {};
    if (categoryId != null) params['category'] = categoryId;
    if (subCategoryId != null) params['sub_category'] = subCategoryId;
    if (brandId != null) params['brends'] = brandId;
    if (discount != null) params['skidka'] = discount;
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (ordering != null) params['ordering'] = ordering;
    if (limit != null) params['limit'] = limit;
    if (offset != null) params['offset'] = offset;

    final response = await _dio.get('products/', queryParameters: params);
    if (response.data is List) {
      return PaginatedProducts(
        count: (response.data as List).length,
        results: (response.data as List).map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList(),
      );
    }
    return PaginatedProducts.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProductModel> getProductById(int id) async {
    final response = await _dio.get('products/$id/');
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ─── About ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getAboutContent() async {
    final response = await _dio.get('about/');
    final list = _extractList(response.data);
    if (list.isNotEmpty) return list.first as Map<String, dynamic>;
    return {};
  }

  // ─── Privacy / Terms ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getPrivacyContent() async {
    final response = await _dio.get('privacy/');
    final list = _extractList(response.data);
    if (list.isNotEmpty) return list.first as Map<String, dynamic>;
    return {};
  }

  // ─── FCM ────────────────────────────────────────────────────────────────────
  Future<void> registerFcmToken(String token) async {
    await _dio.post(
      'fcm/',
      data: FormData.fromMap({'fcm': token}),
    );
  }

  // ─── Favourites ─────────────────────────────────────────────────────────────
  Future<void> addFavourite(String deviceId, int productId) async {
    print('[API] addFavourite - deviceId: $deviceId, productId: $productId');
    try {
      final response = await _dio.post(
        'addFavourites/',
        data: FormData.fromMap({'device_id': deviceId, 'product_id': productId}),
      );
      print('[API] addFavourite SUCCESS - status: ${response.statusCode}, data: ${response.data}');
    } catch (e) {
      print('[API] addFavourite FAILED - error: $e');
      rethrow;
    }
  }

  Future<void> removeFavourite(String deviceId, int productId) async {
    print('[API] removeFavourite - deviceId: $deviceId, productId: $productId');
    try {
      final response = await _dio.delete(
        'removeFavourites/',
        data: FormData.fromMap({'device_id': deviceId, 'product_id': productId}),
      );
      print('[API] removeFavourite SUCCESS - status: ${response.statusCode}, data: ${response.data}');
    } catch (e) {
      print('[API] removeFavourite FAILED - error: $e');
      rethrow;
    }
  }

  /// Returns a list of ProductModel. Handles three backend response formats:
  ///  1. Direct product objects (new format): [{id: 123, name_tk: "...", ...}]
  ///  2. Nested with product object: [{product: {id: 123, name_tk: "...", ...}}]
  ///  3. Nested with product ID: [{product: 123}]
  Future<List<ProductModel>> getFavourites(String deviceId) async {
    print('[API] getFavourites - deviceId: $deviceId');
    try {
      final response = await _dio.get(
        'getFavourites/',
        queryParameters: {'device_id': deviceId},
      );
      print('[API] getFavourites response - status: ${response.statusCode}');
      print('[API] getFavourites response data: ${response.data}');
      final list = _extractList(response.data);
      print('[API] getFavourites - found ${list.length} items');
      final products = <ProductModel>[];

      for (final item in list) {
        final itemMap = item as Map<String, dynamic>;

        // Check if 'product' field exists
        if (itemMap.containsKey('product')) {
          final raw = itemMap['product'];
          print('[API] Processing favourite with product field - type: ${raw.runtimeType}, value: $raw');

          if (raw is Map<String, dynamic>) {
            // Format 2: Backend returns full product in 'product' field
            products.add(ProductModel.fromJson(raw));
            print('[API] Added product from nested object: ${raw['id']}');
          } else if (raw is int) {
            // Format 3: Backend returns only product ID
            try {
              print('[API] Fetching product details for ID: $raw');
              final product = await getProductById(raw);
              products.add(product);
              print('[API] Added product from ID: ${product.id}');
            } catch (e) {
              print('[API] Failed to fetch product $raw: $e');
            }
          }
        } else if (itemMap.containsKey('id') && itemMap.containsKey('name_tk')) {
          // Format 1: Backend returns product directly (no 'product' wrapper)
          print('[API] Processing direct product object - id: ${itemMap['id']}');
          try {
            products.add(ProductModel.fromJson(itemMap));
            print('[API] Added direct product: ${itemMap['id']}');
          } catch (e) {
            print('[API] Failed to parse direct product: $e');
          }
        } else {
          print('[API] Unknown favourite format, skipping item: $itemMap');
        }
      }

      print('[API] getFavourites - returning ${products.length} products');
      return products;
    } catch (e) {
      print('[API] getFavourites FAILED - error: $e');
      rethrow;
    }
  }

  // ─── Device ─────────────────────────────────────────────────────────────────
  Future<void> registerDevice(String deviceId) async {
    await _dio.post(
      'device/',
      data: FormData.fromMap({'device_id': deviceId}),
    );
  }

  // ─── Dialogs ─────────────────────────────────────────────────────────────────
  Future<List<DialogNoticeModel>> getDialogs() async {
    final response = await _dio.get('dialogs/');
    final list = _extractList(response.data);
    return list.map((e) => DialogNoticeModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ─── Orders ─────────────────────────────────────────────────────────────────
  Future<List<PaymentMethod>> getPaymentMethods() async {
    final response = await _dio.get('payments/');
    final list = _extractList(response.data);
    return list.map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<DeliveryType>> getDeliveryTypes() async {
    final response = await _dio.get('deliverytypes/');
    final list = _extractList(response.data);
    return list.map((e) => DeliveryType.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<DeliveryTime>> getDeliveryTimes() async {
    final response = await _dio.get('deliverytimes/');
    final list = _extractList(response.data);
    return list.map((e) => DeliveryTime.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<RegionModel>> getRegions() async {
    final response = await _dio.get('regions/');
    final list = _extractList(response.data);
    return list.map((e) => RegionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<OrderModel>> getMyOrders(String deviceId) async {
    final response = await _dio.get(
      'orders/',
      queryParameters: {'device_id': deviceId},
    );
    final list = _extractList(response.data);
    return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<OrderModel> createOrder(CreateOrderRequest request) async {
    final body = request.toJson();
    print('┌─── CREATE ORDER REQUEST ──────────────────────');
    print('│ POST orders/');
    print('│ Body: $body');
    print('└───────────────────────────────────────────────');
    final response = await _dio.post('orders/', data: body);
    print('┌─── CREATE ORDER RESPONSE ─────────────────────');
    print('│ Status: ${response.statusCode}');
    print('│ Body:   ${response.data}');
    print('└───────────────────────────────────────────────');
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────
  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data.containsKey('results')) {
      return data['results'] as List<dynamic>;
    }
    return [];
  }
}
