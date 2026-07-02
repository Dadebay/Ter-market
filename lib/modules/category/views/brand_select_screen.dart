import 'package:atlas/core/api/api_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/core/api/api_service.dart';
import 'package:atlas/models/brand_model.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/widgets/app_loading_state.dart';
import 'package:atlas/widgets/app_network_image.dart';
import 'package:iconly/iconly.dart';

class BrandSelectScreen extends StatefulWidget {
  final int? selectedBrandId;
  final int? categoryId;
  final List<BrandModel>? preloadedBrands;

  const BrandSelectScreen({
    super.key,
    this.selectedBrandId,
    this.categoryId,
    this.preloadedBrands,
  });

  @override
  State<BrandSelectScreen> createState() => _BrandSelectScreenState();
}

class _BrandSelectScreenState extends State<BrandSelectScreen> {
  final _api = ApiService();
  List<BrandModel> _brands = [];
  List<BrandModel> _filtered = [];
  bool _isLoading = true;
  bool _hasError = false;
  final _searchCtrl = TextEditingController();
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedBrandId;
    _searchCtrl.addListener(_onSearch);
    if (widget.preloadedBrands != null) {
      _brands = widget.preloadedBrands!;
      _filtered = widget.preloadedBrands!;
      _isLoading = false;
    } else {
      _fetchBrands();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty ? _brands : _brands.where((b) => b.localizedName.toLowerCase().contains(q)).toList();
    });
  }

  Future<void> _fetchBrands() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      print('┌─── BRAND SELECT SCREEN: _fetchBrands ───────');
      final result = await _api.getBrands();
      print('│ Total brands received: ${result.length}');
      for (final b in result) {
        print('│ Brand: id=${b.id}, name=${b.localizedName}, icon=${b.icon}');
      }
      print('└──────────────────────────────────────────────');
      if (!mounted) return;
      setState(() {
        _brands = result;
        _filtered = result;
      });
    } catch (e) {
      print('│ ERROR: $e');
      print('└──────────────────────────────────────────────');
      if (!mounted) return;
      setState(() => _hasError = true);
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'brands'.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Gilroy',
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_selectedId != null)
            TextButton(
              onPressed: () => Navigator.of(context).pop(<String, dynamic>{
                'id': null,
                'name': null,
              }),
              child: Text(
                'reset'.tr,
                style: const TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: TextField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Gilroy',
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'search'.tr,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                  fontFamily: 'Gilroy',
                ),
                prefixIcon: Icon(IconlyLight.search, color: Colors.grey.shade400, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        color: Colors.grey,
                        onPressed: () {
                          _searchCtrl.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF2F4F3),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Body
          Expanded(
            child: _isLoading
                ? const AppLoadingState()
                : _hasError
                    ? _buildError()
                    : _filtered.isEmpty
                        ? _buildEmpty()
                        : _buildGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'error_retry'.tr,
            style: const TextStyle(
              color: Colors.grey,
              fontFamily: 'Gilroy',
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _fetchBrands,
            child: Text(
              'retry'.tr,
              style: const TextStyle(
                color: AppColors.primary,
                fontFamily: 'Gilroy',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Text(
        'Brend tapylmady',
        style: const TextStyle(
          color: Colors.grey,
          fontFamily: 'Gilroy',
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildBrandCard(BrandModel brand) {
    final isSelected = _selectedId == brand.id;
    print(ApiClient.imgUrl + brand.icon!);
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(<String, dynamic>{
        'id': brand.id,
        'name': brand.localizedName,
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                    child: Container(
                      color: Colors.white,
                      // padding: const EdgeInsets.all(10),
                      child: brand.icon != null
                          ? AppNetworkImage(
                              url: ApiClient.imgUrl + "/" + brand.icon!,
                              fit: BoxFit.contain,
                              backgroundColor: Colors.white,
                            )
                          : const Icon(Icons.storefront_outlined, color: Colors.grey),
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(13)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Text(
                    brand.localizedName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Gilroy',
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    // Group by category
    final grouped = <String, List<BrandModel>>{};
    for (final brand in _filtered) {
      final key = brand.localizedCategory ?? '';
      (grouped[key] ??= []).add(brand);
    }

    final hasCategories = grouped.keys.any((k) => k.isNotEmpty);

    // If no brand has a category, show a plain flat grid
    if (!hasCategories) {
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
        itemCount: _filtered.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.88,
        ),
        itemBuilder: (_, i) => _buildBrandCard(_filtered[i]),
      );
    }

    // Grouped layout: named categories first (alphabetically), then uncategorised
    final namedKeys = grouped.keys.where((k) => k.isNotEmpty).toList()..sort();
    final orderedKeys = [...namedKeys, if (grouped.containsKey('')) ''];

    return CustomScrollView(
      slivers: [
        for (int s = 0; s < orderedKeys.length; s++) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(14, s == 0 ? 14 : 24, 14, 12),
              child: Text(
                orderedKeys[s].isNotEmpty ? orderedKeys[s] : 'other_brands'.tr,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Gilroy',
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.88,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) => _buildBrandCard(grouped[orderedKeys[s]]![i]),
                childCount: grouped[orderedKeys[s]]!.length,
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}
