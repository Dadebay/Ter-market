import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/modules/product_detail/bindings/product_detail_binding.dart';
import 'package:atlas/modules/product_detail/views/product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  static const List<Map<String, dynamic>> _products = [
    {
      'title': 'A4,A3 Kagyz (500 saypa)',
      'image': 'assets/images/kagyz.jpg',
      'price': 45.0,
      'category': 'Kagyzlar',
    },
    {
      'title': 'Gara Galamlar (12-li set)',
      'image': 'assets/images/renk.jpg',
      'price': 25.0,
      'category': 'Galamlar',
    },
    {
      'title': 'Yapyşdyryjy kleý 50ml',
      'image': 'assets/images/galamlar.jpg',
      'price': 12.0,
      'category': 'Kleý',
    },
    {
      'title': 'Depder Kagyz',
      'image': 'assets/images/renk.jpg',
      'price': 35.0,
      'category': 'Defterly',
    },
  ];

  static const List<String> _recentSearches = [
    'A4,A3 Kagyz',
    'Gara Galamlar',
    'Yapyşdyryjy kleý',
    'Depder Kagyz',
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    if (_query.trim().isEmpty) {
      return _products;
    }
    final q = _query.toLowerCase();
    return _products
        .where(
          (item) =>
              (item['title'] as String).toLowerCase().contains(q) ||
              (item['category'] as String).toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: Get.back,
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowLeft01,
                          color: Color(0xff22B241),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'search'.tr,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Gilroy',
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F3),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE6ECE8)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: (value) => setState(() => _query = value),
                      style: const TextStyle(
                        fontFamily: 'Gilroy',
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'search_hint'.tr,
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedSearch01,
                          color: Colors.grey,
                          size: 20,
                        ),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                                icon: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedCancel01,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [
                  if (_query.isEmpty) ...[
                    Text(
                      'recent_searches'.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Gilroy',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _recentSearches
                          .map(
                            (item) => GestureDetector(
                              onTap: () {
                                _searchController.text = item;
                                setState(() => _query = item);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: const Color(0xFFE7ECE8)),
                                ),
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Gilroy',
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 18),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'results'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Gilroy',
                        ),
                      ),
                      Text(
                        '${filtered.length} ${'products'.tr}',
                        style: const TextStyle(
                          color: Color(0xff22B241),
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Gilroy',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (filtered.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE7ECE8)),
                      ),
                      child: Column(
                        children: [
                          const HugeIcon(
                            icon: HugeIcons.strokeRoundedSearchRemove,
                            color: Colors.grey,
                            size: 30,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'no_results'.tr,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Gilroy',
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...filtered.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _SearchResultCard(item: item),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _SearchResultCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(
        () => ProductDetailScreen(
          title: item['title'] as String,
          imageUrl: item['image'] as String,
          price: item['price'] as double,
        ),
        binding: ProductDetailBinding(),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7ECE8)),
        ),
        child: Row(
          children: [
            Container(
              width: 82,
              height: 82,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  item['image'] as String,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['category'] as String,
                      style: const TextStyle(
                        color: Color(0xff22B241),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Gilroy',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['title'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Gilroy',
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${(item['price'] as double).toStringAsFixed(0)} TMT',
                      style: const TextStyle(
                        color: Color(0xff22B241),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Gilroy',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                color: Color(0xFF97A29D),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
