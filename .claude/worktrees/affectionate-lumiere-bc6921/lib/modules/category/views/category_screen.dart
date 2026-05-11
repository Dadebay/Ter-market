import 'package:atlas/models/category_model.dart';
import 'package:atlas/modules/category/views/sub_category_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/modules/category/controllers/category_controller.dart';
import 'package:atlas/widgets/app_loading_state.dart';
import 'package:atlas/widgets/app_empty_state.dart';
import 'package:atlas/widgets/app_network_image.dart';
import 'package:hugeicons/hugeicons.dart';

class CategoryScreen extends GetView<CategoryController> {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSearchBar(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const AppLoadingState();
                }
                if (controller.hasError.value) {
                  return AppErrorState(
                    message: 'Ýalňyşlyk ýüze çykdy. Täzeden synanyşyň.',
                    onRetry: controller.fetchCategories,
                  );
                }
                if (controller.categories.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.category_outlined,
                    title: 'Kategoriýa tapylmady',
                  );
                }
                return _buildCategoryLayout();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const Row(
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedSearch01,
            color: Colors.black45,
            size: 20,
          ),
          VerticalDivider(
            color: Color(0xFFE5E7EB),
            width: 32,
            indent: 12,
            endIndent: 12,
          ),
          Expanded(
            child: TextField(
              cursorColor: Colors.black54,
              decoration: InputDecoration(
                hintText: 'Gözleg',
                hintStyle: TextStyle(
                  color: Colors.black38,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSidebar(),
        Expanded(child: _buildSubCategoryGrid()),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 100,
      color: const Color(0xFFF9FAFB),
      child: Obx(() => ListView.builder(
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final cat = controller.categories[index];
              final isSelected = controller.selectedCategoryId.value == cat.id;
              return _buildSidebarItem(cat, isSelected);
            },
          )),
    );
  }

  Widget _buildSidebarItem(CategoryModel cat, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.selectCategory(cat.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: isSelected
              ? const Border(
                  left: BorderSide(color: Color(0xff22B241), width: 3))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cat.image != null)
              AppNetworkImage(
                url: cat.image,
                width: 36,
                height: 36,
                fit: BoxFit.contain,
              )
            else
              const Icon(Icons.category_outlined,
                  color: Colors.grey, size: 28),
            const SizedBox(height: 6),
            Text(
              cat.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
                color:
                    isSelected ? const Color(0xff22B241) : Colors.black54,
                fontFamily: 'Gilroy',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubCategoryGrid() {
    return Obx(() {
      if (controller.isSubLoading.value) {
        return const AppLoadingState();
      }
      if (controller.subCategories.isEmpty) {
        return const AppEmptyState(
          icon: Icons.folder_open_outlined,
          title: 'Alt kategoriýa ýok',
        );
      }
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.8,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: controller.subCategories.length,
        itemBuilder: (context, index) {
          final sub = controller.subCategories[index];
          return _buildSubCategoryCard(sub);
        },
      );
    });
  }

  Widget _buildSubCategoryCard(SubCategoryModel sub) {
    return GestureDetector(
      onTap: () => Get.to(
        () => SubCategoryProductScreen(
          categoryName: sub.name,
          subCategoryId: sub.id,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (sub.image != null)
              AppNetworkImage(
                url: sub.image,
                width: 64,
                height: 64,
                fit: BoxFit.contain,
              )
            else
              const Icon(Icons.folder_outlined, color: Colors.grey, size: 40),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                sub.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Gilroy',
                  color: Color(0xFF0D1B3E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
