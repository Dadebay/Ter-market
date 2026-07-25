// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:atlas/admin/admin_api_service.dart';
import 'package:atlas/admin/admin_order_item_model.dart';
import 'package:atlas/admin/admin_order_model.dart';
import 'package:atlas/utils/price_format.dart';

enum _ItemViewMode { grid, listBig, listCompact }

class AdminOrderDetailScreen extends StatefulWidget {
  final AdminOrderModel order;

  const AdminOrderDetailScreen({super.key, required this.order});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  static const _viewModeKey = 'admin_order_items_view_mode';

  final _api = AdminApiService();
  final _storage = GetStorage();
  List<AdminOrderItemModel> _items = [];
  bool _isLoading = true;
  bool _hasError = false;
  _ItemViewMode _viewMode = _ItemViewMode.listBig;

  @override
  void initState() {
    super.initState();
    final savedIndex = _storage.read<int>(_viewModeKey);
    if (savedIndex != null && savedIndex >= 0 && savedIndex < _ItemViewMode.values.length) {
      _viewMode = _ItemViewMode.values[savedIndex];
    }
    _fetchItems();
  }

  void _setViewMode(_ItemViewMode mode) {
    setState(() => _viewMode = mode);
    _storage.write(_viewModeKey, mode.index);
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

  String? _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return null;
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
        actions: [
          _ViewModeButton(
            icon: Icons.grid_view_rounded,
            tooltip: 'Tor görnüşi',
            selected: _viewMode == _ItemViewMode.grid,
            onTap: () => _setViewMode(_ItemViewMode.grid),
          ),
          _ViewModeButton(
            icon: Icons.view_agenda_outlined,
            tooltip: 'Uly sanaw görnüşi',
            selected: _viewMode == _ItemViewMode.listBig,
            onTap: () => _setViewMode(_ItemViewMode.listBig),
          ),
          _ViewModeButton(
            icon: Icons.view_list_rounded,
            tooltip: 'Kiçi sanaw görnüşi',
            selected: _viewMode == _ItemViewMode.listCompact,
            onTap: () => _setViewMode(_ItemViewMode.listCompact),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xff22B241),
        onRefresh: _fetchItems,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildOrderInfo(order)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  _items.isEmpty ? 'Harytlar' : 'Harytlar (${_items.length})',
                  style: const TextStyle(
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
                sliver: _buildItemsSliver(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSliver() {
    switch (_viewMode) {
      case _ItemViewMode.grid:
        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.65,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, i) => _OrderItemGridCard(item: _items[i]),
            childCount: _items.length,
          ),
        );
      case _ItemViewMode.listBig:
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OrderItemCard(item: _items[i]),
            ),
            childCount: _items.length,
          ),
        );
      case _ItemViewMode.listCompact:
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _OrderItemCompactCard(item: _items[i]),
            ),
            childCount: _items.length,
          ),
        );
    }
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
                if (order.phoneNumber != null && order.phoneNumber!.isNotEmpty)
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Telefon',
                    value: order.phoneNumber!,
                    onTap: () => callPhoneNumber(order.phoneNumber),
                  ),
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
                  _InfoRow(icon: Icons.local_shipping_outlined, label: 'Eltip bermek', value: deliveryTypeLabel(order.deliveryType)),
                ],
                if (order.deliveryTime != null && order.deliveryTime!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.access_time, label: 'Wagt', value: deliveryTimeLabel(order.deliveryTime)),
                ],
                if (order.paymentStatus != null && order.paymentStatus!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.payment_outlined, label: 'Töleg', value: order.paymentStatus!),
                ],
                if (_formatDate(order.createdAt) case final sene?) ...[
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.calendar_today_outlined, label: 'Sene', value: sene),
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

class _ViewModeButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;

  const _ViewModeButton({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: selected ? const Color(0xff22B241) : Colors.black45),
    );
  }
}

class _OrderItemGridCard extends StatelessWidget {
  final AdminOrderItemModel item;

  const _OrderItemGridCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.productImage ?? '';
    final total = item.totalPrice ?? (item.price * item.quantity);

    return Container(
      padding: const EdgeInsets.all(10),
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
                    height: 130,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => _imagePlaceholder(height: 130),
                    errorWidget: (_, __, ___) => _imagePlaceholder(height: 130),
                  )
                : _imagePlaceholder(height: 130),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName ?? 'Haryt #${item.productId ?? item.id}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Gilroy',
                      color: Color(0xFF1D1B20),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${fmtPrice(item.price)} TMT',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, fontFamily: 'Gilroy', color: Colors.black45),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xff22B241).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '×${item.quantity}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, fontFamily: 'Gilroy', color: Color(0xff22B241)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${fmtPrice(total)} TMT',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Gilroy', color: Color(0xff22B241)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder({double height = 130}) {
    return Container(
      width: double.infinity,
      height: height,
      color: const Color(0xFFF5F5F5),
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.black26, size: 32),
    );
  }
}

class _OrderItemCompactCard extends StatelessWidget {
  final AdminOrderItemModel item;

  const _OrderItemCompactCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.productImage ?? '';
    final total = item.totalPrice ?? (item.price * item.quantity);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 76,
                    height: 76,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => _imagePlaceholder(),
                    errorWidget: (_, __, ___) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.productName ?? 'Haryt #${item.productId ?? item.id}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Gilroy', color: Color(0xFF1D1B20)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${fmtPrice(item.price)} TMT × ${item.quantity}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, fontFamily: 'Gilroy', color: Colors.black45),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              '${fmtPrice(total)} TMT',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Gilroy', color: Color(0xff22B241)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 76,
      height: 76,
      color: const Color(0xFFF5F5F5),
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.black26, size: 24),
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
  final VoidCallback? onTap;

  const _InfoRow({required this.icon, required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: onTap != null ? const Color(0xff22B241) : Colors.black45),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'Gilroy', color: Colors.black45)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'Gilroy',
              color: onTap != null ? const Color(0xff22B241) : const Color(0xFF1D1B20),
              decoration: onTap != null ? TextDecoration.underline : TextDecoration.none,
            ),
          ),
        ),
      ],
    );
    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}
