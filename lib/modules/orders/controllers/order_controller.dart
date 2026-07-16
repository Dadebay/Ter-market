import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:atlas/core/api/api_service.dart';
import 'package:atlas/models/order_model.dart';
import 'package:atlas/utils/order_log.dart';

class OrderController extends GetxController {
  final _api = ApiService();
  final _storage = GetStorage();

  var orders = <OrderModel>[].obs;
  var isLoading = false.obs;
  var isPlacingOrder = false.obs;
  var hasError = false.obs;

  var paymentMethods = <PaymentMethod>[].obs;
  var isLoadingPayments = false.obs;

  var deliveryTypes = <DeliveryType>[].obs;
  var isLoadingDeliveryTypes = false.obs;

  var deliveryTimes = <DeliveryTime>[].obs;
  var isLoadingDeliveryTimes = false.obs;

  var dialogNotices = <DialogNoticeModel>[].obs;
  var isLoadingDialogs = false.obs;

  var regions = <RegionModel>[].obs;
  var isLoadingRegions = false.obs;

  var selectedBank = Rx<BankOption?>(null);
  var isInitiatingPayment = false.obs;
  var lastCreatedOrderId = Rx<int?>(null);
  var isCancellingOrder = false.obs;

  String get deviceId {
    var id = _storage.read<String>('device_id');
    if (id == null) {
      id = 'atlas-${DateTime.now().millisecondsSinceEpoch}';
      _storage.write('device_id', id);
    }
    return id;
  }

  @override
  void onInit() {
    super.onInit();
    fetchMyOrders();
    fetchPaymentMethods();
    fetchDeliveryTypes();
    fetchDeliveryTimes();
    fetchDialogs();
    fetchRegions();
  }

  Future<void> fetchDialogs() async {
    isLoadingDialogs.value = true;
    try {
      dialogNotices.value = await _api.getDialogs();
    } catch (_) {
      // silently fail
    } finally {
      isLoadingDialogs.value = false;
    }
  }

  Future<void> fetchPaymentMethods() async {
    isLoadingPayments.value = true;
    try {
      paymentMethods.value = await _api.getPaymentMethods();
    } catch (_) {
      // silently fail - will retry when order screen opens
    } finally {
      isLoadingPayments.value = false;
    }
  }

  Future<void> fetchDeliveryTypes() async {
    isLoadingDeliveryTypes.value = true;
    try {
      deliveryTypes.value = await _api.getDeliveryTypes();
    } catch (_) {
      // silently fail
    } finally {
      isLoadingDeliveryTypes.value = false;
    }
  }

  Future<void> fetchDeliveryTimes() async {
    isLoadingDeliveryTimes.value = true;
    try {
      deliveryTimes.value = await _api.getDeliveryTimes();
    } catch (_) {
      // silently fail
    } finally {
      isLoadingDeliveryTimes.value = false;
    }
  }

  Future<void> fetchRegions() async {
    isLoadingRegions.value = true;
    try {
      regions.value = await _api.getRegions();
    } catch (_) {
      // silently fail
    } finally {
      isLoadingRegions.value = false;
    }
  }

  Future<void> fetchMyOrders() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      orders.value = await _api.getMyOrders(deviceId);
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> placeOrder({
    required String phoneNumber,
    required String address,
    required String paymentStatus,
    int? deliveryTypeId,
    int? deliveryTimeId,
    int? regionId,
    bool isExpress = false,
    String? deliveryDate,
    required List<Map<String, dynamic>> cartItems,
  }) async {
    isPlacingOrder.value = true;
    OrderLog.step('placeOrder() called');
    OrderLog.info('deviceId=$deviceId phone=$phoneNumber address="$address"');
    OrderLog.info('payment=$paymentStatus deliveryTypeId=$deliveryTypeId '
        'deliveryTimeId=$deliveryTimeId regionId=$regionId '
        'isExpress=$isExpress deliveryDate=$deliveryDate');
    OrderLog.info('cartItems=${cartItems.map((e) => "id=${e['id']} qty=${e['quantity']}").join(", ")}');
    try {
      final request = CreateOrderRequest(
        deviceId: deviceId,
        phoneNumber: phoneNumber,
        address: address,
        paymentStatus: paymentStatus,
        deliveryTypeId: deliveryTypeId,
        deliveryTimeId: deliveryTimeId,
        regionId: regionId,
        isExpress: isExpress,
        deliveryDate: deliveryDate,
        items: cartItems.map((item) {
          final productId = item['id'];
          final parsedId = productId is int ? productId : int.tryParse(productId.toString()) ?? 0;
          if (parsedId == 0) {
            OrderLog.warn('cart item has invalid/zero product id: raw="$productId" item=$item');
          }
          return OrderItemRequest(
            product: parsedId,
            quantity: item['quantity'] as int? ?? 1,
          );
        }).toList(),
      );

      final order = await _api.createOrder(request);
      orders.insert(0, order);
      OrderLog.success('placeOrder OK — order id=${order.id} number=${order.orderNumber}');
      return true;
    } on DioException catch (e, st) {
      OrderLog.error('placeOrder DioException type=${e.type} '
          'status=${e.response?.statusCode} data=${e.response?.data} '
          'message=${e.message}');
      OrderLog.error('request path=${e.requestOptions.path} body=${e.requestOptions.data}');
      OrderLog.error('stack: $st');
      return false;
    } catch (e, st) {
      OrderLog.error('placeOrder unexpected ${e.runtimeType}: $e');
      OrderLog.error('stack: $st');
      return false;
    } finally {
      isPlacingOrder.value = false;
    }
  }

  Future<bool> cancelOrder(int orderId) async {
    isCancellingOrder.value = true;
    try {
      await _api.cancelOrder(orderId, deviceId);
      await fetchMyOrders();
      return true;
    } catch (e) {
      return false;
    } finally {
      isCancellingOrder.value = false;
    }
  }

  // Returns the payment URL without launching it, so the caller controls the dialog lifecycle.
  Future<String?> fetchPaymentUrl(int orderId) async {
    if (selectedBank.value == null) return null;
    isInitiatingPayment.value = true;
    try {
      final url = await _api.initiateOnlinePayment(
        orderId: orderId,
        bankId: selectedBank.value!.id,
      );
      return url;
    } catch (e) {
      return null;
    } finally {
      isInitiatingPayment.value = false;
    }
  }

  Future<void> initiateOnlinePayment(int orderId) async {
    final url = await fetchPaymentUrl(orderId);
    if (url != null && url.isNotEmpty) {
      final mode = Platform.isIOS ? LaunchMode.inAppWebView : LaunchMode.inAppBrowserView;
      await launchUrlString(url, mode: mode);
    } else {
      Get.snackbar('error'.tr, 'payment_url_error'.tr,
          backgroundColor: const Color(0xFFFFEBEE),
          colorText: const Color(0xFFD32F2F),
          snackPosition: SnackPosition.TOP);
    }
  }
}
