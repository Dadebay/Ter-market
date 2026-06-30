import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/utils/nav.dart';
import 'package:atlas/modules/home/controllers/home_controller.dart';
import 'package:atlas/modules/home/widgets/home_widgets.dart';
import 'package:atlas/modules/product/controllers/product_controller.dart';
import 'package:atlas/models/product_model.dart';
import 'package:atlas/modules/category/controllers/category_controller.dart';
import 'package:atlas/modules/category/views/category_detail_screen.dart';
import 'package:atlas/widgets/app_network_image.dart';
import 'package:atlas/widgets/product_card.dart';
import 'package:atlas/widgets/app_dialogs.dart';
import 'package:atlas/widgets/app_loading_state.dart';
import 'package:atlas/modules/main/controllers/feature_controllers.dart';
import 'package:atlas/modules/main/controllers/main_controller.dart';
import 'package:atlas/modules/product_detail/views/product_detail_screen.dart';
import 'package:atlas/modules/product_detail/bindings/product_detail_binding.dart';
import 'package:atlas/modules/home/views/contact_page.dart';
import 'package:atlas/modules/search/views/search_screen.dart';
import 'package:iconly/iconly.dart';

class HomeScreen extends GetView<HomeController> {
  HomeScreen({super.key});
  final HomeController controller = Get.put<HomeController>(HomeController());

  void _onCartPressed(ProductModel product) {
    AppDialogs.showQuickOrderDialog({
      'id': product.id,
      'title': product.localizedName,
      'imageUrl': product.image ?? '',
      'price': product.price,
    });
  }

