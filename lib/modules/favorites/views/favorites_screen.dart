import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:atlas/modules/main/controllers/feature_controllers.dart';
import 'package:atlas/modules/product_detail/bindings/product_detail_binding.dart';
import 'package:atlas/modules/product_detail/views/product_detail_screen.dart';
import 'package:atlas/widgets/product_card.dart';

class FavoritesScreen extends GetView<FavoritesController> {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'favorites'.tr,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Gilroy',
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedFilter,
              color: Colors.black,
              size: 22,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildFavoritesGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesGrid() {
    return Obx(() {
      if (controller.favoriteItems.isEmpty) {
        return Padding(
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: _buildEmptyState());
      }
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.45,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: controller.favoriteItems.length,
        itemBuilder: (context, index) {
          final product = controller.favoriteItems[index];
          return ProductCard(
            id: product['id'],
            title: product['title'] as String,
            imageUrl: product['imageUrl'] as String,
            price: (product['price'] is int)
                ? (product['price'] as int).toDouble()
                : (product['price'] as double),
            rating: (product['rating'] ?? 0.0) as double,
            onTap: () => Get.to(
              () => ProductDetailScreen(
                id: product['id'],
                title: product['title'] as String,
                imageUrl: product['imageUrl'] as String,
                price: (product['price'] is int)
                    ? (product['price'] as int).toDouble()
                    : (product['price'] as double),
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
