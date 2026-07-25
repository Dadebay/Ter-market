import 'package:atlas/modules/main/controllers/feature_controllers.dart';
import 'package:atlas/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/modules/main/controllers/main_controller.dart';
import 'package:atlas/modules/home/views/home_screen.dart';
import 'package:atlas/modules/category/views/category_screen.dart';
import 'package:atlas/modules/favorites/views/favorites_screen.dart';
import 'package:atlas/modules/cart/views/cart_screen.dart';
import 'package:atlas/modules/profile/views/profile_screen.dart';
import 'package:iconly/iconly.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final PersistentTabController _tabController;
  late final MainController _mainCtrl;
  Worker? _indexWorker;

  @override
  void initState() {
    super.initState();
    _mainCtrl = Get.find<MainController>();
    _tabController = PersistentTabController(initialIndex: 0);

    // Sync MainController.currentIndex → PersistentTabController
    _indexWorker = ever(_mainCtrl.currentIndex, (int idx) {
      if (mounted && _tabController.index != idx) {
        setState(() {
          _tabController.jumpToTab(idx);
        });
      }
    });
  }

  @override
  void dispose() {
    _indexWorker?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (_tabController.index == index) return;
    if (index == 2) {
      final cart = Get.find<CartController>();
      final items = cart.cartItems;
      print('┌─── CART SCREEN OPENED ────────────────────────');
      print('│ item count  : ${items.length}');
      for (final item in items) {
        final price = (item['price'] is int) ? (item['price'] as int).toDouble() : (item['price'] as double? ?? 0.0);
        final qty = (item['quantity'] as num?)?.toInt() ?? 1;
        print('│   ${item['title']} | price=${price.toStringAsFixed(0)} qty=$qty total=${(price * qty).toStringAsFixed(0)} TMT');
      }
      print('│ totalPrice  : ${cart.totalPrice.toStringAsFixed(0)} TMT');
      print('└────────────────────────────────────────────────');
    }
    setState(() {
      _tabController.jumpToTab(index);
      _mainCtrl.currentIndex.value = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView.custom(
      context,
      controller: _tabController,
      itemCount: 5,
      backgroundColor: Colors.white,
      screens: [
        CustomNavBarScreen(screen: HomeScreen()),
        const CustomNavBarScreen(screen: CategoryScreen()),
        const CustomNavBarScreen(screen: CartScreen()),
        const CustomNavBarScreen(screen: FavoritesScreen(fromBottomNavBar: true)),
        const CustomNavBarScreen(screen: ProfileScreen()),
      ],
      customWidget: _MainNavBar(
        selectedIndex: _tabController.index,
        onItemSelected: _onTabSelected,
      ),
    );
  }
}

class _MainNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const _MainNavBar({
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    return Obx(() {
      final cartCount = cartController.cartItems.length;
      return BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemSelected,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(IconlyLight.home, color: Colors.grey),
            activeIcon: const Icon(IconlyBold.home, color: AppColors.primary),
            label: 'home'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(IconlyLight.category, color: Colors.grey),
            activeIcon: const Icon(IconlyBold.category, color: AppColors.primary),
            label: 'category'.tr,
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text(cartCount.toString()),
              isLabelVisible: cartCount > 0,
              backgroundColor: Colors.red,
              child: const Icon(IconlyLight.bag, color: Colors.grey),
            ),
            activeIcon: Badge(
              label: Text(cartCount.toString()),
              isLabelVisible: cartCount > 0,
              backgroundColor: Colors.red,
              child: const Icon(IconlyBold.bag, color: AppColors.primary),
            ),
            label: 'cart'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(IconlyLight.heart, color: Colors.grey),
            activeIcon: const Icon(IconlyBold.heart, color: AppColors.primary),
            label: 'favorites'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(IconlyLight.profile, color: Colors.grey),
            activeIcon: const Icon(IconlyBold.profile, color: AppColors.primary),
            label: 'profile'.tr,
          ),
        ],
      );
    });
  }
}
