import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/utils/nav.dart';
import 'package:iconly/iconly.dart';
import 'package:lottie/lottie.dart';
import 'package:atlas/modules/main/controllers/feature_controllers.dart';
import 'package:atlas/modules/product_detail/bindings/product_detail_binding.dart';
import 'package:atlas/modules/product_detail/views/product_detail_screen.dart';
import 'package:atlas/widgets/product_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, required this.fromBottomNavBar});
  final bool fromBottomNavBar;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final FavoritesController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<FavoritesController>();
    // Refresh favorites when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('[FavoritesScreen] Screen opened, refreshing favorites...');
      controller.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: widget.fromBottomNavBar == false
            ? IconButton(
                icon: const Icon(IconlyLight.arrow_left_circle, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              )
            : const SizedBox.shrink(),
        title: Text(
          'favorites'.tr,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'Gilroy',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: _buildFavoritesGrid(),
    );
  }

  Widget _buildFavoritesGrid() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF22B241)),
        );
      }
      if (controller.favoriteItems.isEmpty) {
        return Padding(padding: const EdgeInsets.only(left: 40, right: 40), child: _buildEmptyState());
      }
      final screenWidth = MediaQuery.of(context).size.width;
      final isTablet = screenWidth >= 600;
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 4 : 2,
          childAspectRatio: isTablet ? 0.72 : 0.62,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: controller.favoriteItems.length,
        itemBuilder: (context, index) {
          final product = controller.favoriteItems[index];
          final lang = Get.locale?.languageCode ?? 'tk';
          final title = (lang == 'ru' ? (product['name_ru'] as String? ?? product['title'] as String) : (product['name_tk'] as String? ?? product['title'] as String));
          return ProductCard(
            id: product['id'],
            title: title,
            imageUrl: product['imageUrl'] as String,
            price: (product['price'] is int) ? (product['price'] as int).toDouble() : (product['price'] as double),
            rating: (product['rating'] ?? 0.0) as double,
            onTap: () => Nav.push(
              context,
              () => ProductDetailScreen(
                productId: int.tryParse(product['id']?.toString() ?? '') ?? 0,
                title: title,
                imageUrl: product['imageUrl'] as String,
                price: (product['price'] is int) ? (product['price'] as int).toDouble() : (product['price'] as double),
              ),
              binding: ProductDetailBinding(),
            ),
          );
        },
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // HugeIcon aýryldy, Lottie goşuldy
          SizedBox(
            width: 100,
            height: 100,
            child: Lottie.asset(
              'assets/images/like.json',
              repeat: true,
              animate: true,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'favorites_empty'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Gilroy',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'favorites_empty_desc'.tr,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
