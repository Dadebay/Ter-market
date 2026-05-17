import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/modules/category/controllers/category_controller.dart';
import 'package:atlas/modules/category/views/category_detail_screen.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/widgets/app_loading_state.dart';
import 'package:atlas/widgets/app_empty_state.dart';
import 'package:atlas/widgets/app_network_image.dart';

class CategoryScreen extends GetView<CategoryController> {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        titleSpacing: 16,
        title: Text(
            'categories'.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Gilroy',
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingState();
        }
        if (controller.hasError.value) {
          return AppErrorState(
            message: 'error_retry'.tr,
            onRetry: controller.fetchCategories,
          );
        }
        if (controller.categories.isEmpty) {
          return AppEmptyState(
            icon: Icons.category_outlined,
            title: 'no_categories'.tr,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final cat = controller.categories[index];
            return GestureDetector(
              onTap: () => Get.to(
                () => CategoryDetailScreen(
                  categoryId: cat.id,
                  categoryName: cat.localizedName,
                ),
              ),
              child: Container(
                height: 160,
                margin: const EdgeInsets.only(bottom: 12),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (cat.image != null)
                      AppNetworkImage(
                        url: cat.image,
                        fit: BoxFit.cover,
                      )
                    else
                      Container(
                        color: AppColors.primary.withOpacity(0.1),
                        child: const Center(
                          child: Icon(Icons.category_outlined, size: 56, color: Colors.grey),
                        ),
                      ),
                    // Gradient overlay
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                    // Category name
                    Positioned(
                      left: 16,
                      right: 56,
                      bottom: 16,
                      child: Text(
                        cat.localizedName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Gilroy',
                        ),
                      ),
                    ),
                    // Arrow button
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
