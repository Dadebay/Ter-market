import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
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

// Müşteri hizmetleri numaraları — buradan kolayca değiştirebilirsin
const _contactNumbers = [
  {'label': 'Müşteri hizmetleri', 'number': '+99361000001'},
  {'label': 'Teknik destek', 'number': '+99361000002'},
  {'label': 'Sipariş takip', 'number': '+99361000003'},
];

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
        toolbarHeight: 60,
        titleSpacing: 12,
        title: Row(
          children: [
            // ── Telefon ikonu ──
            GestureDetector(onTap: () => _showContactDialog(context), child: Icon(FeatherIcons.phoneCall, color: Colors.black87, size: 20)),
            const SizedBox(width: 10),
            // ── "Ter Market" logo yazısı ──
            Expanded(
              child: RichText(
                textAlign: TextAlign.center,
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
              onTap: () => Get.to(() => const SearchScreen()),
              child: Icon(
                FeatherIcons.search,
                color: Colors.black87,
                size: 20,
              ),
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
              const SizedBox(height: 8),
              const BannerCarousel(),
              const SizedBox(height: 16),
              _buildSectionHeader(
                'Arzanladyşlar',
                () => Get.to(
                  () => const SubCategoryProductScreen(categoryName: 'Arzanladyşlar'),
                ),
              ),
              const SizedBox(height: 7),
              Obx(() {
                if (productController.isLoadingDiscounted.value) {
                  return const SizedBox(height: 350, child: AppLoadingState());
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
                      final product = productController.discountedProducts[index];
                      return Padding(
                        padding: EdgeInsets.only(right: index == productController.discountedProducts.length - 1 ? 0 : 8),
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
                  () => const SubCategoryProductScreen(categoryName: 'Täze harytlar'),
                ),
              ),
              const SizedBox(height: 7),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: productController.newProducts.length,
                    itemBuilder: (context, index) {
                      final product = productController.newProducts[index];
                      return Padding(
                        padding: EdgeInsets.only(right: index == productController.newProducts.length - 1 ? 0 : 8),
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

  void _showContactDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Habarlaşmak',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFamily: 'Gilroy',
              ),
            ),
            const SizedBox(height: 16),
            ..._contactNumbers.map(
              (contact) => _buildContactTile(
                label: contact['label']!,
                number: contact['number']!,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile({required String label, required String number}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: () async {
          final uri = Uri(scheme: 'tel', path: number);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF4B2AA4).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              FeatherIcons.phoneCall,
              color: Color(0xFF4B2AA4),
              size: 20,
            ),
          ),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Gilroy',
          ),
        ),
        subtitle: Text(
          number,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF4B2AA4),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: HugeIcon(
          icon: HugeIcons.strokeRoundedArrowRight01,
          color: Color(0xFF4B2AA4),
          size: 16,
        ),
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
