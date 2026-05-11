import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/modules/main/controllers/feature_controllers.dart';
import 'package:atlas/modules/main/controllers/main_controller.dart';

class AppDialogs {
  static void showTopSuccessSnackbar({
    required String title,
    required String subtitle,
    IconData icon = HugeIcons.strokeRoundedCheckmarkCircle02,
  }) {
    Get.closeAllSnackbars();
    Get.showSnackbar(
      GetSnackBar(
        snackPosition: SnackPosition.TOP,
        snackStyle: SnackStyle.FLOATING,
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        padding: EdgeInsets.zero,
        borderRadius: 18,
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 3),
        isDismissible: true,
        messageText: Container(
          decoration: BoxDecoration(
            color: const Color(0xff22B241),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff22B241).withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: Colors.white, size: 21),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Gilroy',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Gilroy',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void showQuickOrderDialog(Map<String, dynamic> item) {
    final quantity = 1.obs;
    final cartController = Get.find<CartController>();
    final mainController = Get.find<MainController>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sargyt etmek isleýärsiňizmi?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Gilroy',
                ),
              ),
              const SizedBox(height: 20),
              // Product Preview Row
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 80,
                      height: 80,
                      color: const Color(0xFFF9F9F9),
                      child: item['imageUrl'].toString().startsWith('assets')
                          ? Image.asset(item['imageUrl'], fit: BoxFit.contain)
                          : Image.network(item['imageUrl'],
                              fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${item['price']} TMT',
                          style: const TextStyle(
                            color: Color(0xff22B241),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              // Quantity Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildQtyBtn(
                    const Text('-',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff22B241))),
                    () {
                      if (quantity.value > 1) quantity.value--;
                    },
                  ),
                  const SizedBox(width: 20),
                  Obx(() => Text(
                        '${quantity.value}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  const SizedBox(width: 20),
                  _buildQtyBtn(
                    const Text('+',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff22B241))),
                    () => quantity.value++,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Ýok',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        cartController.addItem(item,
                            initialQuantity: quantity.value);
                        Get.back();
                        showTopSuccessSnackbar(
                          title: 'Sebede üstünlikli goşuldy',
                          subtitle:
                              '${quantity.value} sany • ${item['price']} TMT',
                          icon: HugeIcons.strokeRoundedShoppingCart01,
                        );
                        mainController.changeIndex(3);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff22B241),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Hawa',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildQtyBtn(Widget child, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xff22B241).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      ),
    );
  }
}
