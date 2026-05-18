// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/modules/main/controllers/feature_controllers.dart';
import 'package:atlas/modules/orders/controllers/order_controller.dart';
import 'package:atlas/modules/profile/controllers/language_controller.dart';
import 'package:atlas/models/order_model.dart';
import 'package:atlas/widgets/app_dialogs.dart';
import 'package:atlas/widgets/app_loading_state.dart';

class OrderScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double total;

  const OrderScreen({
    super.key,
    required this.cartItems,
    required this.total,
  });

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  PaymentMethod? _selectedPayment;

  late OrderController _orderCtrl;
  late CartController _cartCtrl;

  @override
  void initState() {
    super.initState();
    _orderCtrl = Get.isRegistered<OrderController>() ? Get.find<OrderController>() : Get.put(OrderController());
    _cartCtrl = Get.find<CartController>();
    if (_orderCtrl.paymentMethods.isEmpty) {
      _orderCtrl.fetchPaymentMethods();
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  String get _lang {
    try {
      return Get.find<LanguageController>().selectedLanguage.value;
    } catch (_) {
      return 'tk';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPayment == null) {
      Get.snackbar(
        'error'.tr,
        'select_payment_method'.tr,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    final count = widget.cartItems.fold<int>(0, (s, item) => s + ((item['quantity'] ?? 1) as int));
    final success = await _orderCtrl.placeOrder(
      phoneNumber: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      paymentStatus: _selectedPayment!.localizedName('tk'),
      cartItems: widget.cartItems,
    );
    if (success) {
      _cartCtrl.clearCart();
      Get.back();
      AppDialogs.showTopSuccessSnackbar(
        title: 'order_success'.tr,
        subtitle: '$count ${'items'.tr} • ${widget.total.toStringAsFixed(0)} TMT',
        icon: HugeIcons.strokeRoundedShoppingBag01,
      );
    } else {
      Get.snackbar(
        'error'.tr,
        'failed_to_create_order'.tr,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.cartItems.fold<int>(0, (s, item) => s + ((item['quantity'] ?? 1) as int));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: Color(0xff22B241),
          ),
          onPressed: Get.back,
        ),
        title: Text(
          'confirm_order'.tr,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontFamily: 'Gilroy',
            fontSize: 18,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order summary card
              _OrderSummaryCard(
                itemCount: itemCount,
                total: widget.total,
                cartItems: widget.cartItems,
              ),
              const SizedBox(height: 20),

              // Contact info section
              _SectionLabel(label: 'contact_info'.tr),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _phoneCtrl,
                label: 'phone_number'.tr,
                hint: '+993 61 xxxxxx',
                keyboardType: TextInputType.phone,
                prefixIcon: HugeIcons.strokeRoundedCall,
                validator: (v) => (v == null || v.isEmpty) ? 'field_required'.tr : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _addressCtrl,
                label: 'delivery_address'.tr,
                hint: 'address_hint'.tr,
                prefixIcon: HugeIcons.strokeRoundedLocation01,
                maxLines: 2,
                validator: (v) => (v == null || v.isEmpty) ? 'field_required'.tr : null,
              ),
              const SizedBox(height: 20),

              // Payment method section
              _SectionLabel(label: 'payment_method'.tr),
              const SizedBox(height: 10),
              Obx(() {
                if (_orderCtrl.isLoadingPayments.value) {
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.all(16),
                    child: AppLoadingState(),
                  ));
                }
                if (_orderCtrl.paymentMethods.isEmpty) {
                  return _buildRetryPayments();
                }
                return Column(
                  children: _orderCtrl.paymentMethods
                      .map((p) => _PaymentTile(
                            method: p,
                            lang: _lang,
                            isSelected: _selectedPayment?.id == p.id,
                            onTap: () => setState(() => _selectedPayment = p),
                          ))
                      .toList(),
                );
              }),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(itemCount),
    );
  }

  Widget _buildRetryPayments() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('error_occurred'.tr, style: const TextStyle(color: Color(0xFF8E8E93))),
          TextButton(
            onPressed: _orderCtrl.fetchPaymentMethods,
            child: Text('retry'.tr, style: const TextStyle(color: Color(0xff22B241))),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(
          fontFamily: 'Gilroy',
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: HugeIcon(
              icon: prefixIcon,
              color: const Color(0xff22B241),
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xff22B241), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildBottomBar(int itemCount) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'total'.tr,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8E8E93),
                    fontFamily: 'Gilroy',
                  ),
                ),
                Text(
                  '${widget.total.toStringAsFixed(0)} TMT',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xff22B241),
                    fontFamily: 'Gilroy',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _orderCtrl.isPlacingOrder.value ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff22B241),
                      disabledBackgroundColor: const Color(0xff22B241).withOpacity(0.5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _orderCtrl.isPlacingOrder.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: AppLoadingState(size: 24),
                          )
                        : Text(
                            'yes_order'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Gilroy',
                            ),
                          ),
                  ),
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Order Summary Card ──────────────────────────────────────────────────────

class _OrderSummaryCard extends StatelessWidget {
  final int itemCount;
  final double total;
  final List<Map<String, dynamic>> cartItems;

  const _OrderSummaryCard({
    required this.itemCount,
    required this.total,
    required this.cartItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0x1422B241),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedShoppingBag01,
                    color: Color(0xff22B241),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$itemCount ${'items'.tr}',
                      style: const TextStyle(
                        fontFamily: 'Gilroy',
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      '${total.toStringAsFixed(0)} TMT',
                      style: const TextStyle(
                        fontFamily: 'Gilroy',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xff22B241),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (cartItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 10),
            ...cartItems.map((item) => _CartItemRow(item: item)),
          ],
        ],
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final Map<String, dynamic> item;

  const _CartItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final title = item['title'] as String? ?? '';
    final qty = item['quantity'] as int? ?? 1;
    final price = item['price'] is int ? (item['price'] as int).toDouble() : (item['price'] ?? 0.0) as double;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'x$qty',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF8E8E93),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(price * qty).toStringAsFixed(0)} TMT',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xff22B241),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Label ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        fontFamily: 'Gilroy',
        color: Color(0xFF1A1A1A),
      ),
    );
  }
}

// ─── Payment Tile ────────────────────────────────────────────────────────────

class _PaymentTile extends StatelessWidget {
  final PaymentMethod method;
  final String lang;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentTile({
    required this.method,
    required this.lang,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon {
    final name = method.nameTk.toLowerCase();
    if (name.contains('terminal')) return HugeIcons.strokeRoundedCreditCard;
    if (name.contains('online')) return HugeIcons.strokeRoundedMobileNavigator01;
    return HugeIcons.strokeRoundedMoney01;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xff22B241) : const Color(0xFFE8E8E8),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? const Color(0xff22B241).withOpacity(0.08) : Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xff22B241).withOpacity(0.12) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: HugeIcon(
                  icon: _icon,
                  color: isSelected ? const Color(0xff22B241) : const Color(0xFF8E8E93),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                method.localizedName(lang),
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFF4A4A4A),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xff22B241) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xff22B241) : const Color(0xFFD0D0D0),
                  width: 2,
                ),
              ),
              child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
          ],
        ),
      ),
    );
  }
}
