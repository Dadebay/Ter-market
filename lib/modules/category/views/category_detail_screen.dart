import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/core/api/api_service.dart';
import 'package:atlas/models/category_model.dart';
import 'package:atlas/models/product_model.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/widgets/product_card.dart';
import 'package:atlas/widgets/app_loading_state.dart';
import 'package:atlas/widgets/app_empty_state.dart';
import 'package:atlas/widgets/app_dialogs.dart';
import 'package:atlas/modules/product_detail/views/product_detail_screen.dart';
import 'package:atlas/modules/product_detail/bindings/product_detail_binding.dart';

class CategoryDetailScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final _api = ApiService();

  final _subCategories = <SubCategoryModel>[].obs;
  final _products = <ProductModel>[].obs;
  final _categoryName = ''.obs;
  final _isSubLoading = true.obs;
  final _isProductLoading = true.obs;
  final _hasError = false.obs;
  int? _selectedSubCatId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _categoryName.value = widget.categoryName;
    await _fetchCategoryById();
    await _fetchSubCategories();

    if (_subCategories.isNotEmpty) {
      final firstId = _subCategories.first.id;
      _selectedSubCatId = firstId;
      debugPrint('[CategoryDetail] initial selectedSubCatId=$_selectedSubCatId');
      await _fetchProducts(categoryId: widget.categoryId, subCategoryId: firstId);
    } else {
      _selectedSubCatId = null;
      debugPrint('[CategoryDetail] no subcategory, selectedSubCatId=null');
      await _fetchProducts(categoryId: widget.categoryId);
    }
  }

  Future<void> _fetchCategoryById() async {
    try {
      final category = await _api.getCategoryById(widget.categoryId);
      if (category.name.isNotEmpty) {
        _categoryName.value = category.name;
      }
    } catch (_) {
      // fallback to incoming name
    }
  }

  Future<void> _fetchSubCategories() async {
    _isSubLoading.value = true;
    try {
      _subCategories.value = await _api.getSubCategories(categoryId: widget.categoryId);
    } catch (_) {
      // subcategories optional
    } finally {
      _isSubLoading.value = false;
    }
  }

  Future<void> _fetchProducts({int? categoryId, int? subCategoryId}) async {
    debugPrint('[CategoryDetail] fetchProducts categoryId=$categoryId subCategoryId=$subCategoryId');
    _isProductLoading.value = true;
    _hasError.value = false;
    try {
      final result = await _api.getProducts(
        categoryId: categoryId,
        subCategoryId: subCategoryId,
      );
      _products.value = result.results;
    } catch (_) {
      _hasError.value = true;
    } finally {
      _isProductLoading.value = false;
    }
  }

  void _selectSubCategory(int? id) {
    debugPrint('[CategoryDetail] tapped subcategory id=$id (prev=$_selectedSubCatId)');
    setState(() {
      _selectedSubCatId = id;
    });
    _fetchProducts(categoryId: widget.categoryId, subCategoryId: id);
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
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
        ),
        title: Obx(
          () => Text(
            _categoryName.value.isEmpty ? widget.categoryName : _categoryName.value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Gilroy',
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Horizontal subcategory chips ──
          Obx(() {
            if (_isSubLoading.value) {
              return const SizedBox(
                height: 52,
                child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))),
              );
            }
            if (_subCategories.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: 52,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _subCategories.length + 1, // +1 for "Ählisi"
                itemBuilder: (context, index) {
                  final isAll = index == 0;
                  final subCat = isAll ? null : _subCategories[index - 1];
                  final isSelected = isAll ? _selectedSubCatId == null : _selectedSubCatId == subCat!.id;
                  return _buildChip(
                    label: isAll ? 'Ählisi' : subCat!.name,
                    isSelected: isSelected,
                    onTap: () => _selectSubCategory(isAll ? null : subCat?.id),
                  );
                },
              ),
            );
          }),
          // ── Divider ──
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          // ── Products grid ──
          Expanded(
            child: Obx(() {
              if (_isProductLoading.value) {
                return const AppLoadingState();
              }
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
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.45,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return ProductCard(
                    id: product.id.toString(),
                    title: product.name,
                    price: product.price,
                    oldPrice: product.oldPrice,
                    imageUrl: product.image ?? '',
                    storeName: product.storeName ?? 'Ter Market',
                    location: product.location ?? 'Aşgabat',
                    rating: product.rating,
                    onTap: () => Get.to(
                      () => ProductDetailScreen(
                        id: product.id.toString(),
                        title: product.name,
                        imageUrl: product.image ?? '',
                        price: product.price,
                      ),
                      binding: ProductDetailBinding(),
                    ),
                    onCartPressed: () => AppDialogs.showQuickOrderDialog({
                      'id': product.id,
                      'title': product.name,
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
