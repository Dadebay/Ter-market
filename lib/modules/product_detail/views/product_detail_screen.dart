// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:atlas/modules/product_detail/controllers/product_detail_controller.dart';
import 'package:atlas/modules/main/controllers/feature_controllers.dart';
import 'package:atlas/modules/main/controllers/main_controller.dart';
import 'package:atlas/widgets/app_dialogs.dart';

class ProductDetailScreen extends GetView<ProductDetailController> {
  final String title;
  final String imageUrl;
  final double price;
  final String? id;

  const ProductDetailScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.id,
  });

  static const Map<String, Map<String, dynamic>> _detailsByTitle = {
    'A4,A3 Kagyz (500 saypa)': {
      'code': 'a4-a3-500',
      'id': 'AT-1001',
      'seller': 'Sab computers',
      'description':
          'A4,A3 kagyz toplumy çap etmek, ýazmak we resmi resminamalar üçin amatly ýokary hilli kagyzdyr.',
      'specs': [
        ['product_type', 'Ofis kagyzy'],
        ['product_volume', '500 saypa'],
        ['product_feature', 'A4 we A3'],
      ],
    },
    'Gara Galamlar (12-li set)': {
      'code': 'gara-galam-12',
      'id': 'AT-1002',
      'seller': 'Sab computers',
      'description':
          '12-li gara galamlar toplumy gündelik ýazgylar, okuw we ofis işleri üçin amatly, ýeňil hem rahat ulanylýar.',
      'specs': [
        ['product_type', 'Gara galam'],
        ['product_volume', '12 sany'],
        ['product_feature', 'Okuw we ofis'],
      ],
    },
    'Yapyşdyryjy kleý 50ml': {
      'code': 'kley-50ml',
      'id': 'AT-1003',
      'seller': 'Sab computers',
      'description':
          '50ml ýapyşdyryjy kleý kagyz, karton we ýeňil materiallar üçin çalt we ygtybarly ýapyşdyrma berýär.',
      'specs': [
        ['product_type', 'Kleý'],
        ['product_volume', '50 ml'],
        ['product_feature', 'Çalt gurama'],
      ],
    },
    'Depder Kagyz': {
      'code': 'depder-kagyz',
      'id': 'AT-1004',
      'seller': 'Sab computers',
      'description':
          'Depder kagyz okuwçylar we ofis üçin amatly, arassa ak we ýumşak ýazylýan gurluşa eýe önümdir.',
      'specs': [
        ['product_type', 'Depder kagyz'],
        ['product_volume', 'Standart'],
        ['product_feature', 'Okuw we ýazgy'],
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    final data = _detailsByTitle[title] ??
        {
          'code': 'atlas-product',
          'id': 'AT-0000',
          'seller': 'Sab computers',
          'description': 'product_desc_default'.tr,
          'specs': [
            ['product_type', 'standard'],
            ['product_volume', '-'],
            ['product_feature', '-'],
          ],
        };

    final specs = (data['specs'] as List)
        .map((e) => [e[0].toString().tr, e[1]])
        .toList(growable: false);

    final imageList = List<String>.filled(4, imageUrl);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        leading: IconButton(
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              color: Color(0xff22B241)),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() {
            final favoritesController = Get.find<FavoritesController>();
            final bool isFavorited = favoritesController.isFavorited(id, title);

            return IconButton(
              onPressed: () {
                favoritesController.toggleFavorite({
                  'id': id,
                  'title': title,
                  'imageUrl': imageUrl,
                  'price': price,
                });
              },
              icon: isFavorited
                  ? const Icon(Icons.favorite, color: Colors.red)
                  : const HugeIcon(
                      icon: HugeIcons.strokeRoundedFavourite,
                      color: Color(0xff22B241),
                    ),
            );
          }),
          IconButton(
            onPressed: () {
              final String shareMessage = '$title\n$imageUrl';
              Share.share(shareMessage);
            },
            icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedShare01, color: Color(0xff22B241)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: PageView.builder(
                      onPageChanged: (idx) => controller.changeImage(idx),
                      itemCount: imageList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            _showFullScreenImage(imageList, index);
                          },
                          child: Hero(
                            tag: 'product_image_${id ?? title}_$index',
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: imageList[index].startsWith('assets')
                                  ? Image.asset(
                                      imageList[index],
                                      fit: BoxFit.contain,
                                    )
                                  : Image.network(
                                      imageList[index],
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.broken_image,
                                          size: 50,
                                          color: Colors.grey,
                                        );
                                      },
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(imageList.length, (index) {
                          bool isSelected =
                              controller.selectedImage.value == index;
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? const Color(0xff22B241)
                                  : Colors.grey.withOpacity(0.3),
                            ),
                          );
                        }),
                      )),
                  const Divider(
                      height: 20, thickness: 1, color: Color(0xFFF0F0F0)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const SizedBox(height: 16),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildDetailRow(
                            'product_code'.tr, data['code'] as String),
                        const SizedBox(height: 10),
                        _buildDetailRow('product_id'.tr, data['id'] as String),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text('seller'.tr,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13)),
                            const SizedBox(width: 8),
                            Text(
                              data['seller'] as String,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xff22B241),
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios,
                                color: Color(0xff22B241), size: 12),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text('description'.tr,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Gilroy')),
                        const SizedBox(height: 12),
                        Text(
                          data['description'] as String,
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.7),
                              height: 1.5),
                        ),
                        const SizedBox(height: 32),
                        Text('product_features'.tr,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Gilroy')),
                        const SizedBox(height: 16),
                        _buildSpecItem(HugeIcons.strokeRoundedWaterEnergy,
                            specs[0][0] as String, specs[0][1] as String),
                        _buildSpecItem(HugeIcons.strokeRoundedDroplet,
                            specs[1][0] as String, specs[1][1] as String),
                        _buildSpecItem(HugeIcons.strokeRoundedSun01,
                            specs[2][0] as String, specs[2][1] as String),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  void _showFullScreenImage(List<String> imageList, int initialIndex) {
    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
          ),
        ),
        body: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 5.0,
            child: imageList[initialIndex].startsWith('assets')
                ? Image.asset(
                    imageList[initialIndex],
                    fit: BoxFit.contain,
                  )
                : Image.network(
                    imageList[initialIndex],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image,
                        size: 80,
                        color: Colors.grey,
                      );
                    },
                  ),
          ),
        ),
      ),
      transition: Transition.fadeIn,
    );
  }

  Widget _buildSpecItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              HugeIcon(icon: icon, color: Colors.grey, size: 20),
              const SizedBox(width: 12),
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(width: 8),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Text(
                '${price.toStringAsFixed(0)} TMT',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xff22B241),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    AppDialogs.showQuickOrderDialog({
                      'title': title,
                      'imageUrl': imageUrl,
                      'price': price,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff22B241),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('order_now'.tr,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
