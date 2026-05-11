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
  State<SubCategoryProductScreen> createState() =>
      _SubCategoryProductScreenState();
}

class _SubCategoryProductScreenState extends State<SubCategoryProductScreen> {
  final _api = ApiService();
  final _products = <ProductModel>[].obs;
  final _isLoading = true.obs;
  final _hasError = false.obs;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    _isLoading.value = true;
    _hasError.value = false;
    try {
      final result = await _api.getProducts(
        categoryId: widget.categoryId,
        subCategoryId: widget.subCategoryId,
      );
      _products.value = result.results;
    } catch (_) {
      _hasError.value = true;
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              color: Color(0xff22B241)),
        ),
        actions: [
          _buildTopAction(HugeIcons.strokeRoundedVerticalResize, null),
          _buildTopAction(null, 'Filter'),
          const SizedBox(width: 16),
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
                      title: product.name,
                      price: product.price,
                      oldPrice: product.oldPrice,
                      imageUrl: product.image ?? '',
                      storeName: product.storeName ?? 'Atlas',
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
      ),
    );
  }

  Widget _buildTopAction(IconData? icon, String? text) {
    return Container(
      margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Center(
        child: Row(
          children: [
            if (icon != null) ...[
              HugeIcon(icon: icon, color: Colors.black, size: 20),
              if (text != null) const SizedBox(width: 8),
            ],
            if (text != null)
              Text(
                text,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Gilroy',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
