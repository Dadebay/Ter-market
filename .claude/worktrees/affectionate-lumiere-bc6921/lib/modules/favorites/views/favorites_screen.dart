import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
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
        title: const Text('Halanlarym'),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedFilter,
              color: Colors.black,
              size: 22,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedDelete02,
              color: Colors.black,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
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
        return _buildEmptyState();
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
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: const HugeIcon(
              icon: HugeIcons.strokeRoundedFavourite,
              color: Colors.grey,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Sanawyňyz häzir boş',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Gilroy',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Halanan harytlaryňyzy şu ýerde görüp bilersiňiz',
            style: TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
