import 'package:flutter/material.dart';
import 'package:atlas/admin/admin_api_service.dart';
import 'package:atlas/admin/admin_order_model.dart';
import 'package:atlas/admin/admin_orders_screen.dart';

/// Orders older than yesterday. The main orders screen only shows today +
/// yesterday; anything before that lives here so the main list stays short.
class AdminArchiveOrdersScreen extends StatefulWidget {
  const AdminArchiveOrdersScreen({super.key});

  @override
  State<AdminArchiveOrdersScreen> createState() => _AdminArchiveOrdersScreenState();
}

class _AdminArchiveOrdersScreenState extends State<AdminArchiveOrdersScreen> {
  final _api = AdminApiService();
  final _archivedOrders = <AdminOrderModel>[];
  final _searchController = TextEditingController();

  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  bool _hasMore = true;
  int _page = 1;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AdminOrderModel> get _filteredOrders {
    if (_searchQuery.isEmpty) return _archivedOrders;
    final q = _searchQuery.toLowerCase();
    return _archivedOrders.where((o) => (o.orderNumber ?? o.id.toString()).toLowerCase().contains(q)).toList();
  }

  DateTime? _parseLocal(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    try {
      return DateTime.parse(iso).toLocal();
    } catch (_) {
      return null;
    }
  }

  DateTime get _yesterdayStart {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.subtract(const Duration(days: 1));
  }

  /// Fetches one raw page and keeps only the orders older than yesterday.
  Future<void> _fetchNextPage() async {
    final raw = await _api.getAllOrders(page: _page);
    if (raw.isEmpty) {
      _hasMore = false;
      return;
    }
    final archived = raw.map(AdminOrderModel.fromJson).where((o) {
      final dt = _parseLocal(o.createdAt);
      return dt != null && dt.isBefore(_yesterdayStart);
    });
    _archivedOrders.addAll(archived);
    _archivedOrders.sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
    if (raw.length < 20) {
      _hasMore = false;
    } else {
      _page++;
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isInitialLoading = true;
      _hasError = false;
      _page = 1;
      _hasMore = true;
      _archivedOrders.clear();
    });
    try {
      var attempts = 0;
      // Recent pages are mostly today/yesterday, so page forward until a
      // reasonable first batch of archived orders shows up.
      while (_hasMore && _archivedOrders.length < 20 && attempts < 20) {
        await _fetchNextPage();
        attempts++;
      }
    } catch (_) {
      setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isInitialLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      var attempts = 0;
      final startCount = _archivedOrders.length;
      while (_hasMore && _archivedOrders.length < startCount + 20 && attempts < 20) {
        await _fetchNextPage();
        attempts++;
      }
      if (mounted) setState(() {});
    } catch (_) {
      // keep whatever loaded so far; user can retry via the footer button
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Arhiw',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Gilroy'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadInitial,
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_isInitialLoading && !_hasError) _buildSearchBar(),
          Expanded(
            child: _isInitialLoading
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
                              onPressed: _loadInitial,
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
                    : AdminOrderList(orders: _filteredOrders, onRefresh: _loadInitial, footer: _buildFooter()),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
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
    );
  }

  Widget? _buildFooter() {
    if (!_hasMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text('Ähli sargytlar ýüklendi', style: TextStyle(fontFamily: 'Gilroy', fontSize: 13, color: Colors.black45)),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: _isLoadingMore
            ? const CircularProgressIndicator(color: Color(0xff22B241))
            : OutlinedButton(
                onPressed: _loadMore,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xff22B241),
                  side: const BorderSide(color: Color(0xff22B241)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Has köp ýükle', style: TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w700)),
              ),
      ),
    );
  }
}
