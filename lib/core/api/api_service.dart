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
        results: (response.data as List)
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    return PaginatedProducts.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProductModel> getProductById(int id) async {
    final response = await _dio.get('products/$id/');
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
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
