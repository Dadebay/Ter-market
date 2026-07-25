import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class AdminAuthException implements Exception {
  final String message;
  AdminAuthException(this.message);
  @override
  String toString() => message;
}

class AdminApiService {
  static const String _baseUrl = 'https://termarket.com.tm/';
  static const _accessKey = 'admin_access_token';
  static const _refreshKey = 'admin_refresh_token';

  static final GetStorage _storage = GetStorage();

  static Dio? _instance;

  Dio get _dio {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(_AdminAuthInterceptor(dio));
    return dio;
  }

  // ─── Auth ───────────────────────────────────────────────────────────────
  static String? get accessToken => _storage.read<String>(_accessKey);
  static String? get refreshToken => _storage.read<String>(_refreshKey);
  static bool get isLoggedIn => accessToken != null && accessToken!.isNotEmpty;

  static Future<void> _saveTokens({required String access, required String refresh}) async {
    await _storage.write(_accessKey, access);
    await _storage.write(_refreshKey, refresh);
  }

  static Future<void> logout() async {
    await _storage.remove(_accessKey);
    await _storage.remove(_refreshKey);
  }

  // POST /v2/login/ with username, password (multipart) → {access, refresh}
  Future<void> login(String username, String password) async {
    try {
      print('\x1B[36m[AdminApi] 📤 POST v2/login/ | user=$username\x1B[0m');
      final response = await _dio.post(
        'v2/login/',
        data: FormData.fromMap({'username': username, 'password': password}),
      );
      print('\x1B[32m[AdminApi] ✅ login response status=${response.statusCode} | keys=${response.data?.keys?.toList()}\x1B[0m');
      final data = response.data;
      final access = data['access'] as String?;
      final refresh = data['refresh'] as String?;
      if (access == null || refresh == null) {
        print('\x1B[31m[AdminApi] ❌ access veya refresh token null | data=$data\x1B[0m');
        throw AdminAuthException('Ulanyjy ady ýa-da parol nädogry');
      }
      await _saveTokens(access: access, refresh: refresh);
    } on DioException catch (e) {
      print('\x1B[31m[AdminApi] ❌ DioException login | status=${e.response?.statusCode} | data=${e.response?.data} | message=${e.message}\x1B[0m');
      if (e.response?.statusCode == 401 || e.response?.statusCode == 400) {
        throw AdminAuthException('Ulanyjy ady ýa-da parol nädogry');
      }
      throw AdminAuthException('Ulgama birikip bolmady');
    }
  }

  // POST /v2/refresh/ with refresh token (multipart) → {access}
  Future<String> refreshAccessToken() async {
    final refresh = refreshToken;
    if (refresh == null || refresh.isEmpty) {
      throw AdminAuthException('Refresh token ýok');
    }
    final response = await Dio(BaseOptions(baseUrl: _baseUrl)).post(
      'v2/refresh/',
      data: FormData.fromMap({'refresh': refresh}),
    );
    final newAccess = response.data['access'] as String?;
    if (newAccess == null) {
      throw AdminAuthException('Token täzelenip bilinmedi');
    }
    await _storage.write(_accessKey, newAccess);
    return newAccess;
  }

  // POST /api/foradmin/ with fcm_token
  Future<void> registerAdminDevice(String fcmToken) async {
    try {
      await _dio.post(
        'api/foradmin/',
        data: FormData.fromMap({'device_id': fcmToken}),
      );
      print('[AdminApi] registerAdminDevice success');
    } catch (e) {
      print('[AdminApi] registerAdminDevice error: $e');
      rethrow;
    }
  }

