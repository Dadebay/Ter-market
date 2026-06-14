import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/utils/nav.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/modules/search/controllers/product_search_controller.dart';
import 'package:atlas/modules/product_detail/bindings/product_detail_binding.dart';
import 'package:atlas/modules/product_detail/views/product_detail_screen.dart';
import 'package:atlas/models/product_model.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/utils/price_format.dart';
import 'package:iconly/iconly.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _textController = TextEditingController();
  late final ProductSearchController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(ProductSearchController());
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _textController.text = widget.initialQuery!;
      _controller.search(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _controller.search(value);
  }

  void _clearSearch() {
    _textController.clear();
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 60,
        titleSpacing: 12,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        title: Text(
          'search'.tr,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            fontFamily: 'Gilroy',
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F3),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE6ECE8)),
                    ),
                    child: TextField(
                      controller: _textController,
                      autofocus: true,
                      onChanged: _onChanged,
                      style: const TextStyle(
                        fontFamily: 'Gilroy',
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'search_hint'.tr,
                        hintStyle: const TextStyle(color: Colors.grey),
                        contentPadding: const EdgeInsets.only(left: 14, top: 18, bottom: 6, right: 8),
                        prefixIcon: Icon(
                          IconlyLight.search,
                          color: Colors.grey,
                          size: 20,
                        ),
                        suffixIcon: Obx(
                          () => _controller.query.value.isEmpty
                              ? const SizedBox.shrink()
                              : IconButton(
                                  onPressed: _clearSearch,
                                  icon: Icon(
                                    IconlyLight.search,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                final q = _controller.query.value;
                final isLoading = _controller.isLoading.value;
                final hasError = _controller.hasError.value;
                final results = _controller.results;

                if (q.isEmpty) {
                  return Obx(() {
                    final history = _controller.searchHistory;
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'recent_searches'.tr,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Gilroy',
                              ),
                            ),
                            if (history.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _controller.clearSearchHistory();
                                },
                                child: Text(
                                  'clear_all'.tr,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Gilroy',
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (history.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text(
                                'no_recent_searches'.tr,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Gilroy',
                                ),
                              ),
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: history
                                .map(
                                  (item) => GestureDetector(
                                    onTap: () {
                                      _textController.text = item;
                                      _controller.search(item);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: const Color(0xFFE7ECE8)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            item,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Gilroy',
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          GestureDetector(
                                            onTap: () {
                                              _controller.removeFromSearchHistory(item);
                                            },
                                            child: const HugeIcon(
                                              icon: HugeIcons.strokeRoundedCancel01,
                                              color: Colors.grey,
                                              size: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                      ],
                    );
                  });
                }

                if (isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedWifiOff01,
                          color: Colors.grey,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'error_occurred'.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => _controller.search(q),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'retry'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Gilroy',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  children: [
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
                          '${results.length} ${'products'.tr}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (results.isEmpty)
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
                      ...results.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _SearchResultCard(product: item),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final ProductModel product;

  const _SearchResultCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Nav.push(
        context,
        () => ProductDetailScreen(
          productId: product.id,
          title: product.localizedName,
          imageUrl: product.image ?? '',
          price: product.price,
          oldPrice: product.oldPrice,
          images: product.allImages,
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
                child: product.image != null && product.image!.isNotEmpty
                    ? (product.image!.startsWith('assets')
                        ? Image.asset(
                            product.image!,
                            fit: BoxFit.contain,
                          )
                        : CachedNetworkImage(
                            imageUrl: product.image!,
                            fit: BoxFit.contain,
                            errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                            progressIndicatorBuilder: (_, __, progress) => Center(
                              child: CircularProgressIndicator(
                                value: progress.progress,
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          ))
                    : const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.discount != null && product.discount! > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${product.discount!.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      product.localizedName,
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
                    Row(
                      children: [
                        Text(
                          '${fmtPrice(product.price)} TMT',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                        if (product.oldPrice != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '${fmtPrice(product.oldPrice!)} TMT',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Gilroy',
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
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
