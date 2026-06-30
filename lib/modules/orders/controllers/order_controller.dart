import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:atlas/core/api/api_service.dart';
import 'package:atlas/models/order_model.dart';

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
          return OrderItemRequest(
            product: productId is int ? productId : int.tryParse(productId.toString()) ?? 0,
            quantity: item['quantity'] as int? ?? 1,
          );
        }).toList(),
      );
      print('┌─── PLACE ORDER REQUEST ────────────────────────');
      print('│ deviceId       : $deviceId');
      print('│ phoneNumber    : $phoneNumber');
      print('│ address        : $address');
      print('│ paymentStatus  : $paymentStatus');
      print('│ deliveryTypeId : $deliveryTypeId');
      print('│ deliveryTimeId : $deliveryTimeId  <-- null = express');
      print('│ regionId       : $regionId');
      print('│ isExpress      : $isExpress');
      print('│ deliveryDate   : $deliveryDate');
      print('│ items          : ${cartItems.map((e) => "id=${e['id']} qty=${e['quantity']}").join(", ")}');
      print('│ request toJson : ${request.toJson()}');
      print('└────────────────────────────────────────────────');

      final order = await _api.createOrder(request);
      final itemsTotal = order.items.fold(0.0, (s, i) => s + i.cost);
      final deliveryFee = isExpress ? (order.regionDetail?.exPrice ?? 0.0) : (order.regionDetail?.price ?? 0.0);
      final calculatedTotal = itemsTotal + deliveryFee;
      print('┌─── PLACE ORDER RESPONSE ───────────────────────');
      print('│ order id            : ${order.id}');
      print('│ order orderNumber   : ${order.orderNumber}');
      print('│ order is_express    : ${order.isExpress}');
      print('│ order isExpressDelivery (inferred): ${order.isExpressDelivery}');
      print('│ order deliveryType  : ${order.deliveryTypeDetail?.titleTk}');
      print('│ order deliveryTime  : ${order.deliveryTimeDetail?.displayTime}');
      print('│ order region        : ${order.regionDetail?.name}');
      print('│ order region.price  : ${order.regionDetail?.price}');
      print('│ order region.exPrice: ${order.regionDetail?.exPrice}');
      print('│ order status        : ${order.orderStatus}');
      print('│ --- TOTALS ---');
      print('│ backend total_price : ${order.totalPrice}');
      print('│ items cost sum      : $itemsTotal');
      print('│ delivery fee used   : $deliveryFee  (isExpress=$isExpress)');
      print('│ calculated total    : $calculatedTotal');
      print('│ displayTotal getter : ${order.displayTotal}');
      print('└────────────────────────────────────────────────');
      orders.insert(0, order);
      return true;
    } catch (e, st) {
      print('┌─── CREATE ORDER ERROR ────────────────────────');
      print('│ type: ${e.runtimeType}');
      print('│ error: $e');
      if (e is DioException) {
        print('│ DioException type: ${e.type}');
        print('│ status: ${e.response?.statusCode}');
        print('│ response data: ${e.response?.data}');
        print('│ request path: ${e.requestOptions.path}');
        print('│ request body: ${e.requestOptions.data}');
        print('│ message: ${e.message}');
      }
      print('│ stackTrace: $st');
      print('└───────────────────────────────────────────────');
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
      // ignore: avoid_print
      print('\x1B[35m┌─── PAYMENT URL ───────────────────────────────\x1B[0m');
      // ignore: avoid_print
      print('\x1B[35m│ url    : $url\x1B[0m');
      // ignore: avoid_print
      print('\x1B[35m│ bank   : ${selectedBank.value?.nameKey}\x1B[0m');
      // ignore: avoid_print
      print('\x1B[35m└───────────────────────────────────────────────\x1B[0m');
      return url;
    } catch (e) {
      // ignore: avoid_print
      print('\x1B[31m┌─── PAYMENT URL ERROR ─────────────────────────\x1B[0m');
      // ignore: avoid_print
      print('\x1B[31m│ $e\x1B[0m');
      // ignore: avoid_print
      print('\x1B[31m└───────────────────────────────────────────────\x1B[0m');
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
