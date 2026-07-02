import 'package:atlas/themes/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/core/api/api_service.dart';
import 'package:atlas/models/order_model.dart';
import 'package:atlas/modules/profile/controllers/language_controller.dart';
import 'package:atlas/utils/price_format.dart';
import 'package:iconly/iconly.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
  final _api = ApiService();
  final _orders = <OrderModel>[].obs;
  final _isLoading = true.obs;
  final _hasError = false.obs;

  late final TabController _tabController;

  static const _waitingStatuses = {'pending', '0'};
  static const _acceptedStatuses = {'accepted', '1', 'processing', 'on_way', 'delivered'};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    _isLoading.value = true;
    _hasError.value = false;
    try {
      final storage = Get.find<GetStorage>();
      final deviceId = storage.read<String>('device_id') ?? '';
      final result = await _api.getMyOrders(deviceId);
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

  List<OrderModel> get _waitingOrders => _orders.where((o) => _waitingStatuses.contains(o.status)).toList();
  List<OrderModel> get _acceptedOrders => _orders.where((o) => _acceptedStatuses.contains(o.status)).toList();

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
          icon: const Icon(
            IconlyLight.arrow_left_circle,
            color: Colors.black87,
            size: 22,
          ),
          onPressed: () => Navigator.of(context).pop(),
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.black45,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
            fontFamily: 'Gilroy',
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Gilroy',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: [
            Tab(text: 'tab_waiting'.tr),
            Tab(text: 'tab_accepted'.tr),
          ],
        ),
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.accent,
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
                    backgroundColor: AppColors.accent,
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

        return TabBarView(
          controller: _tabController,
          children: [
            _OrderList(
              orders: _waitingOrders,
              lang: lang,
              formatDate: _formatDate,
              onRefresh: _fetchOrders,
            ),
            _OrderList(
              orders: _acceptedOrders,
              lang: lang,
              formatDate: _formatDate,
              onRefresh: _fetchOrders,
            ),
          ],
        );
      }),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<OrderModel> orders;
  final String lang;
  final String Function(String?) formatDate;
  final Future<void> Function() onRefresh;

  const _OrderList({
    required this.orders,
    required this.lang,
    required this.formatDate,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: onRefresh,
      child: orders.isEmpty
          ? CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const HugeIcon(
                            icon: HugeIcons.strokeRoundedShoppingCart01,
                            color: AppColors.accent,
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
                  ),
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _OrderCard(
                  order: orders[index],
                  lang: lang,
                  formatDate: formatDate,
                );
              },
            ),
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
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedShoppingBag01,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    order.orderNumber ?? order.id.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Gilroy',
                      color: AppColors.primary,
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

          // ── Quick info ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                if (order.orderStatus != null)
                  Row(
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedInformationCircle,
                        color: Colors.black45,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${'order_status'.tr}: ',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Gilroy',
                          color: Colors.black45,
                        ),
                      ),
                      _StatusBadge(status: order.orderStatus!),
                    ],
                  ),
                if (order.regionDetail != null) ...[
                  if (order.orderStatus != null) const SizedBox(height: 8),
                  _InfoRow(
                    icon: HugeIcons.strokeRoundedLocationAdd01,
                    label: 'region'.tr,
                    value: '${order.regionDetail!.name} (+${fmtPrice(order.isExpressDelivery ? order.regionDetail!.exPrice : order.regionDetail!.price)} TMT)',
                  ),
                ],
              ],
            ),
          ),

          // ── Details Section ────────────
          Container(
            padding: const EdgeInsets.all(16).copyWith(top: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (order.createdAt != null && order.createdAt!.isNotEmpty)
                  _InfoRow(
                    icon: HugeIcons.strokeRoundedCalendar01,
                    label: 'order_date'.tr,
                    value: formatDate(order.createdAt),
                  ),
                if (order.deliveryTypeDetail != null) ...[
                  if (order.createdAt != null) const SizedBox(height: 8),
                  _InfoRow(
                    icon: HugeIcons.strokeRoundedDeliveryBox01,
                    label: 'delivery_type'.tr,
                    value: order.isExpressDelivery ? 'express_delivery'.tr : order.deliveryTypeDetail!.localizedName(lang),
                  ),
                ],
                if (order.deliveryTimeDetail != null) ...[
                  if (order.deliveryTypeDetail != null || order.createdAt != null) const SizedBox(height: 8),
                  _InfoRow(
                    icon: HugeIcons.strokeRoundedClock01,
                    label: 'delivery_time'.tr,
                    value: order.deliveryTimeDetail!.displayTime,
                  ),
                ],
                if (order.phoneNumber != null && order.phoneNumber!.isNotEmpty) ...[
                  if (order.deliveryTypeDetail != null || order.deliveryTimeDetail != null) const SizedBox(height: 8),
                  _InfoRow(
                    icon: HugeIcons.strokeRoundedCall,
                    label: 'phone'.tr,
                    value: order.phoneNumber!,
                  ),
                ],
                if (order.address != null && order.address!.isNotEmpty) ...[
                  if (order.phoneNumber != null || order.deliveryTimeDetail != null) const SizedBox(height: 8),
                  _InfoRow(
                    icon: HugeIcons.strokeRoundedLocation01,
                    label: 'address'.tr,
                    value: order.address!,
                  ),
                ],
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, thickness: 0.8),
          ),

          // ── Footer: payment + total ──────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                if (order.paymentStatus != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedMoney01,
                          color: AppColors.black,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          order.paymentStatus!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Gilroy',
                            color: AppColors.black,
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
                  '${fmtPrice(order.displayTotal)} TMT',
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
                ? CachedNetworkImage(
                    imageUrl: item.productImages.first,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const Center(
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
                '${fmtPrice(item.price)} TMT × ${item.quantity}',
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
          '${fmtPrice(item.cost)} TMT',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Gilroy', color: AppColors.black),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HugeIcon(icon: icon, color: Colors.black45, size: 14),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Gilroy',
            color: Colors.black45,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Gilroy',
              color: Color(0xFF1D1B20),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  static const _colors = <String, Color>{
    'pending': Color(0xFFF59E0B),
    'accepted': Color(0xFF10B981),
    'processing': Color(0xFF3B82F6),
    'sending': Color(0xFF8B5CF6),
    'on_way': Color(0xFF8B5CF6),
    'delivered': Color(0xFF22C55E),
    'cancelled': Color(0xFFEF4444),
  };

  static const _labelKeys = <String, String>{
    'pending': 'status_pending',
    'accepted': 'status_accepted',
    'processing': 'status_processing',
    'sending': 'status_sending',
    'on_way': 'status_on_way',
    'delivered': 'status_delivered',
    'cancelled': 'status_cancelled',
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[status] ?? const Color(0xFF6B7280);
    final labelKey = _labelKeys[status];
    final label = labelKey != null ? labelKey.tr : status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: 'Gilroy',
          color: color,
        ),
      ),
    );
  }
}
