// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:atlas/admin/admin_api_service.dart';
import 'package:atlas/admin/admin_archive_orders_screen.dart';
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
  final _searchController = TextEditingController();
  bool _isLoading = true;
  bool _hasError = false;
  late TabController _tabController;
  String _searchQuery = '';
  String? _selectedDeliveryType;

  static const _pendingStatuses = {'pending', '0'};

  @override
  void initState() {
    super.initState();
    print('[Admin] AdminOrdersScreen açıldı');
    _tabController = TabController(length: 2, vsync: this)..addListener(() => setState(() {}));
    _fetchOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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

  DateTime? _parseLocal(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    try {
      return DateTime.parse(iso).toLocal();
    } catch (_) {
      return null;
    }
  }

  /// Orders from today or yesterday only. Older orders are hidden — orders
  /// with an unparseable date stay visible rather than silently vanishing.
  List<AdminOrderModel> get _recentOrders {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cutoff = today.subtract(const Duration(days: 1));
    return _allOrders.where((o) {
      final dt = _parseLocal(o.createdAt);
      return dt == null || !dt.isBefore(cutoff);
    }).toList();
  }

  /// Distinct, non-empty delivery types seen across all loaded orders, used
  /// to build the filter chips without hardcoding server-side values.
  List<String> get _deliveryTypes {
    final types = _allOrders
        .map((o) => o.deliveryType?.trim())
        .where((d) => d != null && d.isNotEmpty)
        .map((d) => d!)
        .toSet()
        .toList();
    types.sort();
    return types;
  }

  bool _matchesSearch(AdminOrderModel o) {
    if (_searchQuery.isEmpty) return true;
    final orderNumber = (o.orderNumber ?? o.id.toString()).toLowerCase();
    return orderNumber.contains(_searchQuery.toLowerCase());
  }

  List<AdminOrderModel> _applyFilters(List<AdminOrderModel> list) {
    return list.where((o) {
      if (_selectedDeliveryType != null &&
          o.deliveryType?.trim().toLowerCase() != _selectedDeliveryType!.toLowerCase()) {
        return false;
      }
      return _matchesSearch(o);
    }).toList();
  }

  List<AdminOrderModel> get _pendingOrders =>
      _applyFilters(_recentOrders.where((o) => _pendingStatuses.contains(o.status)).toList());
  List<AdminOrderModel> get _otherOrders =>
      _applyFilters(_recentOrders.where((o) => !_pendingStatuses.contains(o.status)).toList());

  /// Orders in the currently active tab, matching the search box but not
  /// yet narrowed by delivery type — the base used to count each chip.
  List<AdminOrderModel> get _activeTabOrders {
    final statusFiltered = _tabController.index == 0
        ? _recentOrders.where((o) => _pendingStatuses.contains(o.status))
        : _recentOrders.where((o) => !_pendingStatuses.contains(o.status));
    return statusFiltered.where(_matchesSearch).toList();
  }

  int _countForDeliveryType(String? type, List<AdminOrderModel> base) {
    if (type == null) return base.length;
    return base.where((o) => o.deliveryType?.trim().toLowerCase() == type.toLowerCase()).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Arhiw',
          icon: const Icon(Icons.archive_outlined, color: Colors.black87),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AdminArchiveOrdersScreen()),
          ),
        ),
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
      body: Column(
        children: [
          if (!_isLoading && !_hasError) _buildFilterBar(),
          Expanded(
            child: _isLoading
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
                          AdminOrderList(orders: _pendingOrders, onRefresh: _fetchOrders),
                          AdminOrderList(orders: _otherOrders, onRefresh: _fetchOrders),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final types = _deliveryTypes;
    final base = _activeTabOrders;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v.trim()),
            style: const TextStyle(fontFamily: 'Gilroy', fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Sargyt belgisi boýunça gözle...',
              hintStyle: const TextStyle(fontFamily: 'Gilroy', color: Colors.black38, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Colors.black45, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.black45, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (types.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _FilterChip(
                    label: 'Hemmesi (${_countForDeliveryType(null, base)})',
                    selected: _selectedDeliveryType == null,
                    onTap: () => setState(() => _selectedDeliveryType = null),
                  ),
                  for (final type in types) ...[
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: '${deliveryTypeLabel(type)} (${_countForDeliveryType(type, base)})',
                      selected: _selectedDeliveryType == type,
                      onTap: () => setState(() => _selectedDeliveryType = type),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xff22B241) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? const Color(0xff22B241) : const Color(0xFFE0E0E0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Gilroy',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}

class AdminOrderList extends StatelessWidget {
  final List<AdminOrderModel> orders;
  final Future<void> Function() onRefresh;
  final Widget? footer;

  const AdminOrderList({super.key, required this.orders, required this.onRefresh, this.footer});

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
              itemCount: orders.length + (footer != null ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                if (i >= orders.length) return footer!;
                return AdminOrderCard(order: orders[i]);
              },
            ),
    );
  }
}

class AdminOrderCard extends StatelessWidget {
  final AdminOrderModel order;

  const AdminOrderCard({super.key, required this.order});

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
                  AdminInfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Telefon',
                    value: order.phoneNumber!,
                    onTap: () => callPhoneNumber(order.phoneNumber),
                  ),
                if (order.regionName != null && order.regionName!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  AdminInfoRow(icon: Icons.location_on_outlined, label: 'Welaýat', value: order.regionName!),
                ],
                if (order.address != null && order.address!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  AdminInfoRow(icon: Icons.home_outlined, label: 'Adres', value: order.address!),
                ],
                if (order.deliveryType != null && order.deliveryType!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  AdminInfoRow(icon: Icons.local_shipping_outlined, label: 'Eltip bermek', value: deliveryTypeLabel(order.deliveryType)),
                ],
                if (order.deliveryTime != null && order.deliveryTime!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  AdminInfoRow(icon: Icons.access_time, label: 'Wagt', value: deliveryTimeLabel(order.deliveryTime)),
                ],
                if (order.paymentStatus != null && order.paymentStatus!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  AdminInfoRow(icon: Icons.payment_outlined, label: 'Töleg', value: order.paymentStatus!),
                ],
                if (_formatDate(order.createdAt) case final sene?) ...[
                  const SizedBox(height: 8),
                  AdminInfoRow(icon: Icons.calendar_today_outlined, label: 'Sene', value: sene),
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

class AdminInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const AdminInfoRow({super.key, required this.icon, required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: onTap != null ? const Color(0xff22B241) : Colors.black45),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'Gilroy', color: Colors.black45),
        ),
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
