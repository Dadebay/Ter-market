import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/modules/home/controllers/home_controller.dart';
import 'package:atlas/modules/home/widgets/home_widgets.dart';
import 'package:atlas/modules/product/controllers/product_controller.dart';
import 'package:atlas/models/product_model.dart';
import 'package:atlas/modules/category/controllers/category_controller.dart';
import 'package:atlas/modules/category/views/category_detail_screen.dart';
import 'package:atlas/widgets/app_network_image.dart';
import 'package:atlas/widgets/product_card.dart';
import 'package:atlas/widgets/app_dialogs.dart';
import 'package:atlas/widgets/app_loading_state.dart';
import 'package:atlas/modules/main/controllers/feature_controllers.dart';
import 'package:atlas/modules/main/controllers/main_controller.dart';
import 'package:atlas/modules/product_detail/views/product_detail_screen.dart';
import 'package:atlas/modules/product_detail/bindings/product_detail_binding.dart';
import 'package:atlas/modules/home/views/contact_page.dart';
import 'package:atlas/modules/search/views/search_screen.dart';
import 'package:iconly/iconly.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<CartController>();
    Get.find<MainController>();
    final productController = Get.find<ProductController>();
    final categoryController = Get.find<CategoryController>();
    final searchController = TextEditingController();

    void onCartPressed(ProductModel product) {
      AppDialogs.showQuickOrderDialog({
        'id': product.id,
        'title': product.localizedName,
        'imageUrl': product.image ?? '',
        'price': product.price,
      });
    }

    void onProductTap(ProductModel product) {
      Get.to(
        () => ProductDetailScreen(
          productId: product.id,
          title: product.localizedName,
          imageUrl: product.image ?? '',
          price: product.price,
          oldPrice: product.oldPrice,
          images: product.allImages,
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
        toolbarHeight: 60,
        titleSpacing: 12,
        title: Row(
          children: [
            Expanded(
              child: RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Ter ',
                      style: TextStyle(
                        color: Color(0xFF4B2AA4),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Gilroy',
                      ),
                    ),
                    TextSpan(
                      text: 'Market',
                      style: TextStyle(
                        color: Color(0xFFF5A623),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Gilroy',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── Sağ: sadece arama ikonu ──
            GestureDetector(
              onTap: () => Get.to(() => const ContactPage()),
              child: Icon(FeatherIcons.phoneCall, color: Colors.black87, size: 20),
            ),
            const SizedBox(width: 4),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE0E0E0),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'search_hint'.tr,
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 15,
                              fontFamily: 'Gilroy',
                              fontWeight: FontWeight.w500,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              Get.to(() => SearchScreen(initialQuery: value));
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        final query = searchController.text.trim();
                        if (query.isNotEmpty) {
                          Get.to(() => SearchScreen(initialQuery: query));
                        } else {
                          Get.to(() => const SearchScreen());
                        }
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4B2AA4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          IconlyLight.search,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const BannerCarousel(),
              _buildCategorySection(categoryController),
              _buildSectionHeader(
                'discounts'.tr,
                () {
                  Get.to(() => CategoryDetailScreen(
                        categoryName: 'discounts'.tr,
                        initialFilter: 'price_high',
                      ));
                },
              ),
              Obx(() {
                if (productController.isLoadingDiscounted.value) {
                  return const SizedBox(height: 350, child: AppLoadingState());
                }
                if (productController.discountedProducts.isEmpty) {
                  return const SizedBox(height: 100);
                }
                return SizedBox(
                  height: 270,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    itemCount: productController.discountedProducts.length,
                    itemBuilder: (context, index) {
                      final product = productController.discountedProducts[index];
                      return Padding(
                        padding: EdgeInsets.only(right: index == productController.discountedProducts.length - 1 ? 0 : 8),
                        child: ProductCard(
                          id: product.id.toString(),
                          imageUrl: product.image ?? '',
                          title: product.localizedName,
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
              const SizedBox(height: 40),
              _buildSectionHeader(
                'new_products'.tr,
                () {
                  Get.to(() => CategoryDetailScreen(
                        categoryName: 'new_products'.tr,
                        initialFilter: 'newest',
                      ));
                },
              ),
              Obx(() {
                if (productController.isLoadingNew.value) {
                  return const SizedBox(height: 350, child: AppLoadingState());
                }
                if (productController.newProducts.isEmpty) {
                  return const SizedBox(height: 100);
                }
                return SizedBox(
                  height: 350,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    itemCount: productController.newProducts.length,
                    itemBuilder: (context, index) {
                      final product = productController.newProducts[index];
                      return Padding(
                        padding: EdgeInsets.only(right: index == productController.newProducts.length - 1 ? 0 : 8),
                        child: ProductCard(
                          id: product.id.toString(),
                          imageUrl: product.image ?? '',
                          title: product.localizedName,
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

  Widget _buildCategorySection(CategoryController categoryController) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'sections'.tr,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontFamily: 'Gilroy',
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 25),
          Obx(() {
            if (categoryController.isLoading.value) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (categoryController.categories.isEmpty) {
              return const SizedBox.shrink();
            }
            // Display up to 8 categories in a 4x2 grid
            final displayCategories = categoryController.categories.take(12).toList();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.70,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: displayCategories.length,
                itemBuilder: (context, index) {
                  final category = displayCategories[index];
                  return _buildCategoryCard(category);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(category) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => CategoryDetailScreen(
            categoryId: category.id,
            categoryName: category.localizedName,
          ),
        );
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (category.image != null)
                  Container(
                    width: 75,
                    height: 65,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: AppNetworkImage(
                        url: category.image!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.category_outlined,
                      size: 28,
                      color: Color(0xFF4B2AA4),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 6, left: 6),
            child: Text(
              category.localizedName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFamily: 'Gilroy',
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, right: 16, left: 16, bottom: 20),
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
            child: Text(
              'see_all'.tr,
              style: const TextStyle(
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
