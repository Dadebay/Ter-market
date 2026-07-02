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
      final response = await _dio.post(
        'v2/login/',
        data: FormData.fromMap({'username': username, 'password': password}),
      );
      final data = response.data;
      final access = data['access'] as String?;
      final refresh = data['refresh'] as String?;
      if (access == null || refresh == null) {
        throw AdminAuthException('Ulanyjy ady ýa-da parol nädogry');
      }
      await _saveTokens(access: access, refresh: refresh);
    } on DioException catch (e) {
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

  // POST /api/foradmin/ with device_id (and optional fcm_token)
  Future<void> registerAdminDevice(String deviceId, {String? fcmToken}) async {
    try {
      final fields = <String, dynamic>{'device_id': deviceId};
      if (fcmToken != null && fcmToken.isNotEmpty) {
        fields['fcm_token'] = fcmToken;
      }
      await _dio.post(
        'api/foradmin/',
        data: FormData.fromMap(fields),
      );
      print('[AdminApi] registerAdminDevice success: $deviceId');
    } catch (e) {
      print('[AdminApi] registerAdminDevice error: $e');
      rethrow;
    }
  }

  // GET /v2/orders/
  Future<List<Map<String, dynamic>>> getAllOrders({int page = 1}) async {
    try {
      final response = await _dio.get(
        'v2/orders/',
        queryParameters: {'page': page},
      );
      final data = response.data;
      if (data is Map && data.containsKey('results')) {
        return List<Map<String, dynamic>>.from(data['results'] as List);
      }
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print('[AdminApi] getAllOrders error: $e');
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
