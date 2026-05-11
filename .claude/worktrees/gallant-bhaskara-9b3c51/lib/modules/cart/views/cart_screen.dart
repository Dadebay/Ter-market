import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/modules/main/controllers/feature_controllers.dart';
import 'package:atlas/modules/orders/controllers/order_controller.dart';
import 'package:atlas/widgets/app_dialogs.dart';
import 'package:atlas/widgets/app_loading_state.dart';

class CartScreen extends GetView<CartController> {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('Sebet',
            style:
                TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Gilroy')),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() => controller.cartItems.isNotEmpty
              ? IconButton(
                  onPressed: () => _showDeleteConfirmation(context, -1),
                  icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedDelete01,
                      color: Colors.red,
                      size: 20),
                )
              : const SizedBox()),
        ],
      ),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return _buildEmptyCart();
        }
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.cartItems.length,
                itemBuilder: (context, index) {
                  final item = controller.cartItems[index];
                  return _buildCartItem(context, index, item);
                },
              ),
            ),
            _buildCartSummary(context),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F2),
              shape: BoxShape.circle,
            ),
            child: const HugeIcon(
              icon: HugeIcons.strokeRoundedShoppingCart01,
              color: Colors.grey,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Sebediňiz boş',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Gilroy',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Haryt goşuň we sargyt ediň!',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
      BuildContext context, int index, Map<String, dynamic> item) {
    final title = item['title'] ?? 'Nätanyş haryt';
    final image = item['imageUrl'] ?? '';
    final price = item['price'] ?? 0.0;
    final quantity = item['quantity'] ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: const Color(0xFFF9F9F9),
              child: image.startsWith('assets')
                  ? Image.asset(image,
                      height: 80,
                      width: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.image, color: Colors.grey))
                  : Image.network(image,
                      height: 80,
                      width: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.image, color: Colors.grey)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            fontFamily: 'Gilroy'),
                      ),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: () => _showDeleteConfirmation(context, index),
                      icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedDelete01,
                          color: Colors.red,
                          size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${(price is int ? price.toDouble() : price as double).toStringAsFixed(0)} TMT',
                  style: const TextStyle(
                    color: Color(0xff22B241),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildQtyBtn(
                          Icons.remove, () => controller.updateQuantity(index, -1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('$quantity',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      _buildQtyBtn(
                          Icons.add, () => controller.updateQuantity(index, 1)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(index == -1 ? 'Sebedi arassalamak' : 'Harydy aýyrmak'),
        content: Text(index == -1
            ? 'Siz hakykatdan hem sebedi doly arassalamak isleýärsiňizmi?'
            : 'Siz bu harydy sebetden aýyrmak isleýärsiňizmi?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Ýok', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (index == -1) {
                controller.clearCart();
              } else {
                controller.removeItem(index);
              }
              Get.back();
            },
            child: const Text('Hawa',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Jemi:',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Gilroy')),
                Obx(() => Text(
                    '${controller.totalPrice.toStringAsFixed(0)} TMT',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xff22B241)))),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showOrderDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff22B241),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Sargyt etmek',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Gilroy')),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDialog(BuildContext context) {
    if (controller.cartItems.isEmpty) return;

    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final orderedCount = controller.cartItems.fold<int>(
      0,
      (sum, item) => sum + ((item['quantity'] ?? 1) as int),
    );
    final orderedTotal = controller.totalPrice;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0x1422B241),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const HugeIcon(
                        icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                        color: Color(0xff22B241),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Sargydy tassyklamak',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Gilroy',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F8F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$orderedCount haryt • ${orderedTotal.toStringAsFixed(0)} TMT',
                    style: const TextStyle(
                      color: Color(0xff22B241),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Gilroy',
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '+993 61 xxxxxx',
                    labelText: 'Telefon belgisi',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xff22B241)),
                    ),
                    isDense: true,
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Telefon girizi' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    hintText: 'Eltip bermek salgysy',
                    labelText: 'Salgy',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xff22B241)),
                    ),
                    isDense: true,
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Salgy girizi' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: Get.back,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFDBE2DC)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Ýok',
                          style: TextStyle(
                            color: Color(0xFF66707A),
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Obx(() {
                        final orderController = Get.find<OrderController>();
                        return ElevatedButton(
                          onPressed: orderController.isPlacingOrder.value
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  final success =
                                      await orderController.placeOrder(
                                    phoneNumber: phoneController.text,
                                    address: addressController.text,
                                    cartItems: controller.cartItems.toList(),
                                  );
                                  Get.back();
                                  if (success) {
                                    controller.clearCart();
                                    AppDialogs.showTopSuccessSnackbar(
                                      title: 'Sargyt üstünlikli ugradyldy',
                                      subtitle:
                                          '$orderedCount haryt • ${orderedTotal.toStringAsFixed(0)} TMT',
                                      icon: HugeIcons
                                          .strokeRoundedShoppingBag01,
                                    );
                                  } else {
                                    Get.snackbar(
                                      'Ýalňyşlyk',
                                      'Sargyt ugradylmady. Täzeden synanyşyň.',
                                      backgroundColor: Colors.red.shade50,
                                      colorText: Colors.red,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff22B241),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: orderController.isPlacingOrder.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: AppLoadingState(size: 20),
                                )
                              : const Text(
                                  'Hawa, sargyt et',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Gilroy',
                                  ),
                                ),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
