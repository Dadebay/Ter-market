import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/modules/home/controllers/banner_controller.dart';
import 'package:atlas/widgets/app_network_image.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
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

      return Column(
        children: [
          SizedBox(
            height: 160,
            child: PageView.builder(
              controller: _pageController,
              reverse: true,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemCount: banners.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AppNetworkImage(
                      url: banners[index].image,
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              banners.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: index == _currentIndex ? 20 : 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: index == _currentIndex ? const Color(0xff22B241) : const Color(0xFFE0E6F0),
                ),
              ),
            ),
          ),
        ],
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
