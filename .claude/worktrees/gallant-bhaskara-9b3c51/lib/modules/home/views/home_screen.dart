import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/modules/home/controllers/home_controller.dart';
import 'package:atlas/modules/home/widgets/home_widgets.dart';
import 'package:atlas/modules/product/controllers/product_controller.dart';
import 'package:atlas/models/product_model.dart';
import 'package:atlas/widgets/product_card.dart';
import 'package:atlas/widgets/app_dialogs.dart';
import 'package:atlas/widgets/app_loading_state.dart';
import 'package:atlas/modules/main/controllers/feature_controllers.dart';
import 'package:atlas/modules/main/controllers/main_controller.dart';
import 'package:atlas/modules/category/views/sub_category_product_screen.dart';
import 'package:atlas/modules/search/views/search_screen.dart';
import 'package:atlas/modules/product_detail/views/product_detail_screen.dart';
import 'package:atlas/modules/product_detail/bindings/product_detail_binding.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<CartController>();
    Get.find<MainController>();
    final productController = Get.find<ProductController>();

    void onCartPressed(ProductModel product) {
      AppDialogs.showQuickOrderDialog({
        'id': product.id,
        'title': product.name,
        'imageUrl': product.image ?? '',
        'price': product.price,
      });
    }

    void onProductTap(ProductModel product) {
      Get.to(
        () => ProductDetailScreen(
          id: product.id.toString(),
          title: product.name,
          imageUrl: product.image ?? '',
          price: product.price,
        ),
        binding: ProductDetailBinding(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 55,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 70,
              errorBuilder: (context, error, stackTrace) => const Text(
                'Atlas',
                style: TextStyle(
                    color: Color(0xff22B241), fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => Get.to(() => const SearchScreen()),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: const Row(
                    children: [
                      HugeIcon(
                          icon: HugeIcons.strokeRoundedSearch01,
                          color: Colors.grey,
                          size: 20),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Gözleg',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xff22B241),
        onRefresh: () async {
          await Future.wait([
            productController.fetchDiscountedProducts(),
            productController.fetchNewProducts(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 45,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  children: [
                    _buildNavCard('Dükanlar',
                        HugeIcons.strokeRoundedShoppingBag01,
                        const Color(0xFFF2F2F2)),
                    _buildNavCard('Brendler',
                        HugeIcons.strokeRoundedWardrobe01,
                        const Color(0xFFF2F2F2)),
                    _buildNavCard('Bazarlar',
                        HugeIcons.strokeRoundedStore01,
                        const Color(0xFFF2F2F2)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const BannerCarousel(),
              const SizedBox(height: 16),
              _buildSectionHeader(
                'Arzanladyşlar',
                () => Get.to(
                  () => const SubCategoryProductScreen(
                      categoryName: 'Arzanladyşlar'),
                ),
              ),
              const SizedBox(height: 7),
              Obx(() {
                if (productController.isLoadingDiscounted.value) {
                  return const SizedBox(
                    height: 350,
                    child: AppLoadingState(),
                  );
                }
                if (productController.discountedProducts.isEmpty) {
                  return const SizedBox(height: 100);
                }
                return SizedBox(
                  height: 350,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: productController.discountedProducts.length,
                    itemBuilder: (context, index) {
                      final product =
                          productController.discountedProducts[index];
                      return Padding(
                        padding: EdgeInsets.only(
                            right: index ==
                                    productController.discountedProducts.length - 1
                                ? 0
                                : 8),
                        child: ProductCard(
                          id: product.id.toString(),
                          imageUrl: product.image ?? '',
                          title: product.name,
                          price: product.price,
                          oldPrice: product.oldPrice,
                          rating: product.rating,
                          storeName: product.storeName ?? 'Atlas',
                          location: product.location ?? 'Aşgabat',
                          onTap: () => onProductTap(product),
                          onCartPressed: () => onCartPressed(product),
                        ),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 15),
              _buildSectionHeader(
                'Täze harytlar',
                () => Get.to(
                  () => const SubCategoryProductScreen(
                      categoryName: 'Täze harytlar'),
                ),
              ),
              const SizedBox(height: 7),
              Obx(() {
                if (productController.isLoadingNew.value) {
                  return const SizedBox(
                    height: 350,
                    child: AppLoadingState(),
                  );
                }
                if (productController.newProducts.isEmpty) {
                  return const SizedBox(height: 100);
                }
                return SizedBox(
                  height: 350,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: productController.newProducts.length,
                    itemBuilder: (context, index) {
                      final product = productController.newProducts[index];
                      return Padding(
                        padding: EdgeInsets.only(
                            right:
                                index == productController.newProducts.length - 1
                                    ? 0
                                    : 8),
                        child: ProductCard(
                          id: product.id.toString(),
                          imageUrl: product.image ?? '',
                          title: product.name,
                          price: product.price,
                          oldPrice: product.oldPrice,
                          rating: product.rating,
                          storeName: product.storeName ?? 'Atlas',
                          location: product.location ?? 'Aşgabat',
                          showNewTag: true,
                          onTap: () => onProductTap(product),
                          onCartPressed: () => onCartPressed(product),
                        ),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavCard(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(
            icon: icon,
            color: const Color(0xff22B241),
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Gilroy'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: 'Gilroy',
              letterSpacing: -0.5,
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'Hemmesini gör',
              style: TextStyle(
                color: Color(0xff22B241),
                fontWeight: FontWeight.w700,
                fontFamily: 'Gilroy',
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
