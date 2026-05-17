import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/core/api/api_service.dart';
import 'package:atlas/models/product_model.dart';
import 'package:atlas/widgets/product_card.dart';
import 'package:atlas/widgets/app_loading_state.dart';
import 'package:atlas/widgets/app_empty_state.dart';
import 'package:atlas/widgets/app_dialogs.dart';
import 'package:atlas/modules/product_detail/views/product_detail_screen.dart';
import 'package:atlas/modules/product_detail/bindings/product_detail_binding.dart';

enum _SortOption { none, newest, priceLow, priceHigh, discount }

class SubCategoryProductScreen extends StatefulWidget {
  final String categoryName;
  final int? categoryId;
  final int? subCategoryId;

  const SubCategoryProductScreen({
    super.key,
    required this.categoryName,
    this.categoryId,
    this.subCategoryId,
  });

  @override
  State<SubCategoryProductScreen> createState() => _SubCategoryProductScreenState();
}

class _SubCategoryProductScreenState extends State<SubCategoryProductScreen> {
  final _api = ApiService();
  final _products = <ProductModel>[].obs;
  final _isLoading = true.obs;
  final _hasError = false.obs;

  _SortOption _activeSortOption = _SortOption.none;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts({_SortOption? sort}) async {
    _isLoading.value = true;
    _hasError.value = false;
    try {
      String? ordering;
      double? skidka;

      switch (sort ?? _activeSortOption) {
        case _SortOption.newest:
          ordering = '-created_at';
        case _SortOption.priceLow:
          ordering = 'price';
        case _SortOption.priceHigh:
          ordering = '-price';
        case _SortOption.discount:
          skidka = 1;
        case _SortOption.none:
          break;
      }

      final result = await _api.getProducts(
        categoryId: widget.categoryId,
        subCategoryId: widget.subCategoryId,
        ordering: ordering,
        discount: skidka,
      );
      _products.value = result.results;
    } catch (_) {
      _hasError.value = true;
    } finally {
      _isLoading.value = false;
    }
  }

  void _showFilterSheet() {
    _SortOption tempSort = _activeSortOption;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
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
                        onPressed: () {
                          setSheetState(() => tempSort = _SortOption.none);
                        },
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
                        Get.back();
                        _fetchProducts(sort: tempSort);
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilter = _activeSortOption != _SortOption.none;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Gilroy',
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: Color(0xff22B241)),
        ),
        actions: [
          GestureDetector(
            onTap: _showFilterSheet,
            child: Container(
              margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: hasActiveFilter ? const Color(0xff22B241) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasActiveFilter ? const Color(0xff22B241) : const Color(0xFFDDE2DF),
                ),
              ),
              child: Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedFilterHorizontal,
                    color: hasActiveFilter ? Colors.white : Colors.black87,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'filter'.tr,
                    style: TextStyle(
                      color: hasActiveFilter ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Gilroy',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            Expanded(
              child: Obx(() {
                if (_isLoading.value) {
                  return const AppLoadingState();
                }
                if (_hasError.value) {
                  return AppErrorState(
                    message: 'Ýalňyşlyk ýüze çykdy.',
                    onRetry: _fetchProducts,
                  );
                }
                if (_products.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'Haryt tapylmady',
                    subtitle: widget.categoryName,
                    onRetry: _fetchProducts,
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.45,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return ProductCard(
                      id: product.id.toString(),
                      title: product.localizedName,
                      price: product.price,
                      oldPrice: product.oldPrice,
                      imageUrl: product.image ?? '',
                      storeName: product.storeName ?? 'Atlas',
                      location: product.location ?? 'Aşgabat',
                      rating: product.rating,
                      onTap: () => Get.to(
                        () => ProductDetailScreen(
                          id: product.id.toString(),
                          title: product.localizedName,
                          imageUrl: product.image ?? '',
                          price: product.price,
                        ),
                        binding: ProductDetailBinding(),
                      ),
                      onCartPressed: () => AppDialogs.showQuickOrderDialog({
                        'id': product.id,
                        'title': product.localizedName,
                        'imageUrl': product.image ?? '',
                        'price': product.price,
                      }),
                    );
                  },
                );
              }),
            ),
          ],
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
