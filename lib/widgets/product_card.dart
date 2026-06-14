// ignore_for_file: deprecated_member_use

import 'package:atlas/themes/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/modules/main/controllers/feature_controllers.dart';
import 'package:atlas/utils/price_format.dart';
import 'package:atlas/widgets/app_dialogs.dart';
import 'package:iconly/iconly.dart';

class ProductCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final double price;
  final double? oldPrice;
  final String? discount;
  final double rating;
  final String location;
  final String storeName;
  final bool showNewTag;
  final dynamic id;
  final String? description;
  final String? brandIcon;
  final VoidCallback onTap;
  final VoidCallback? onCartPressed;

  const ProductCard({
    super.key,
    this.title = 'Ýumoş Extra "Amber" konsentrirlenen geýim ...',
    this.imageUrl = 'assets/images/galam.jpg',
    this.price = 65.0,
    this.oldPrice,
    this.discount,
    this.rating = 0.0,
    this.location = 'Aşgabat',
    this.storeName = 'Sab computers',
    this.showNewTag = true,
    this.id,
    this.description,
    this.brandIcon,
    required this.onTap,
    this.onCartPressed,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late CartController _cartController;

  @override
  void initState() {
    super.initState();
    _cartController = Get.find<CartController>();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('┌─── ProductCard tapped ────────────────────────');
        print('│ id:       ${widget.id}');
        print('│ title:    ${widget.title}');
        print('│ price:    ${widget.price}');
        print('│ oldPrice: ${widget.oldPrice}');
        print('│ discount: ${widget.discount}');
        print('│ imageUrl: ${widget.imageUrl}');
        print('└───────────────────────────────────────────────');
        widget.onTap();
      },
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    color: const Color(0xFFF9F9F9),
                    child: widget.imageUrl.startsWith('assets')
                        ? Image.asset(widget.imageUrl, fit: BoxFit.contain)
                        : CachedNetworkImage(
                            imageUrl: widget.imageUrl,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.image, size: 40, color: Colors.grey),
                          ),
                  ),
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: Opacity(
                      opacity: 0.55,
                      child: Image.asset(
                        'assets/images/logo_width.png',
                        width: 56,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  if (widget.discount != null && widget.discount!.isNotEmpty && widget.discount != '0')
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${widget.discount}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 3, bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: fmtPrice(widget.price),
                                style: TextStyle(
                                  color: widget.oldPrice != null && widget.oldPrice! > widget.price ? Colors.red : Colors.black,
                                  fontSize: 17,
                                  fontFamily: 'Gilroy',
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(
                                text: ' TMT',
                                style: TextStyle(
                                  color: widget.oldPrice != null && widget.oldPrice! > widget.price ? Colors.red : Colors.black,
                                  fontSize: 12,
                                  fontFamily: 'Gilroy',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.oldPrice != null && widget.oldPrice! > widget.price) ...[
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: fmtPrice(widget.oldPrice!),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Gilroy',
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: Colors.grey,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' TMT',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                      fontFamily: 'Gilroy',
                                      fontWeight: FontWeight.w400,
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Obx(() {
                    final qty = _cartController.getQuantity(widget.id, widget.title);
                    if (qty > 0) {
                      return GestureDetector(
                        onTap: () {}, // Prevents tap from propagating to parent
                        child: _QuantityCounter(
                          quantity: qty,
                          onDecrement: () => _cartController.changeQuantityByProduct(widget.id, widget.title, -1),
                          onIncrement: () => _cartController.changeQuantityByProduct(widget.id, widget.title, 1),
                        ),
                      );
                    }
                    return Row(
                      children: [
                        Obx(() {
                          final favCtrl = Get.find<FavoritesController>();
                          final isFav = favCtrl.isFavorited(widget.id, widget.title);
                          return GestureDetector(
                            onTap: () {
                              favCtrl.toggleFavorite({
                                'id': widget.id,
                                'title': widget.title,
                                'imageUrl': widget.imageUrl,
                                'price': widget.price,
                                'rating': widget.rating,
                              });
                              if (!isFav) AppDialogs.showAddedToFavorites();
                            },
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isFav ? Colors.red : AppColors.primary,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Icon(
                                  isFav ? IconlyBold.heart : IconlyLight.heart,
                                  color: isFav ? Colors.red : AppColors.primary,
                                  size: 17,
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(width: 6),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _cartController.addOrIncrement({
                              'id': widget.id,
                              'title': widget.title,
                              'imageUrl': widget.imageUrl,
                              'price': widget.price,
                              'rating': widget.rating,
                            }),
                            child: Container(
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedShoppingCart01,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityCounter extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityCounter({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onDecrement,
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: Icon(Icons.remove, color: Colors.white, size: 18),
              ),
            ),
          ),
          Text(
            '$quantity',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          GestureDetector(
            onTap: onIncrement,
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: Icon(Icons.add, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
