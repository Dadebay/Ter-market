import 'package:dio/dio.dart';

class AdminApiService {
  static const String _baseUrl = 'https://termarket.com.tm/';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

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
