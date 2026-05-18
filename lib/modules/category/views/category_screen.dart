import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/models/category_model.dart';
import 'package:atlas/modules/category/controllers/category_controller.dart';
import 'package:atlas/modules/category/views/category_detail_screen.dart';
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
          style: const TextStyle(
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final cat = controller.categories[index];
            return _CategoryAccordionTile(cat: cat, controller: controller);
          },
        );
      }),
    );
  }
}

class _CategoryAccordionTile extends StatelessWidget {
  final CategoryModel cat;
  final CategoryController controller;

  const _CategoryAccordionTile({
    required this.cat,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isExpanded = controller.expandedIds.contains(cat.id);
      final isLoadingSub = controller.loadingSubCatIds.contains(cat.id);
      final subCategories = controller.subCategoriesMap[cat.id] ?? [];

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Category row ──────────────────────────────────────────────
          InkWell(
            onTap: () => controller.toggleCategory(cat.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Icon / image
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: cat.image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AppNetworkImage(
                              url: cat.image,
                              fit: BoxFit.contain,
                            ),
                          )
                        : const Icon(Icons.category_outlined, size: 28, color: Colors.grey),
                  ),
                  const SizedBox(width: 14),
                  // Name
                  Expanded(
                    child: Text(
                      cat.localizedName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Gilroy',
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  // Toggle button
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isExpanded ? const Color(0xFF1D1B20) : const Color(0xFFF0F0F0),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isExpanded ? Icons.remove : Icons.add,
                      size: 18,
                      color: isExpanded ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Subcategory list ──────────────────────────────────────────
          if (isExpanded) ...[
            if (isLoadingSub)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF22B241),
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  children: subCategories.map((sub) {
                    return GestureDetector(
                      onTap: () => Get.to(
                        () => CategoryDetailScreen(
                          categoryId: cat.id,
                          categoryName: cat.localizedName,
                          initialSubCategoryId: sub.id,
                          initialSubCategoryName: sub.localizedName,
                        ),
                      ),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          sub.localizedName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Gilroy',
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
          const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFEEEEEE)),
        ],
      );
    });
  }
}
