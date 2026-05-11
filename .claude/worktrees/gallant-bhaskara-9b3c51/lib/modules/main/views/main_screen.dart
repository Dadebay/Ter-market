import 'package:atlas/modules/main/controllers/feature_controllers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/modules/main/controllers/main_controller.dart';
import 'package:atlas/modules/home/views/home_screen.dart';
import 'package:atlas/modules/category/views/category_screen.dart';
import 'package:atlas/modules/favorites/views/favorites_screen.dart';
import 'package:atlas/modules/cart/views/cart_screen.dart';
import 'package:atlas/modules/profile/views/profile_screen.dart';

class MainScreen extends GetView<MainController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              HomeScreen(),
              CategoryScreen(),
              FavoritesScreen(),
              CartScreen(),
              ProfileScreen(),
            ],
          )),
      bottomNavigationBar: Obx(() {
        final cartController = Get.find<CartController>();
        int cartCount = cartController.cartItems.length;

        return BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeIndex,
          selectedItemColor: const Color(0xff22B241),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
          items: [
            const BottomNavigationBarItem(
              icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedHome09, color: Colors.grey),
              activeIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedHome09,
                  color: Color(0xff22B241)),
              label: 'Baş sahypa',
            ),
            const BottomNavigationBarItem(
              icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedGridView, color: Colors.grey),
              activeIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedGridView,
                  color: Color(0xff22B241)),
              label: 'Kategoriýa',
            ),
            const BottomNavigationBarItem(
              icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedFavourite, color: Colors.grey),
              activeIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedFavourite,
                  color: Color(0xff22B241)),
              label: 'Halanlarym',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                label: Text(cartCount.toString()),
                isLabelVisible: cartCount > 0,
                backgroundColor: Colors.red,
                child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedShoppingCart01,
                    color: Colors.grey),
              ),
              activeIcon: Badge(
                label: Text(cartCount.toString()),
                isLabelVisible: cartCount > 0,
                backgroundColor: Colors.red,
                child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedShoppingCart01,
                    color: Color(0xff22B241)),
              ),
              label: 'Sebet',
            ),
            const BottomNavigationBarItem(
              icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedUser, color: Colors.grey),
              activeIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedUser, color: Color(0xff22B241)),
              label: 'Hasabym',
            ),
          ],
        );
      }),
    );
  }
}
