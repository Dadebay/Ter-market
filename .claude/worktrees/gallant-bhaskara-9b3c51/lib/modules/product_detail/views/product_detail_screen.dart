import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
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
        ['Görnüşi', 'Ofis kagyzy'],
        ['Göwrümi', '500 saypa'],
        ['Ululygy', 'A4 we A3'],
      ],
    },
    'Gara Galamlar (12-li set)': {
      'code': 'gara-galam-12',
      'id': 'AT-1002',
      'seller': 'Sab computers',
      'description':
          '12-li gara galamlar toplumy gündelik ýazgylar, okuw we ofis işleri üçin amatly, ýeňil hem rahat ulanylýar.',
      'specs': [
        ['Görnüşi', 'Gara galam'],
        ['Mukdary', '12 sany'],
        ['Ulanylyşy', 'Okuw we ofis'],
      ],
    },
    'Yapyşdyryjy kleý 50ml': {
      'code': 'kley-50ml',
      'id': 'AT-1003',
      'seller': 'Sab computers',
      'description':
          '50ml ýapyşdyryjy kleý kagyz, karton we ýeňil materiallar üçin çalt we ygtybarly ýapyşdyrma berýär.',
      'specs': [
        ['Görnüşi', 'Kleý'],
        ['Göwrümi', '50 ml'],
        ['Aýratynlygy', 'Çalt gurama'],
      ],
    },
    'Depder Kagyz': {
      'code': 'depder-kagyz',
      'id': 'AT-1004',
      'seller': 'Sab computers',
      'description':
          'Depder kagyz okuwçylar we ofis üçin amatly, arassa ak we ýumşak ýazylýan gurluşa eýe önümdir.',
      'specs': [
        ['Görnüşi', 'Depder kagyz'],
        ['Sahypa', 'Standart'],
        ['Ulanylyşy', 'Okuw we ýazgy'],
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
          'description': 'Bu haryt barada maglumat ýakynda goşular.',
          'specs': [
            ['Görnüşi', 'Standart'],
            ['Göwrümi', '-'],
            ['Aýratynlygy', '-'],
          ],
        };
    final specs = (data['specs'] as List)
        .map((e) => e as List<dynamic>)
        .toList(growable: false);
    final imageList = List<String>.filled(4, imageUrl);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
                  ? Icon(
                      Icons.favorite,
                      color: Colors.red,
                    )
                  : HugeIcon(
                      icon: HugeIcons.strokeRoundedFavourite,
                      color: const Color(0xff22B241),
                    ),
            );
          }),
          IconButton(
            onPressed: () => Get.find<MainController>().changeIndex(3),
            icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedShoppingCart01,
                color: Color(0xff22B241)),
          ),
          IconButton(
            onPressed: () {},
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
                  // Image Carousel Section
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        height: 400,
                        width: double.infinity,
                        child: PageView.builder(
                          onPageChanged: (idx) => controller.changeImage(idx),
                          itemCount: imageList.length,
                          itemBuilder: (context, index) {
                            return Padding(
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
                                    ),
                            );
                          },
                        ),
                      ),
                      // Tags
                      Positioned(
                        top: 10,
                        left: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTag('Kartdan töleg', const Color(0xFF22B241)),
                            const SizedBox(height: 8),
                            _buildTag('Onlaýn töleg', const Color(0xFFFFB7E5)),
                          ],
                        ),
                      ),
                      // Indicators
                      Positioned(
                        bottom: 20,
                        child: Obx(() => Row(
                              children:
                                  List.generate(imageList.length, (index) {
                                bool isSelected =
                                    controller.selectedImage.value == index;
                                return Container(
                                  width: 8,
                                  height: 8,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? const Color(0xff22B241)
                                        : Colors.grey.withOpacity(0.3),
                                  ),
                                );
                              }),
                            )),
                      ),
                    ],
                  ),
                  const Divider(
                      height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                  // Info Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rating row
                        Row(
                          children: [
                            const Text(
                              '0.0',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: List.generate(
                                  5,
                                  (index) => const Icon(Icons.star_border,
                                      color: Color(0xff22B241), size: 18)),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '| 0 Teswir',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Title
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Details
                        _buildDetailRow(
                            'Harydyň kody:', data['code'] as String),
                        const SizedBox(height: 10),
                        _buildDetailRow('Gerekli ID:', data['id'] as String),
                        const SizedBox(height: 10),
                        // Seller row
                        Row(
                          children: [
                            const Text(
                              'Satyjy:',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              data['seller'] as String,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xff22B241),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios,
                                color: Color(0xff22B241), size: 12),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Additional Data Sections
                        const Text(
                          'Düşündiriş',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Gilroy'),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          data['description'] as String,
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.7),
                              height: 1.5),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Harydyň aýratynlyklary',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Gilroy'),
                        ),
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
          // Bottom Bar with SafeArea
          _buildBottomBar(),
        ],
      ),
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

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
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
                  child: const Text(
                    'Sargyt etmek',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