  void _onProductTap(BuildContext context, ProductModel product) {
    Nav.push(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    Get.find<CartController>();
    Get.find<MainController>();
    final productController = Get.find<ProductController>();
    final categoryController = Get.find<CategoryController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        color: const Color(0xff22B241),
        onRefresh: () async {
          await Future.wait([
            productController.fetchDiscountedProducts(),
            productController.fetchNewProducts(),
            productController.fetchMostSoldProducts(),
            categoryController.fetchCategories(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeSearchBar(context: context),
              const BannerCarousel(),
              _buildCategorySection(context, categoryController),
              _buildSectionHeader(
                'discounts'.tr,
                () => Nav.push(context, () => CategoryDetailScreen(categoryName: 'discounts'.tr, initialFilter: 'price_high')),
              ),
              Obx(() => _HorizontalProductList(
                    isLoading: productController.isLoadingDiscounted.value,
                    products: productController.discountedProducts,
                    onTap: (p) => _onProductTap(context, p),
                    onCart: _onCartPressed,
                  )),
              const SizedBox(height: 30),
              _buildSectionHeader(
                'new_products'.tr,
                () => Nav.push(context, () => CategoryDetailScreen(categoryName: 'new_products'.tr, initialFilter: 'newest')),
              ),
              Obx(() => _HorizontalProductList(
                    isLoading: productController.isLoadingNew.value,
                    products: productController.newProducts,
                    showNewTag: true,
                    onTap: (p) => _onProductTap(context, p),
                    onCart: _onCartPressed,
                  )),
              Obx(() => productController.isLoadingMostSold.value || productController.mostSoldProducts.isNotEmpty
                  ? Column(
                      children: [
                        const SizedBox(height: 30),
                        _buildSectionHeader(
                          'most_sold'.tr,
                          () => Nav.push(context, () => CategoryDetailScreen(categoryName: 'most_sold'.tr, mostSoldMode: true)),
                        ),
                        _HorizontalProductList(
                          isLoading: productController.isLoadingMostSold.value,
                          products: productController.mostSoldProducts,
                          onTap: (p) => _onProductTap(context, p),
                          onCart: _onCartPressed,
                        ),
                        const SizedBox(height: 40),
                      ],
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 60,
      titleSpacing: 12,
      title: Row(
        children: [
          Expanded(
            child: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Ter ',
                    style: TextStyle(color: Color(0xFF4B2AA4), fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Gilroy'),
                  ),
                  TextSpan(
                    text: 'Market',
                    style: TextStyle(color: Color(0xFFF5A623), fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Gilroy'),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Nav.push(context, () => ContactPage()),
            child: const Icon(FeatherIcons.phoneCall, color: Colors.black87, size: 20),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, CategoryController categoryController) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'sections'.tr,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontFamily: 'Gilroy',
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 25),
          Obx(() {
            if (categoryController.isLoading.value) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (categoryController.categories.isEmpty) {
              return const SizedBox.shrink();
            }
            // Display up to 8 categories in a 4x2 grid
            final displayCategories = categoryController.categories.take(12).toList();
            final screenWidth = MediaQuery.of(context).size.width;
            final isTablet = screenWidth >= 600;
            final catCrossAxisCount = isTablet ? 6 : 4;
            final catAspectRatio = isTablet ? 0.75 : 0.70;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: catCrossAxisCount,
                  childAspectRatio: catAspectRatio,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: displayCategories.length,
                itemBuilder: (context, index) {
                  final category = displayCategories[index];
                  return _buildCategoryCard(context, category);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, category) {
    return GestureDetector(
      onTap: () {
        Nav.push(
          context,
          () => CategoryDetailScreen(
            categoryId: category.id,
            categoryName: category.localizedName,
          ),
        );
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (category.image != null)
                  Container(
                    width: 75,
                    height: 65,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: AppNetworkImage(
                        url: category.image!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.category_outlined,
                      size: 28,
                      color: Color(0xFF4B2AA4),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 6, left: 6),
            child: Text(
              category.localizedName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFamily: 'Gilroy',
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, right: 16, left: 16, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: 'Gilroy',
              letterSpacing: -0.5,
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'see_all'.tr,
              style: const TextStyle(
                color: Color(0xff22B241),
                fontWeight: FontWeight.w700,
                fontFamily: 'Gilroy',
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Search Bar ──────────────────────────────────────────────────────────────

class _HomeSearchBar extends StatefulWidget {
  final BuildContext context;
  const _HomeSearchBar({required this.context});

  @override
  State<_HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<_HomeSearchBar> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _navigate() {
    final q = _ctrl.text.trim();
    Nav.push(widget.context, () => q.isNotEmpty ? SearchScreen(initialQuery: q) : const SearchScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: TextField(
                controller: _ctrl,
                decoration: InputDecoration(
                  hintText: 'search_hint'.tr,
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15, fontFamily: 'Gilroy', fontWeight: FontWeight.w500),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onSubmitted: (v) {
                  if (v.isNotEmpty) Nav.push(widget.context, () => SearchScreen(initialQuery: v));
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _navigate,
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(color: const Color(0xFF4B2AA4), borderRadius: BorderRadius.circular(12)),
              child: const Icon(IconlyLight.search, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Horizontal Product List ─────────────────────────────────────────────────

class _HorizontalProductList extends StatelessWidget {
  final bool isLoading;
  final List<ProductModel> products;
  final bool showNewTag;
  final void Function(ProductModel) onTap;
  final void Function(ProductModel) onCart;

  const _HorizontalProductList({
    required this.isLoading,
    required this.products,
    required this.onTap,
    required this.onCart,
    this.showNewTag = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const SizedBox(height: 350, child: AppLoadingState());
    if (products.isEmpty) return const SizedBox(height: 100);
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16, right: 8),
        itemCount: products.length,
        itemBuilder: (_, i) {
          final p = products[i];
          return Padding(
            padding: EdgeInsets.only(right: i == products.length - 1 ? 0 : 8),
            child: ProductCard(
              id: p.id.toString(),
              imageUrl: p.image ?? '',
              title: p.localizedName,
              description: p.localizedDescription,
              price: p.price,
              oldPrice: p.oldPrice,
              discount: (p.discount != null && p.discount! > 0) ? p.discount!.toStringAsFixed(0) : null,
              rating: p.rating,
              storeName: p.storeName ?? 'Atlas',
              location: p.location ?? 'Aşgabat',
              showNewTag: showNewTag,
              brandIcon: p.brandIcon,
              onTap: () => onTap(p),
              onCartPressed: () => onCart(p),
            ),
          );
        },
      ),
    );
  }
}
