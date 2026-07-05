// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:atlas/admin/admin_api_service.dart';
import 'package:atlas/admin/admin_login_screen.dart';
import 'package:atlas/admin/admin_order_detail_screen.dart';
import 'package:atlas/admin/admin_order_model.dart';
import 'package:atlas/utils/price_format.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> with SingleTickerProviderStateMixin {
  final _api = AdminApiService();
  final _allOrders = <AdminOrderModel>[];
  bool _isLoading = true;
  bool _hasError = false;
  late TabController _tabController;

  static const _pendingStatuses = {'pending', '0'};

  @override
  void initState() {
    super.initState();
    print('[Admin] AdminOrdersScreen açıldı');
    _tabController = TabController(length: 2, vsync: this);
    _fetchOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      // Load first 3 pages to cover enough orders
      final results = <AdminOrderModel>[];
      for (int page = 1; page <= 3; page++) {
        final raw = await _api.getAllOrders(page: page);
        if (raw.isEmpty) break;
        results.addAll(raw.map(AdminOrderModel.fromJson));
        if (raw.length < 20) break; // last page
      }
      results.sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
      setState(() {
        _allOrders
          ..clear()
          ..addAll(results);
      });
    } catch (_) {
      setState(() => _hasError = true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await AdminApiService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
      (route) => false,
    );
  }

  List<AdminOrderModel> get _pendingOrders => _allOrders.where((o) => _pendingStatuses.contains(o.status)).toList();
  List<AdminOrderModel> get _otherOrders => _allOrders.where((o) => !_pendingStatuses.contains(o.status)).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Ter Market Orders',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Gilroy',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _fetchOrders,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xff22B241),
          unselectedLabelColor: Colors.black45,
          indicatorColor: const Color(0xff22B241),
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w700, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w500, fontSize: 14),
          tabs: [
            Tab(text: 'Garaşylýan (${_pendingOrders.length})'),
            Tab(text: 'Beýlekiler (${_otherOrders.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xff22B241)))
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Ýalňyşlyk ýüze çykdy', style: TextStyle(fontSize: 16, fontFamily: 'Gilroy')),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _fetchOrders,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff22B241),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Täzele', style: TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _AdminOrderList(orders: _pendingOrders, onRefresh: _fetchOrders),
                    _AdminOrderList(orders: _otherOrders, onRefresh: _fetchOrders),
                  ],
                ),
    );
  }
}

class _AdminOrderList extends StatelessWidget {
  final List<AdminOrderModel> orders;
  final Future<void> Function() onRefresh;

  const _AdminOrderList({required this.orders, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xff22B241),
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
                            color: const Color(0xff22B241).withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shopping_bag_outlined, size: 52, color: Color(0xff22B241)),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Sargyt ýok',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Gilroy'),
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
              itemBuilder: (_, i) => _AdminOrderCard(order: orders[i]),
            ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final AdminOrderModel order;

  const _AdminOrderCard({required this.order});

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
    switch (order.status) {
      case 'pending':
      case '0':
        return const Color(0xFFF59E0B);
      case 'accepted':
      case '1':
        return const Color(0xFF10B981);
      case 'processing':
        return const Color(0xFF3B82F6);
      case 'sending':
        return const Color(0xFF8B5CF6);
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
    switch (order.orderStatus ?? order.status) {
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
        return order.orderStatus ?? order.status ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AdminOrderDetailScreen(order: order)),
      ),
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xff22B241).withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, color: Color(0xff22B241), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    order.orderNumber ?? '#${order.id}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Gilroy',
                      color: Color(0xff22B241),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Gilroy',
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Info rows
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              children: [
                if (order.phoneNumber != null && order.phoneNumber!.isNotEmpty)
                  _Row(icon: Icons.phone_outlined, label: 'Telefon', value: order.phoneNumber!),
                if (order.regionName != null && order.regionName!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _Row(icon: Icons.location_on_outlined, label: 'Welaýat', value: order.regionName!),
                ],
                if (order.address != null && order.address!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _Row(icon: Icons.home_outlined, label: 'Adres', value: order.address!),
                ],
                if (order.deliveryType != null && order.deliveryType!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _Row(icon: Icons.local_shipping_outlined, label: 'Eltip bermek', value: order.deliveryType!),
                ],
                if (order.deliveryTime != null && order.deliveryTime!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _Row(icon: Icons.access_time, label: 'Wagt', value: order.deliveryTime!),
                ],
                if (order.paymentStatus != null && order.paymentStatus!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _Row(icon: Icons.payment_outlined, label: 'Töleg', value: order.paymentStatus!),
                ],
                if (order.createdAt != null) ...[
                  const SizedBox(height: 8),
                  _Row(icon: Icons.calendar_today_outlined, label: 'Sene', value: _formatDate(order.createdAt)),
                ],
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, thickness: 0.8),
          ),

          // Total
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
    ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.black45),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'Gilroy', color: Colors.black45),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Gilroy', color: Color(0xFF1D1B20)),
          ),
        ),
      ],
    );
  }
}
