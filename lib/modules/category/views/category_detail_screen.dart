import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/utils/nav.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/core/api/api_service.dart';
import 'package:atlas/models/category_model.dart';
import 'package:atlas/models/product_model.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/widgets/product_card.dart';
import 'package:atlas/widgets/app_loading_state.dart';
import 'package:atlas/widgets/app_empty_state.dart';
import 'package:atlas/modules/product_detail/views/product_detail_screen.dart';
import 'package:atlas/modules/product_detail/bindings/product_detail_binding.dart';
import 'package:atlas/models/brand_model.dart';
import 'package:atlas/modules/category/views/brand_select_screen.dart';
import 'package:iconly/iconly.dart';

enum _SortOption { none, newest, priceLow, priceHigh, discount }

class CategoryDetailScreen extends StatefulWidget {
  final int? categoryId;
  final int? brandId;
  final String categoryName;
  final int? initialSubCategoryId;
  final String? initialSubCategoryName;

  /// 'discount' | 'newest' | 'price_low' | 'price_high' | 'most_sold'
  final String? initialFilter;

  final bool mostSoldMode;

  const CategoryDetailScreen({
    super.key,
    this.categoryId,
    this.brandId,
    required this.categoryName,
    this.initialSubCategoryId,
    this.initialSubCategoryName,
    this.initialFilter,
    this.mostSoldMode = false,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final _api = ApiService();

  final _subCategories = <SubCategoryModel>[].obs;
  final _products = <ProductModel>[].obs;
  final _category = Rx<CategoryModel?>(null);
  final _isSubLoading = true.obs;
  final _isProductLoading = true.obs;
  final _isLoadingMore = false.obs;
  final _hasMore = true.obs;
  final _hasError = false.obs;

  int? _selectedSubCatId;
  _SortOption _activeSortOption = _SortOption.none;
  String _searchQuery = '';
  bool _showSearchBar = false;
  final _totalProductCount = 0.obs;
  Timer? _debounceTimer;
  final _searchInputCtrl = TextEditingController();
  int _offset = 0;
  static const int _limit = 10;
  late ScrollController _scrollCtrl;

  // Brand filter
  int? _selectedBrandId;
  String? _selectedBrandName;
  List<BrandModel> _availableBrands = [];

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController()..addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchInputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 300 && !_isLoadingMore.value && !_isProductLoading.value && _hasMore.value) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadInitialData() async {
    if (widget.mostSoldMode) {
      _isSubLoading.value = false;
      await _fetchMostSold();
      return;
    }

    // Map initialFilter to sort option
    if (widget.initialFilter != null) {
      switch (widget.initialFilter) {
        case 'discount':
          _activeSortOption = _SortOption.discount;
        case 'newest':
          _activeSortOption = _SortOption.newest;
        case 'price_low':
          _activeSortOption = _SortOption.priceLow;
        case 'price_high':
          _activeSortOption = _SortOption.priceHigh;
      }
    }

    if (widget.categoryId != null) {
      await _fetchCategoryById();
      await _fetchSubCategories();
    } else {
      // No category to load — mark sub loading done immediately
      _isSubLoading.value = false;
    }

    if (widget.initialSubCategoryId != null) {
      _selectedSubCatId = widget.initialSubCategoryId;
      await _fetchProducts(categoryId: widget.categoryId, subCategoryId: widget.initialSubCategoryId);
    } else {
      _selectedSubCatId = null;
      await _fetchProducts(categoryId: widget.categoryId);
    }
  }

  Future<void> _fetchMostSold() async {
    _isProductLoading.value = true;
    _hasError.value = false;
    try {
      final results = await _api.getMostSoldProducts();
      _products.value = results;
      _totalProductCount.value = results.length;
      _hasMore.value = false;
    } catch (_) {
      _hasError.value = true;
    } finally {
      _isProductLoading.value = false;
    }
  }

  Future<void> _fetchCategoryById() async {
    if (widget.categoryId == null) return;
    try {
      final category = await _api.getCategoryById(widget.categoryId!);
      _category.value = category;
    } catch (_) {}
  }

  Future<void> _fetchSubCategories() async {
    if (widget.categoryId == null) return;
    _isSubLoading.value = true;
    try {
      final subs = await _api.getSubCategories(categoryId: widget.categoryId!);
      subs.sort((a, b) => a.order != b.order ? a.order.compareTo(b.order) : a.id.compareTo(b.id));
      _subCategories.value = subs;
    } catch (_) {
    } finally {
      _isSubLoading.value = false;
    }
  }

  String? _computeOrdering(_SortOption sort) {
    switch (sort) {
      case _SortOption.newest:
        return '-created_at';
      case _SortOption.priceLow:
        return 'price';
      case _SortOption.priceHigh:
        return '-price';
      default:
        return null;
    }
  }

  double? _computeDiscount(_SortOption sort) => sort == _SortOption.discount ? 1 : null;

  Future<void> _fetchProducts({
    int? categoryId,
    int? subCategoryId,
    int? brandId,
    _SortOption? sort,
  }) async {
    _offset = 0;
    _hasMore.value = true;
    _isProductLoading.value = true;
    _hasError.value = false;

    final effectiveSort = sort ?? _activeSortOption;
    try {
      final result = await _api.getProducts(
        categoryId: categoryId,
        subCategoryId: subCategoryId,
        brandId: brandId ?? _selectedBrandId ?? widget.brandId,
        ordering: _computeOrdering(effectiveSort),
        discount: _computeDiscount(effectiveSort),
        search: _searchQuery.isEmpty ? null : _searchQuery,
        limit: _limit,
        offset: 0,
      );
      _products.value = result.results;
      _totalProductCount.value = result.count;
      _hasMore.value = result.count > result.results.length;
      if (result.availableBrands.isNotEmpty) {
        _availableBrands = result.availableBrands.map((e) => BrandModel.fromJson(e)).toList();
      }
    } catch (_) {
      _hasError.value = true;
    } finally {
      _isProductLoading.value = false;
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore.value || !_hasMore.value) return;
    _isLoadingMore.value = true;
    _offset += _limit;
    final effectiveSort = _activeSortOption;
    try {
      final result = await _api.getProducts(
        categoryId: widget.categoryId,
        subCategoryId: _selectedSubCatId,
        brandId: _selectedBrandId ?? widget.brandId,
        ordering: _computeOrdering(effectiveSort),
        discount: _computeDiscount(effectiveSort),
        search: _searchQuery.isEmpty ? null : _searchQuery,
        limit: _limit,
        offset: _offset,
      );
      _products.addAll(result.results);
      _hasMore.value = result.count > (_offset + result.results.length);
    } catch (_) {
      _offset -= _limit; // rollback on error
    } finally {
      _isLoadingMore.value = false;
    }
  }

  void _onSearchInputChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() => _searchQuery = value.trim());
      _fetchProducts(
        categoryId: widget.categoryId,
        subCategoryId: _selectedSubCatId,
      );
    });
  }

  void _selectSubCategory(int? id) {
    setState(() => _selectedSubCatId = id);
    _fetchProducts(categoryId: widget.categoryId, subCategoryId: id);
  }

  void _showBrandSheet() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => BrandSelectScreen(
          selectedBrandId: _selectedBrandId,
          categoryId: widget.categoryId,
          preloadedBrands: _availableBrands.isNotEmpty ? _availableBrands : null,
        ),
      ),
    );
    if (result == null || !mounted) return;
    final newId = result['id'] as int?;
    final newName = result['name'] as String?;
    setState(() {
      _selectedBrandId = newId;
      _selectedBrandName = newName;
    });
    _fetchProducts(
      categoryId: widget.categoryId,
      subCategoryId: _selectedSubCatId,
      brandId: newId,
    );
  }

  void _showFilterSheet() {
    _SortOption tempSort = _activeSortOption;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDE2DF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'sort_and_filter'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Gilroy',
                    ),
                  ),
                  TextButton(
                    onPressed: () => setSheetState(() => tempSort = _SortOption.none),
                    child: Text(
                      'reset'.tr,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Gilroy',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'sort_by'.tr,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                  fontFamily: 'Gilroy',
                ),
              ),
              const SizedBox(height: 10),
              _SortTile(
                label: 'newest_first'.tr,
                icon: HugeIcons.strokeRoundedClock01,
                selected: tempSort == _SortOption.newest,
                onTap: () => setSheetState(() => tempSort = _SortOption.newest),
              ),
              _SortTile(
                label: 'price_low_to_high'.tr,
                icon: HugeIcons.strokeRoundedArrowUp01,
                selected: tempSort == _SortOption.priceLow,
                onTap: () => setSheetState(() => tempSort = _SortOption.priceLow),
              ),
              _SortTile(
                label: 'price_high_to_low'.tr,
                icon: HugeIcons.strokeRoundedArrowDown01,
                selected: tempSort == _SortOption.priceHigh,
                onTap: () => setSheetState(() => tempSort = _SortOption.priceHigh),
              ),
              _SortTile(
                label: 'with_discount'.tr,
                icon: HugeIcons.strokeRoundedTag01,
                selected: tempSort == _SortOption.discount,
                onTap: () => setSheetState(() => tempSort = _SortOption.discount),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _activeSortOption = tempSort);
                    Navigator.of(context).pop();
                    _fetchProducts(
                      categoryId: widget.categoryId,
                      subCategoryId: _selectedSubCatId,
                      sort: tempSort,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff22B241),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'apply'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Gilroy',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(IconlyLight.arrow_left_circle, size: 20, color: Colors.black),
        ),
        title: widget.initialSubCategoryId != null
            ? Text(
                widget.initialSubCategoryName ?? widget.categoryName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Gilroy',
                ),
              )
            : Obx(
                () => Text(
                  _category.value?.localizedName ?? widget.categoryName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Gilroy',
                  ),
                ),
              ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showSearchBar = !_showSearchBar;
                if (!_showSearchBar) {
                  _searchInputCtrl.clear();
                  if (_searchQuery.isNotEmpty) {
                    _searchQuery = '';
                    _fetchProducts(
                      categoryId: widget.categoryId,
                      subCategoryId: _selectedSubCatId,
                    );
                  }
                }
              });
            },
            icon: Icon(
              _showSearchBar ? CupertinoIcons.xmark_circle : IconlyLight.search,
              color: _showSearchBar ? AppColors.primary : Colors.black87,
              size: 22,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showSearchBar) _buildSearchBar(),
          // ── Subcategory chips (only when browsing a real category) ──
          if (widget.categoryId != null)
            Obx(() {
              if (_isSubLoading.value) {
                return const SizedBox(
                  height: 52,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                );
              }
              if (_subCategories.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 52,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: _subCategories.length + 1,
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final subCat = isAll ? null : _subCategories[index - 1];
                    final isSelected = isAll ? _selectedSubCatId == null : _selectedSubCatId == subCat!.id;
                    return _buildChip(
                      label: isAll ? 'Ählisi' : subCat!.localizedName,
                      isSelected: isSelected,
                      onTap: () => _selectSubCategory(isAll ? null : subCat?.id),
                    );
                  },
                ),
              );
            }),
          // ── Brand + Filter pill buttons ──
          _buildFilterRow(),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          // ── Products grid ──
          Expanded(
            child: Obx(() {
              if (_isProductLoading.value) return const AppLoadingState();
              if (_hasError.value) {
                return AppErrorState(
                  message: 'Ýalňyşlyk ýüze çykdy.',
                  onRetry: () => _fetchProducts(
                    categoryId: widget.categoryId,
                    subCategoryId: _selectedSubCatId,
                  ),
                );
              }
              if (_products.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'Haryt tapylmady',
                );
              }
              return CustomScrollView(
                controller: _scrollCtrl,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(12),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = _products[index];
                          return ProductCard(
                            id: product.id.toString(),
                            title: product.localizedName,
                            description: product.localizedDescription,
                            price: product.price,
                            oldPrice: product.oldPrice,
                            discount: (product.discount != null && product.discount! > 0) ? product.discount!.toStringAsFixed(0) : null,
                            imageUrl: product.image ?? '',
                            storeName: product.storeName ?? 'Ter Market',
                            location: product.location ?? 'Aşgabat',
                            rating: product.rating,
                            brandIcon: product.brandIcon,
                            onTap: () => Nav.push(
                              context,
                              () => ProductDetailScreen(
                                productId: product.id,
                                title: product.localizedName,
                                imageUrl: product.image ?? '',
                                price: product.price,
                                oldPrice: product.oldPrice,
                                images: product.allImages,
                              ),
                              binding: ProductDetailBinding(),
                            ),
                            onCartPressed: null,
                          );
                        },
                        childCount: _products.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width >= 600 ? 4 : 2,
                        childAspectRatio: MediaQuery.of(context).size.width >= 600 ? 0.72 : 0.70,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Obx(() {
                      if (_isLoadingMore.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: CircularProgressIndicator(
                              color: Color(0xff22B241),
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      }
                      if (!_hasMore.value && _products.isNotEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              '— Hemmesi görkezildi —',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox(height: 20);
                    }),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    final hasBrand = _selectedBrandId != null;
    final hasSort = _activeSortOption != _SortOption.none;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          // Product count
          Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Jemi:',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontFamily: 'Gilroy',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_totalProductCount.value} sany haryt',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontFamily: 'Gilroy',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              )),
          const SizedBox(width: 8),
          // Brendler pill
          Expanded(
            child: GestureDetector(
              onTap: _showBrandSheet,
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: hasBrand ? AppColors.primary : const Color(0xFFF2F4F3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedStore01,
                      color: hasBrand ? Colors.white : Colors.black54,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        hasBrand ? (_selectedBrandName ?? 'brands'.tr) : 'brands'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Gilroy',
                          color: hasBrand ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    if (hasBrand) ...[
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedBrandId = null;
                            _selectedBrandName = null;
                          });
                          _fetchProducts(
                            categoryId: widget.categoryId,
                            subCategoryId: _selectedSubCatId,
                          );
                        },
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Süzgüç pill
          Expanded(
            child: GestureDetector(
              onTap: _showFilterSheet,
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: hasSort ? AppColors.primary : const Color(0xFFF2F4F3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedFilterHorizontal,
                      color: hasSort ? Colors.white : Colors.black54,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'filter'.tr,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Gilroy',
                        color: hasSort ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _searchInputCtrl,
        autofocus: true,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'Gilroy',
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: 'search_products'.tr,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
            fontFamily: 'Gilroy',
          ),
          prefixIcon: Icon(IconlyLight.search, color: Colors.grey.shade400, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchInputCtrl.clear();
                    setState(() => _searchQuery = '');
                    _fetchProducts(
                      categoryId: widget.categoryId,
                      subCategoryId: _selectedSubCatId,
                    );
                  },
                  child: Icon(Icons.close_rounded, size: 18, color: Colors.grey.shade400),
                )
              : null,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: _onSearchInputChanged,
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'Gilroy',
            ),
          ),
        ),
      ),
    );
  }
}

class _SortTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SortTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xff22B241).withValues(alpha: 0.08) : const Color(0xFFF7F9F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xff22B241) : const Color(0xFFE6ECE8),
          ),
        ),
        child: Row(
          children: [
            HugeIcon(
              icon: icon,
              color: selected ? const Color(0xff22B241) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Gilroy',
                  color: selected ? const Color(0xff22B241) : Colors.black87,
                ),
              ),
            ),
            if (selected)
              const HugeIcon(
                icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                color: Color(0xff22B241),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
