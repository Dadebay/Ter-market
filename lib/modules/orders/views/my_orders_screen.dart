import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/core/api/api_service.dart';
import 'package:atlas/models/order_model.dart';
import 'package:atlas/modules/profile/controllers/language_controller.dart';
import 'package:iconly/iconly.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final _api = ApiService();
  final _orders = <OrderModel>[].obs;
  final _isLoading = true.obs;
  final _hasError = false.obs;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    _isLoading.value = true;
    _hasError.value = false;
    try {
      final storage = Get.find<GetStorage>();
      final deviceId = storage.read<String>('device_id') ?? '';
      final result = await _api.getMyOrders(deviceId);
      // Sort newest first
      result.sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
      _orders.value = result;
    } catch (_) {
      _hasError.value = true;
    } finally {
      _isLoading.value = false;
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Get.find<LanguageController>().selectedLanguage.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            IconlyLight.arrow_left_circle,
            color: Colors.black87,
            size: 22,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'my_orders'.tr,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Gilroy',
          ),
        ),
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF22B241),
              strokeWidth: 2,
            ),
          );
        }
        if (_hasError.value) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedAlert02,
                  color: Colors.grey,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'error'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Gilroy',
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _fetchOrders,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22B241),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'retry'.tr,
                    style: const TextStyle(
                      fontFamily: 'Gilroy',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        if (_orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22B241).withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedShoppingCart01,
                    color: Color(0xFF22B241),
                    size: 52,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'no_orders'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Gilroy',
                    color: Color(0xFF1D1B20),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'no_orders_desc'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Gilroy',
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: const Color(0xFF22B241),
          onRefresh: _fetchOrders,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _OrderCard(
                order: _orders[index],
                lang: lang,
                formatDate: _formatDate,
              );
            },
          ),
        );
      }),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final String lang;
  final String Function(String?) formatDate;

  const _OrderCard({
    required this.order,
    required this.lang,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = formatDate(order.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF0FBF3),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedShoppingBag01,
                  color: Color(0xFF22B241),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${order.orderNumber ?? '#${order.id}'}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Gilroy',
                      color: Color(0xFF1D1B20),
                    ),
                  ),
                ),
                if (dateStr.isNotEmpty)
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Gilroy',
                      color: Colors.black45,
                    ),
                  ),
              ],
            ),
          ),

          // ── Items list ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              children: [
                for (final item in order.items) ...[
                  _ItemRow(item: item),
                  if (item != order.items.last) const Divider(height: 16, thickness: 0.5),
                ],
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 24, thickness: 0.8),
          ),

          // ── Footer: payment + total ──────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                if (order.paymentStatus != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22B241).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedMoney01,
                          color: Color(0xFF22B241),
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          order.paymentStatus!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Gilroy',
                            color: Color(0xFF22B241),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ] else
                  const Spacer(),
                Text(
                  '${'total'.tr} ',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Gilroy',
                    color: Colors.black45,
                  ),
                ),
                Text(
                  '${order.totalPrice.toStringAsFixed(0)} TMT',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Gilroy',
                    color: Color(0xFF1D1B20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final OrderItemModel item;

  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.productImages.isNotEmpty
                ? Image.network(
                    item.productImages.first,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedPackageDelivered,
                        color: Colors.black45,
                        size: 18,
                      ),
                    ),
                  )
                : const Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedPackageDelivered,
                      color: Colors.black45,
                      size: 18,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName ?? 'Haryt ${item.productId}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Gilroy',
                  color: Color(0xFF1D1B20),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.price.toStringAsFixed(0)} TMT × ${item.quantity}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Gilroy',
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${item.cost.toStringAsFixed(0)} TMT',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'Gilroy',
            color: Color(0xFF22B241),
          ),
        ),
      ],
    );
  }
}