  // GET /v2/orderitems/?order_id=<id> — this endpoint uses limit/offset
  // pagination (not `page`), so subsequent pages must be fetched via the
  // exact `next` URL the API returns rather than an incrementing page number.
  Future<List<Map<String, dynamic>>> getOrderItems(int orderId) async {
    try {
      final items = <Map<String, dynamic>>[];
      var pageCount = 0;
      const maxPages = 15; // safety net in case the order_id filter ever breaks

      print('\x1B[36m[AdminApi] 📤 GET v2/orderitems/?order_id=$orderId\x1B[0m');

      var response = await _dio.get(
        'v2/orderitems/',
        queryParameters: {'order_id': orderId},
      );

      while (true) {
        pageCount++;
        print('\x1B[36m[AdminApi] 🔗 requested: ${response.requestOptions.uri}\x1B[0m');
        final data = response.data;

        List<dynamic> pageResults;
        String? next;
        if (data is List) {
          pageResults = data;
          next = null;
        } else if (data is Map && data.containsKey('results')) {
          pageResults = data['results'] as List;
          next = data['next'] as String?;
        } else {
          break;
        }

        items.addAll(List<Map<String, dynamic>>.from(pageResults));
        print('\x1B[32m[AdminApi] ✅ orderitems page=$pageCount | +${pageResults.length} | total=${items.length} | next=$next\x1B[0m');

        if (next == null || pageCount >= maxPages) break;
        response = await _dio.get(next); // absolute URL — dio uses it as-is instead of joining with baseUrl
      }

      return items;
    } catch (e) {
      print('[AdminApi] getOrderItems error: orderId=$orderId | $e');
      rethrow;
    }
  }

  // GET /v2/orders/
  Future<List<Map<String, dynamic>>> getAllOrders({int page = 1}) async {
    try {
      print('\x1B[36m[AdminApi] 📤 GET v2/orders/?page=$page | token=${accessToken?.substring(0, 20)}...\x1B[0m');
      final response = await _dio.get(
        'v2/orders/',
        queryParameters: {'page': page},
      );
      print('\x1B[32m[AdminApi] ✅ GET v2/orders/?page=$page | status=${response.statusCode} | type=${response.data.runtimeType}\x1B[0m');
      final data = response.data;
      if (data is Map) {
        print('\x1B[33m[AdminApi] 📦 response keys: ${data.keys.toList()}\x1B[0m');
        if (data.containsKey('results')) {
          final results = List<Map<String, dynamic>>.from(data['results'] as List);
          print('\x1B[32m[AdminApi] ✅ results count: ${results.length}\x1B[0m');
          if (results.isNotEmpty) {
            print('\x1B[35m[AdminApi] 🕒 first order raw json: ${results.first}\x1B[0m');
          }
          return results;
        }
      }
      if (data is List) {
        print('\x1B[32m[AdminApi] ✅ list count: ${data.length}\x1B[0m');
        return List<Map<String, dynamic>>.from(data);
      }
      print('\x1B[31m[AdminApi] ⚠️ unexpected response format: $data\x1B[0m');
      return [];
    } catch (e) {
      print('\x1B[31m[AdminApi] ❌ getAllOrders error: $e\x1B[0m');
      rethrow;
    }
  }
}

/// Attaches the access token to every request (except auth endpoints) and
/// transparently refreshes + retries once on a 401 response.
class _AdminAuthInterceptor extends Interceptor {
  final Dio _dio;
  _AdminAuthInterceptor(this._dio);

  bool _isAuthEndpoint(String path) => path.contains('v2/login') || path.contains('v2/refresh');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_isAuthEndpoint(options.path)) {
      final token = AdminApiService.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        print('\x1B[34m[AdminApi] 🔑 Bearer $token\x1B[0m');
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    if (err.response?.statusCode == 401 && !_isAuthEndpoint(options.path)) {
      try {
        final newAccess = await AdminApiService().refreshAccessToken();
        final retryOptions = Options(
          method: options.method,
          headers: {...options.headers, 'Authorization': 'Bearer $newAccess'},
        );
        final response = await _dio.request(
          options.path,
          data: options.data,
          queryParameters: options.queryParameters,
          options: retryOptions,
        );
        return handler.resolve(response);
      } catch (_) {
        await AdminApiService.logout();
      }
    }
    handler.next(err);
  }
}
