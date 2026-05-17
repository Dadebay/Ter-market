import 'package:dio/dio.dart';
import 'package:atlas/core/api/api_client.dart';
import 'package:atlas/models/banner_model.dart';
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
    return list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
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
    double? discount,
    String? search,
    String? ordering,
    int? limit,
    int? offset,
  }) async {
    final Map<String, dynamic> params = {};
    if (categoryId != null) params['category'] = categoryId;
    if (subCategoryId != null) params['sub_category'] = subCategoryId;
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
    await _dio.post(
      'addFavourites/',
      data: FormData.fromMap({'device_id': deviceId, 'product_id': productId}),
    );
  }

  Future<void> removeFavourite(String deviceId, int productId) async {
    await _dio.delete(
      'removeFavourites/',
      data: FormData.fromMap({'device_id': deviceId, 'product_id': productId}),
    );
  }

  /// Returns a list of ProductModel. Handles both:
  ///  - current backend: `product` is an int (product ID)
  ///  - future backend:  `product` is a full product object
  Future<List<ProductModel>> getFavourites(String deviceId) async {
    final response = await _dio.get(
      'getFavourites/',
      queryParameters: {'device_id': deviceId},
    );
    final list = _extractList(response.data);
    final products = <ProductModel>[];
    for (final item in list) {
      final raw = (item as Map<String, dynamic>)['product'];
      if (raw is Map<String, dynamic>) {
        // Backend already returns full model
        products.add(ProductModel.fromJson(raw));
      } else if (raw is int) {
        // Backend returns only ID — fetch product detail
        try {
          final product = await getProductById(raw);
          products.add(product);
        } catch (_) {}
      }
    }
    return products;
  }

  // ─── Device ─────────────────────────────────────────────────────────────────
  Future<void> registerDevice(String deviceId) async {
    await _dio.post(
      'device/',
      data: FormData.fromMap({'device_id': deviceId}),
    );
  }

  // ─── Orders ─────────────────────────────────────────────────────────────────
  Future<List<OrderModel>> getMyOrders(String deviceId) async {
    final response = await _dio.get(
      'orders/',
      queryParameters: {'device_id': deviceId},
    );
    final list = _extractList(response.data);
    return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<OrderModel> createOrder(CreateOrderRequest request) async {
    final response = await _dio.post('orders/', data: request.toJson());
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
