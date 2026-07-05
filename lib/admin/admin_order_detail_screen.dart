// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:atlas/admin/admin_api_service.dart';
import 'package:atlas/admin/admin_order_item_model.dart';
import 'package:atlas/admin/admin_order_model.dart';
import 'package:atlas/utils/price_format.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final AdminOrderModel order;

  const AdminOrderDetailScreen({super.key, required this.order});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  final _api = AdminApiService();
  List<AdminOrderItemModel> _items = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final raw = await _api.getOrderItems(widget.order.id);
      debugPrint('[OrderItems] RAW: $raw');
      setState(() {
        _items = raw.map(AdminOrderItemModel.fromJson).toList();
      });
    } catch (_) {
      setState(() => _hasError = true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  Color get _statusColor {
    switch (widget.order.status) {
      case 'pending':
      case '0':
        return const Color(0xFFF59E0B);
      case 'accepted':
      case '1':
        return const Color(0xFF10B981);
      case 'processing':
        return const Color(0xFF3B82F6);
      case 'sending':
      case 'on_way':
        return const Color(0xFF8B5CF6);
      case 'delivered':
        return const Color(0xFF22C55E);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String get _statusLabel {
    switch (widget.order.orderStatus ?? widget.order.status) {
      case 'pending':
      case '0':
        return 'Garaşylýar';
      case 'accepted':
      case '1':
        return 'Kabul edildi';
      case 'processing':
        return 'Işlenýär';
      case 'sending':
        return 'Ýola çykaryldy';
      case 'on_way':
        return 'Ýolda';
      case 'delivered':
        return 'Gowşuryldy';
      case 'cancelled':
        return 'Ýatyryldy';
      default:
        return widget.order.orderStatus ?? widget.order.status ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          order.orderNumber ?? '#${order.id}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Gilroy',
          ),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xff22B241),
        onRefresh: _fetchItems,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildOrderInfo(order)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Harytlar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Gilroy',
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: Color(0xff22B241))),
              )
            else if (_hasError)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('Ýalňyşlyk ýüze çykdy', style: TextStyle(fontFamily: 'Gilroy', fontSize: 15)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchItems,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff22B241),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Täzele', style: TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              )
            else if (_items.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text('Haryt ýok', style: TextStyle(fontFamily: 'Gilroy', fontSize: 15, color: Colors.black45)),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _OrderItemCard(item: _items[i]),
                    ),
                    childCount: _items.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo(AdminOrderModel order) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xff22B241).withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_outlined, color: Color(0xff22B241), size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Sargyt maglumaty',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Gilroy', color: Color(0xff22B241)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Gilroy', color: _statusColor),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              children: [
                if (order.phoneNumber != null && order.phoneNumber!.isNotEmpty) _InfoRow(icon: Icons.phone_outlined, label: 'Telefon', value: order.phoneNumber!),
                if (order.regionName != null && order.regionName!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.location_on_outlined, label: 'Welaýat', value: order.regionName!),
                ],
                if (order.address != null && order.address!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.home_outlined, label: 'Adres', value: order.address!),
                ],
                if (order.deliveryType != null && order.deliveryType!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.local_shipping_outlined, label: 'Eltip bermek', value: order.deliveryType!),
                ],
                if (order.deliveryTime != null && order.deliveryTime!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.access_time, label: 'Wagt', value: order.deliveryTime!),
                ],
                if (order.paymentStatus != null && order.paymentStatus!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.payment_outlined, label: 'Töleg', value: order.paymentStatus!),
                ],
                if (order.createdAt != null) ...[
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.calendar_today_outlined, label: 'Sene', value: _formatDate(order.createdAt)),
                ],
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, thickness: 0.8),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Jemi: ',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Gilroy', color: Colors.black45),
                ),
                Text(
                  '${fmtPrice(order.totalPrice)} TMT',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, fontFamily: 'Gilroy', color: Color(0xFF1D1B20)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemCard extends StatelessWidget {
  final AdminOrderItemModel item;

  const _OrderItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.productImage ?? '';
    final total = item.totalPrice ?? (item.price * item.quantity);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: 180,
                    // fit: BoxFit.cover,
                    placeholder: (_, __) => _imagePlaceholder(height: 180),
                    errorWidget: (_, __, ___) => _imagePlaceholder(height: 180),
                  )
                : _imagePlaceholder(height: 180),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName ?? 'Haryt #${item.productId ?? item.id}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Gilroy',
                    color: Color(0xFF1D1B20),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${fmtPrice(item.price)} TMT × ${item.quantity}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Gilroy',
                        color: Colors.black45,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xff22B241).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '×${item.quantity}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Gilroy',
                          color: Color(0xff22B241),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${fmtPrice(total)} TMT',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Gilroy',
                    color: Color(0xff22B241),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder({double height = 180}) {
    return Container(
      width: double.infinity,
      height: height,
      color: const Color(0xFFF5F5F5),
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.black26, size: 36),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.black45),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'Gilroy', color: Colors.black45)),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Gilroy', color: Color(0xFF1D1B20))),
        ),
      ],
    );
  }
}
