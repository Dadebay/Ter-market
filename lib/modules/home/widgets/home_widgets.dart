import 'dart:async';
import 'package:atlas/modules/home/views/banner_detail_screen.dart';
import 'package:atlas/modules/category/views/category_detail_screen.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/utils/nav.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:atlas/models/banner_model.dart';
import 'package:atlas/modules/home/controllers/banner_controller.dart';
import 'package:atlas/widgets/app_network_image.dart';
import 'package:atlas/modules/main/controllers/feature_controllers.dart';
import 'package:atlas/widgets/app_dialogs.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  // Büyük bir sayıdan başlayarak sonsuz izlenimi veriyoruz
  static const int _multiplier = 1000;
  late PageController _pageController;
  int _realIndex = 0;
  Timer? _timer;
  int _bannerCount = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _initCarousel(int count) {
    if (_bannerCount == count) return; // zaten başlatıldı
    _bannerCount = count;
    _timer?.cancel();

    final startPage = _multiplier ~/ 2 * count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(startPage);
      }
    });

    if (count <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_pageController.hasClients) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  void _handleBannerTap(BannerModel banner) {
    // 1. Eğer banner'da brendId varsa, o brende ait ürünleri göster
    if (banner.brendId != null) {
      Nav.push(
        context,
        () => CategoryDetailScreen(
          brandId: banner.brendId,
          categoryName: banner.title ?? 'Harytlar',
        ),
      );
      return;
    }

    // 2. Eğer banner'da products varsa, hepsini sepete ekle
    if (banner.products != null && banner.products!.isNotEmpty) {
      final cartController = Get.find<CartController>();
      // Ürünleri sessizce ekle (her biri için snackbar gösterme)
      for (final product in banner.products!) {
        cartController.addOrIncrement({
          'id': product.id,
          'title': product.localizedName,
          'imageUrl': product.image ?? '',
          'price': product.price,
          'rating': product.rating,
        }, silent: true);
      }
      // Sonunda tek bir snackbar göster
      AppDialogs.showSnackbar(
        message: '${banner.products!.length} ${'products_added_to_cart'.tr}',
        icon: Icons.shopping_cart_rounded,
        iconColor: const Color(0xFF22B241),
      );
      return;
    }

    // 3. Normal banner davranışı
    final body = banner.body ?? '';
    final isUrl = body.startsWith('http://') || body.startsWith('https://');
    if (isUrl) {
      final uri = Uri.parse(body);
      launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (body.isNotEmpty) {
      Nav.push(
        context,
        () => BannerDetailScreen(
          title: banner.title ?? '',
          imageUrl: banner.image,
          body: body,
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BannerController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return _buildSkeleton();
      }
      if (controller.hasError.value || controller.banners.isEmpty) {
        return _buildFallback();
      }

      final banners = controller.banners;
      _initCarousel(banners.length);

      return Container(
        height: 220,
        margin: EdgeInsets.only(bottom: 10, top: 10),
        child: PageView.builder(
          controller: _pageController,
          itemCount: _multiplier * banners.length,
          onPageChanged: (page) {
            setState(() => _realIndex = page % banners.length);
          },
          itemBuilder: (context, index) {
            final banner = banners[index % banners.length];
            return GestureDetector(
              onTap: () => _handleBannerTap(banner),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AppNetworkImage(
                    url: banner.image,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildSkeleton() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (_) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE0E6F0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallback() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/banner.jpg',
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 160,
            color: const Color(0xFFF0F0F0),
            child: const Center(
              child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 40),
            ),
          ),
        ),
      ),
    );
  }
}

class QuickCategory extends StatelessWidget {
  final String title;
  final Color color;
  final String imageUrl;
  final VoidCallback? onTap;

  const QuickCategory({
    super.key,
    required this.title,
    required this.color,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Gilroy',
                  height: 1.1,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: AppNetworkImage(
                url: imageUrl,
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
