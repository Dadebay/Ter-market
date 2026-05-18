// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/modules/main/controllers/feature_controllers.dart';
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
      onTap: widget.onTap,
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    height: 155,
                    width: double.infinity,
                    color: const Color(0xFFF9F9F9),
                    child: widget.imageUrl.startsWith('assets')
                        ? Image.asset(widget.imageUrl, fit: BoxFit.cover)
                        : Image.network(
                            widget.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 40, color: Colors.grey),
                          ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Obx(() {
                    final favoritesController = Get.find<FavoritesController>();
                    final bool isFavorited = favoritesController.isFavorited(widget.id, widget.title);

                    return _FavoriteButton(
                      isFavorited: isFavorited,
                      onToggle: () {
                        favoritesController.toggleFavorite({
                          'id': widget.id,
                          'title': widget.title,
                          'imageUrl': widget.imageUrl,
                          'price': widget.price,
                          'rating': widget.rating,
                        });
                        if (!isFavorited) {
                          AppDialogs.showAddedToFavorites();
                        }
                      },
                    );
                  }),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 4),
                    child: Text(
                      '${widget.price.toStringAsFixed(0)} TMT',
                      style: const TextStyle(
                        color: Color(0xff22B241),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Obx(
                    () {
                      final qty = _cartController.getQuantity(widget.id, widget.title);
                      if (qty > 0) {
                        return _QuantityCounter(
                          quantity: qty,
                          onDecrement: () => _cartController.changeQuantityByProduct(widget.id, widget.title, -1),
                          onIncrement: () => _cartController.changeQuantityByProduct(widget.id, widget.title, 1),
                        );
                      }
                      return GestureDetector(
                        onTap: () => _cartController.addOrIncrement({
                          'id': widget.id,
                          'title': widget.title,
                          'imageUrl': widget.imageUrl,
                          'price': widget.price,
                          'rating': widget.rating,
                        }),
                        child: Container(
                          width: double.infinity,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xff22B241)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedShoppingCart01,
                              color: Color(0xff22B241),
                              size: 20,
                            ),
                          ),
                        ),
                      );
                    },
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
        color: const Color(0xff22B241),
        borderRadius: BorderRadius.circular(8),
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

class _FavoriteButton extends StatefulWidget {
  final bool isFavorited;
  final VoidCallback onToggle;

  const _FavoriteButton({
    required this.isFavorited,
    required this.onToggle,
  });

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant _FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorited != oldWidget.isFavorited) {
      if (widget.isFavorited) {
        _controller.forward().then((_) => _controller.reverse());
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: widget.onToggle,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: widget.isFavorited
              ? Icon(
                  IconlyBold.heart,
                  color: Colors.red,
                  size: 16,
                )
              : const HugeIcon(
                  icon: HugeIcons.strokeRoundedFavourite,
                  color: Color(0xff22B241),
                  size: 16,
                ),
        ),
      ),
    );
  }
}
