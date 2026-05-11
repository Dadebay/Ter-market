import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/modules/main/controllers/feature_controllers.dart';

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
  final String? id;
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
        width: 170, // Fixed width for horizontal lists
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image & Tags Stack
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    height: 145,
                    width: double.infinity,
                    color: const Color(0xFFF9F9F9),
                    padding: const EdgeInsets.all(8),
                    child: widget.imageUrl.startsWith('assets')
                        ? Image.asset(widget.imageUrl, fit: BoxFit.contain)
                        : Image.network(
                            widget.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image,
                                    size: 40, color: Colors.grey),
                          ),
                  ),
                ),
                // Tags
                Positioned(
                  top: 8,
                  left: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTag('Onlaýn töleg', const Color(0xFFFFB7E5)),
                      if (widget.showNewTag) ...[
                        const SizedBox(height: 4),
                        _buildTag('Täzelikler', const Color(0xFF007BFF)),
                      ],
                      const SizedBox(height: 4),
                      _buildTag('Kartdan töleg', const Color(0xFF22B241)),
                    ],
                  ),
                ),
                // Favorite
                Positioned(
                  top: 8,
                  right: 8,
                  child: Obx(() {
                    final favoritesController = Get.find<FavoritesController>();
                    final bool isFavorited = favoritesController.isFavorited(
                        widget.id, widget.title);

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
                      },
                    );
                  }),
                ),
              ],
            ),
            // Product Info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating
                  Row(
                    children: [
                      Text(
                        '${widget.rating.toInt()}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 2),
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedStar,
                        color: Color(0xff22B241),
                        size: 14,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Title
                  Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Location
                  Row(
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedLocation01,
                        color: Color(0xff22B241),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.location,
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Store
                  Row(
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedShoppingBag01,
                        color: Color(0xff22B241),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.storeName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Price
                  Text(
                    '${widget.price.toStringAsFixed(0)} TMT',
                    style: const TextStyle(
                      color: Color(0xff22B241),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Cart Button
                  Obx(
                    () => GestureDetector(
                      onTap: widget.onCartPressed,
                      child: Container(
                        width: double.infinity,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xff22B241),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedShoppingCart01,
                            color: _cartController.cartItems.any(
                                    (item) => item['title'] == widget.title)
                                ? const Color(0xff22B241)
                                : Colors.grey,
                            size: 25,
                          ),
                        ),
                      ),
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

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
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

class _FavoriteButtonState extends State<_FavoriteButton>
    with SingleTickerProviderStateMixin {
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
                  Icons.favorite,
                  color: Colors.red,
                  size: 16,
                )
              : HugeIcon(
                  icon: HugeIcons.strokeRoundedFavourite,
                  color: const Color(0xff22B241),
                  size: 16,
                ),
        ),
      ),
    );
  }
}
