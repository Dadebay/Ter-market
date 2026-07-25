// ignore_for_file: deprecated_member_use

import 'package:atlas/themes/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:atlas/modules/product_detail/controllers/product_detail_controller.dart';
import 'package:atlas/modules/main/controllers/feature_controllers.dart';
import 'package:atlas/modules/profile/controllers/language_controller.dart';
import 'package:atlas/widgets/app_dialogs.dart';
import 'package:atlas/utils/price_format.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  final String title;
  final String imageUrl;
  final double price;
  final double? oldPrice;
  final List<String> images;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.title,
    this.imageUrl = '',
    required this.price,
    this.oldPrice,
    this.images = const [],
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductDetailController _ctrl;
  late CartController _cartCtrl;
  late PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<ProductDetailController>();
    _cartCtrl = Get.find<CartController>();
    _pageCtrl = PageController();
    _ctrl.loadProduct(widget.productId);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  List<String> get _images {
    final p = _ctrl.product.value;
    if (p != null && p.allImages.isNotEmpty) return p.allImages;
    if (widget.images.isNotEmpty) return widget.images;
    if (widget.imageUrl.isNotEmpty) return [widget.imageUrl];
    return [];
  }

  String get _localizedDescription {
    final p = _ctrl.product.value;
    if (p == null) return '';
    try {
      final lang = Get.find<LanguageController>().selectedLanguage.value;
      final desc = lang == 'ru' ? (p.descriptionRu ?? '') : (p.descriptionTk ?? '');
      return desc.isNotEmpty ? desc : (p.description ?? '');
    } catch (_) {
      return p.description ?? '';
    }
  }

  String get _localizedCategoryName {
    final p = _ctrl.product.value;
    return p?.categoryName ?? '';
  }

  String get _localizedSubCategoryName {
    final p = _ctrl.product.value;
    return p?.subCategoryName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (_ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xff22B241)));
        }
        final product = _ctrl.product.value;
        final displayTitle = product?.localizedName ?? widget.title;
        final displayPrice = product?.price ?? widget.price;
        final displayOldPrice = product?.oldPrice ?? widget.oldPrice;
        final discountPct = product?.discount;
        final imgs = _images;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image carousel
                    if (imgs.isNotEmpty) ...[
                      SizedBox(
                        height: 300,
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _pageCtrl,
                              itemCount: imgs.length,
                              onPageChanged: _ctrl.changeImage,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () => _openFullscreen(imgs, index),
                                  child: Hero(
                                    tag: 'product_${widget.productId}_$index',
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      child: _buildImage(imgs[index]),
                                    ),
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              right: 20,
                              bottom: 16,
                              child: Opacity(
                                opacity: 0.55,
                                child: Image.asset(
                                  'assets/images/logo_width.png',
                                  width: 80,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (imgs.length > 1)
                        Obx(() => Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(imgs.length, (i) {
                                final selected = _ctrl.selectedImage.value == i;
                                return GestureDetector(
                                  onTap: () => _pageCtrl.animateToPage(i, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: selected ? 18 : 8,
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: selected ? AppColors.primary : Colors.grey.withOpacity(0.35),
                                    ),
                                  ),
                                );
                              }),
                            )),
                    ],

                    const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category breadcrumb
                          if (_localizedCategoryName.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Text(
                                    _localizedCategoryName,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (_localizedSubCategoryName.isNotEmpty) ...[
                                    const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
                                    Text(
                                      _localizedSubCategoryName,
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                          // Title
                          Text(
                            displayTitle,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              height: 1.3,
                              fontFamily: 'Gilroy',
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Price
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${_fmt(displayPrice)} TMT',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Gilroy',
                                ),
                              ),
                              if (displayOldPrice != null && displayOldPrice > displayPrice) ...[
                                // const SizedBox(width: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                                  child: Text(
                                    '${_fmt(displayOldPrice)} TMT',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                              ],
                              if (discountPct != null && discountPct > 0) ...[
                                Container(
                                  margin: const EdgeInsets.only(left: 8, bottom: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '-${discountPct.toInt()}%',
                                    style: TextStyle(
                                      color: Colors.red.shade600,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Description
                          Text(
                            'description'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Gilroy',
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _localizedDescription.isNotEmpty ? _localizedDescription : 'no_description'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.65),
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom bar
            _buildBottomBar(displayTitle, displayPrice),
          ],
        );
      }),
    );
  }

  String _fmt(double v) => fmtPrice(v);

  AppBar _buildAppBar() {
    return AppBar(
      scrolledUnderElevation: 0.0,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: AppColors.primary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        Obx(() {
          final favCtrl = Get.find<FavoritesController>();
          final isFav = favCtrl.isFavorited(widget.productId, widget.title);
          return IconButton(
            onPressed: () {
              final p = _ctrl.product.value;
              favCtrl.toggleFavorite({
                'id': widget.productId,
                'title': p?.localizedName ?? widget.title,
                'imageUrl': p?.image ?? widget.imageUrl,
                'price': p?.price ?? widget.price,
              });
              if (!isFav) AppDialogs.showAddedToFavorites();
            },
            icon: isFav
                ? const Icon(Icons.favorite, color: Colors.red)
                : const HugeIcon(
                    icon: HugeIcons.strokeRoundedFavourite,
                    color: AppColors.primary,
                  ),
          );
        }),
        IconButton(
          onPressed: () {
            final p = _ctrl.product.value;
            Share.share('${p?.localizedName ?? widget.title}\n${p?.image ?? widget.imageUrl}');
          },
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedShare01, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildImage(String url) {
    if (url.startsWith('assets')) {
      return Image.asset(url, fit: BoxFit.contain);
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.contain,
      errorWidget: (_, __, ___) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
    );
  }

  void _openFullscreen(List<String> imgs, int initialIndex) {
    final currentIdx = initialIndex.obs;
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, __, ___) => Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.black, size: 28),
            ),
            actions: [
              Obx(() => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Text(
                        '${currentIdx.value + 1} / ${imgs.length}',
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ),
                  )),
            ],
          ),
          body: Stack(
            children: [
              PhotoViewGallery.builder(
                itemCount: imgs.length,
                pageController: PageController(initialPage: initialIndex),
                onPageChanged: (i) => currentIdx.value = i,
                builder: (context, index) {
                  final url = imgs[index];
                  return PhotoViewGalleryPageOptions(
                    imageProvider: url.startsWith('assets') ? AssetImage(url) as ImageProvider : NetworkImage(url),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 4,
                    heroAttributes: PhotoViewHeroAttributes(
                      tag: 'product_${widget.productId}_$index',
                    ),
                  );
                },
                backgroundDecoration: const BoxDecoration(color: Colors.white),
              ),
              const Positioned.fill(
                child: IgnorePointer(
                  child: _WatermarkPattern(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(String title, double price) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Obx(() {
            final qty = _cartCtrl.getQuantity(widget.productId, title);
            if (qty > 0) {
              return Row(
                children: [
                  Text(
                    '${_fmt(price)} TMT',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      fontFamily: 'Gilroy',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _CartCounter(
                      quantity: qty,
                      onDecrement: () => _cartCtrl.changeQuantityByProduct(widget.productId, title, -1),
                      onIncrement: () => _cartCtrl.changeQuantityByProduct(widget.productId, title, 1),
                    ),
                  ),
                ],
              );
            }
            return Row(
              children: [
                Text(
                  '${_fmt(price)} TMT',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    fontFamily: 'Gilroy',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final p = _ctrl.product.value;
                      _cartCtrl.addOrIncrement({
                        'id': widget.productId,
                        'title': title,
                        'imageUrl': p?.image ?? widget.imageUrl,
                        'price': price,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'add_to_cart'.tr,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Gilroy'),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _CartCounter extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _CartCounter({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onDecrement,
            child: const SizedBox(
              width: 50,
              height: 50,
              child: Center(child: Icon(Icons.remove, color: Colors.white, size: 22)),
            ),
          ),
          Text(
            '$quantity',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              fontFamily: 'Gilroy',
            ),
          ),
          GestureDetector(
            onTap: onIncrement,
            child: const SizedBox(
              width: 50,
              height: 50,
              child: Center(child: Icon(Icons.add, color: Colors.white, size: 22)),
            ),
          ),
        ],
      ),
    );
  }
}

class _WatermarkPattern extends StatelessWidget {
  const _WatermarkPattern();

  @override
  Widget build(BuildContext context) {
    const logoW = 90.0;
    const logoH = 28.0;
    const colGap = 150.0;
    const rowGap = 100.0;
    const cols = 5;
    const rows = 12;

    final logo = Opacity(
      opacity: 0.18,
      child: Image.asset(
        'assets/images/logo_width.png',
        width: logoW,
        height: logoH,
        fit: BoxFit.contain,
      ),
    );

    return OverflowBox(
      maxWidth: double.infinity,
      maxHeight: double.infinity,
      alignment: Alignment.center,
      child: Transform.rotate(
        angle: -0.52,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(rows, (row) {
            final stagger = (row % 2 == 0) ? 0.0 : colGap / 2;
            return Padding(
              padding: const EdgeInsets.only(bottom: rowGap - logoH),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: stagger),
                  ...List.generate(
                    cols,
                    (col) => Padding(
                      padding: EdgeInsets.only(right: col < cols - 1 ? colGap - logoW : 0),
                      child: logo,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
