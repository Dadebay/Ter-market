import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
        items: cartItems.map((item) {
          final productId = item['id'];
          return OrderItemRequest(
            product: productId is int ? productId : int.tryParse(productId.toString()) ?? 0,
            quantity: item['quantity'] as int? ?? 1,
          );
        }).toList(),
      );
      final order = await _api.createOrder(request);
      orders.insert(0, order);
      return true;
    } catch (e) {
      print('┌─── CREATE ORDER ERROR ────────────────────────');
      print('│ $e');
      print('└───────────────────────────────────────────────');
      return false;
    } finally {
      isPlacingOrder.value = false;
    }
  }
}
