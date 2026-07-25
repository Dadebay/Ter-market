import 'package:atlas/core/api/api_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/core/api/api_service.dart';
import 'package:atlas/models/brand_model.dart';
import 'package:atlas/utils/nav.dart';
import 'package:atlas/models/category_model.dart';
import 'package:atlas/modules/category/controllers/category_controller.dart';
import 'package:atlas/modules/category/views/category_detail_screen.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/widgets/app_loading_state.dart';
import 'package:atlas/widgets/app_empty_state.dart';
import 'package:atlas/widgets/app_network_image.dart';
import 'package:iconly/iconly.dart';

class _SearchHit {
  final CategoryModel? category;
  final SubCategoryModel? subCategory;
  final CategoryModel? parentCategory;

  _SearchHit.category(CategoryModel cat)
      : category = cat,
        subCategory = null,
        parentCategory = null;

  _SearchHit.subCategory(SubCategoryModel sub, CategoryModel? parent)
      : category = null,
        subCategory = sub,
        parentCategory = parent;

  bool get isCategory => category != null;
  String get displayName => isCategory ? category!.localizedName : subCategory!.localizedName;
}

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with SingleTickerProviderStateMixin {
  late final CategoryController _ctrl;
  final _api = ApiService();
  final _searchCtrl = TextEditingController();
  late final TabController _tabController;
  bool _isSearching = false;
  List<_SearchHit> _hits = [];
  final _brands = <BrandModel>[];
  bool _isBrandsLoading = true;
  bool _hasBrandsError = false;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<CategoryController>();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (_tabController.indexIsChanging) return;
        if (_tabController.index != 0 && _isSearching) {
          _stopSearch();
        }
        setState(() {});
      });
    _searchCtrl.addListener(_onSearchChanged);
    _fetchBrands();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchBrands() async {
    setState(() {
      _isBrandsLoading = true;
      _hasBrandsError = false;
    });
    try {
      final brands = await _api.getBrands();
      if (!mounted) return;
      setState(() {
        _brands
          ..clear()
          ..addAll(brands);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasBrandsError = true);
    } finally {
      if (!mounted) return;
      setState(() => _isBrandsLoading = false);
    }
  }

  void _onSearchChanged() {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _hits = []);
      return;
    }
    final hits = <_SearchHit>[];
    for (final cat in _ctrl.categories) {
      if (cat.titleTk.toLowerCase().contains(q) || cat.titleRu.toLowerCase().contains(q)) {
        hits.add(_SearchHit.category(cat));
      }
    }
    for (final sub in _ctrl.allSubCategories) {
      if (sub.titleTk.toLowerCase().contains(q) || sub.titleRu.toLowerCase().contains(q)) {
        final parent = _ctrl.categories.firstWhereOrNull((c) => c.id == sub.categoryId);
        hits.add(_SearchHit.subCategory(sub, parent));
      }
    }
    setState(() => _hits = hits);
  }

  void _startSearch() => setState(() => _isSearching = true);

  void _stopSearch() {
    _searchCtrl.clear();
    setState(() {
      _isSearching = false;
      _hits = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCategoryTab = _tabController.index == 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        titleSpacing: _isSearching ? 4 : 16,
        leading: isCategoryTab && _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: _stopSearch,
              )
            : null,
        title: isCategoryTab && _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                textInputAction: TextInputAction.search,
                style: const TextStyle(
                  fontSize: 15,
                  fontFamily: 'Gilroy',
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'search_category'.tr,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 15,
                    fontFamily: 'Gilroy',
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              )
            : Text(
                'categories'.tr,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Gilroy',
                ),
              ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: AnimatedBuilder(
              animation: _tabController,
              builder: (_, __) {
                final idx = _tabController.index;
                return Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildTabPill(0, 'categories'.tr, idx),
                      _buildTabPill(1, 'brands'.tr, idx),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        actions: [
          if (isCategoryTab && _isSearching && _searchCtrl.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchCtrl.clear();
                setState(() => _hits = []);
              },
              icon: const Icon(Icons.close_rounded, color: Colors.black54, size: 22),
            )
          else if (isCategoryTab && !_isSearching)
            IconButton(
              onPressed: _startSearch,
              icon: const Icon(IconlyLight.search, color: Colors.black87, size: 24),
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _isSearching ? _buildSearchBody() : _buildCategoryList(),
          _buildBrandsTab(),
        ],
      ),
    );
  }

  Widget _buildTabPill(int tabIndex, String label, int activeIndex) {
    final isActive = activeIndex == tabIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => _tabController.animateTo(tabIndex),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: 'Gilroy',
                color: isActive ? AppColors.white : Colors.black54,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandsTab() {
    if (_isBrandsLoading) return const AppLoadingState();
    if (_hasBrandsError) {
      return AppErrorState(
        message: 'error_retry'.tr,
        onRetry: _fetchBrands,
      );
    }
    if (_brands.isEmpty) {
      return AppEmptyState(
        icon: Icons.storefront_outlined,
        title: 'brands'.tr,
      );
    }

    // Group brands by category — null category goes to a separate "other" bucket
    final grouped = <String, List<BrandModel>>{};
    for (final brand in _brands) {
      final key = brand.localizedCategory ?? '';
      (grouped[key] ??= []).add(brand);
    }

    // Debug: print grouping
    print('[Brands] Total brands: ${_brands.length}');
    for (final entry in grouped.entries) {
      print('[Brands] Category "${entry.key}": ${entry.value.map((b) => b.localizedName).toList()}');
    }

    // Build ordered list: named categories first (alphabetically), then uncategorised
    final namedKeys = grouped.keys.where((k) => k.isNotEmpty).toList()..sort();
    final orderedKeys = [...namedKeys, if (grouped.containsKey('')) ''];

    return CustomScrollView(
      slivers: [
        for (int s = 0; s < orderedKeys.length; s++) ...[
          // Section header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(14, s == 0 ? 14 : 24, 14, 12),
              child: Text(
                orderedKeys[s].isNotEmpty ? orderedKeys[s] : 'other_brands'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Gilroy',
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
          ),
          // Brand grid for this section
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.78,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final brand = grouped[orderedKeys[s]]![index];
                  return GestureDetector(
                    onTap: () => Nav.push(
                      context,
                      () => CategoryDetailScreen(
                        categoryName: brand.localizedName,
                        brandId: brand.id,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEDEDED)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                              child: Container(
                                color: const Color(0xFFFAFAFA),
                                padding: const EdgeInsets.all(8),
                                child: brand.icon != null
                                    ? AppNetworkImage(
                                        url: ApiClient.imgUrl + brand.icon!,
                                        fit: BoxFit.contain,
                                        backgroundColor: const Color(0xFFFAFAFA),
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
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                            child: Text(
                              brand.localizedName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Gilroy',
                                color: Colors.black87,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: grouped[orderedKeys[s]]!.length,
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildHitAvatar(_SearchHit hit) {
    final imageUrl = hit.isCategory ? hit.category!.image : (hit.subCategory!.image ?? hit.parentCategory?.image);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AppNetworkImage(
                url: imageUrl,
                fit: BoxFit.contain,
              ),
            )
          : Icon(
              hit.isCategory ? Icons.category_outlined : Icons.subdirectory_arrow_right_rounded,
              size: 20,
              color: AppColors.primary,
            ),
    );
  }

  Widget _buildCategoryList() {
    return Obx(() {
      if (_ctrl.isLoading.value) return const AppLoadingState();
      if (_ctrl.hasError.value) {
        return AppErrorState(
          message: 'error_retry'.tr,
          onRetry: _ctrl.fetchCategories,
        );
      }
      if (_ctrl.categories.isEmpty) {
        return AppEmptyState(
          icon: Icons.category_outlined,
          title: 'no_categories'.tr,
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _ctrl.categories.length,
        itemBuilder: (context, index) {
          final cat = _ctrl.categories[index];
          return _CategoryAccordionTile(cat: cat, controller: _ctrl);
        },
      );
    });
  }

  Widget _buildSearchBody() {
    if (_searchCtrl.text.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded, size: 52, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'search_category'.tr,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 15,
                fontFamily: 'Gilroy',
              ),
            ),
          ],
        ),
      );
    }
    if (_hits.isEmpty) {
      return AppEmptyState(
        icon: Icons.search_off_rounded,
        title: 'no_results'.tr,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: _hits.length,
      itemBuilder: (context, index) {
        final hit = _hits[index];
        return GestureDetector(
          onTap: () {
            if (hit.isCategory) {
              Nav.push(
                context,
                () => CategoryDetailScreen(
                  categoryId: hit.category!.id,
                  categoryName: hit.category!.localizedName,
                ),
              );
            } else {
              Nav.push(
                context,
                () => CategoryDetailScreen(
                  categoryId: hit.parentCategory?.id,
                  categoryName: hit.parentCategory?.localizedName ?? hit.subCategory!.localizedName,
                  initialSubCategoryId: hit.subCategory!.id,
                  initialSubCategoryName: hit.subCategory!.localizedName,
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildHitAvatar(hit),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hit.displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Gilroy',
                          color: Colors.black87,
                        ),
                      ),
                      if (!hit.isCategory && hit.parentCategory != null)
                        Text(
                          hit.parentCategory!.localizedName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryAccordionTile extends StatelessWidget {
  final CategoryModel cat;
  final CategoryController controller;

  const _CategoryAccordionTile({
    required this.cat,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isExpanded = controller.expandedIds.contains(cat.id);
      final isLoadingSub = controller.loadingSubCatIds.contains(cat.id);
      final subCategories = controller.subCategoriesMap[cat.id] ?? [];

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Category row ──────────────────────────────────────────────
          InkWell(
            onTap: () => controller.toggleCategory(cat.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Icon / image
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: cat.image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AppNetworkImage(
                              url: cat.image,
                              fit: BoxFit.contain,
                            ),
                          )
                        : const Icon(Icons.category_outlined, size: 28, color: Colors.grey),
                  ),
                  const SizedBox(width: 14),
                  // Name
                  Expanded(
                    child: Text(
                      cat.localizedName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Gilroy',
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  // Toggle button
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isExpanded ? AppColors.primary : AppColors.greyBgColor,
                      // color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isExpanded ? Icons.remove : Icons.add,
                      size: 18,
                      color: isExpanded ? AppColors.white : AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Subcategory list ──────────────────────────────────────────
          if (isExpanded) ...[
            if (isLoadingSub)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF22B241),
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  children: subCategories.map((sub) {
                    return GestureDetector(
                      onTap: () => Nav.push(
                        context,
                        () => CategoryDetailScreen(
                          categoryId: cat.id,
                          categoryName: cat.localizedName,
                          initialSubCategoryId: sub.id,
                          initialSubCategoryName: sub.localizedName,
                        ),
                      ),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          sub.localizedName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Gilroy',
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
          const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFEEEEEE)),
        ],
      );
    });
  }
}
