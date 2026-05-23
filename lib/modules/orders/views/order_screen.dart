// ignore_for_file: deprecated_member_use

import 'package:atlas/themes/colors.dart';
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
  DeliveryType? _selectedDeliveryType;
  DeliveryTime? _selectedDeliveryTime;
  RegionModel? _selectedRegion;
  bool _isExpressDelivery = false;

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
    if (_orderCtrl.deliveryTypes.isEmpty) {
      _orderCtrl.fetchDeliveryTypes();
    }
    if (_orderCtrl.deliveryTimes.isEmpty) {
      _orderCtrl.fetchDeliveryTimes();
    }
    if (_orderCtrl.regions.isEmpty) {
      _orderCtrl.fetchRegions();
    }
    if (_orderCtrl.dialogNotices.isEmpty) {
      _orderCtrl.fetchDialogs();
    }
    _phoneCtrl.text = '+993 ';
    _phoneCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: _phoneCtrl.text.length),
    );
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

  void _showSelectionDialog<T>({
    required String title,
    required List<T> items,
    required T? selectedItem,
    required Function(T) onItemSelected,
    required Widget Function(T) itemBuilder,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Gilroy',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () {
                        onItemSelected(item);
                        Navigator.pop(context);
                      },
                      child: itemBuilder(item),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeliveryTimeDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'delivery_time'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Gilroy',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.0,
                  ),
                  itemCount: _orderCtrl.deliveryTimes.length,
                  itemBuilder: (context, index) {
                    final item = _orderCtrl.deliveryTimes[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedDeliveryTime = item);
                        Navigator.pop(context);
                      },
                      child: _DeliveryTimeGridTile(
                        time: item,
                        isSelected: _selectedDeliveryTime?.id == item.id,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRegionDialogWithSearch() {
    showDialog(
      context: context,
      builder: (context) => _RegionSearchDialog(
        regions: _orderCtrl.regions,
        selectedRegion: _selectedRegion,
        onSelected: (region) {
          setState(() => _selectedRegion = region);
        },
      ),
    );
  }

  void _showPaymentDialog() {
    _showSelectionDialog<PaymentMethod>(
      title: 'payment_method'.tr,
      items: _orderCtrl.paymentMethods,
      selectedItem: _selectedPayment,
      onItemSelected: (item) => setState(() => _selectedPayment = item),
      itemBuilder: (item) => _PaymentTile(
        method: item,
        lang: _lang,
        isSelected: _selectedPayment?.id == item.id,
      ),
    );
  }

  void _showRegionDialog() {
    _showRegionDialogWithSearch();
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
    if (_selectedDeliveryType == null) {
      Get.snackbar(
        'error'.tr,
        'select_delivery_type'.tr,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    if (_selectedDeliveryTime == null) {
      Get.snackbar(
        'error'.tr,
        'select_delivery_time'.tr,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    if (_selectedRegion == null) {
      Get.snackbar(
        'error'.tr,
        'select_region'.tr,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // Show dialog notices if any exist
    if (_orderCtrl.dialogNotices.isNotEmpty) {
      final confirmed = await _showOrderDialogs();
      if (!confirmed) return;
    }

    final count = widget.cartItems.fold<int>(0, (s, item) => s + ((item['quantity'] ?? 1) as int));
    final success = await _orderCtrl.placeOrder(
      phoneNumber: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      paymentStatus: _selectedPayment!.localizedName('tk'),
      deliveryTypeId: _selectedDeliveryType?.id,
      deliveryTimeId: _selectedDeliveryTime?.id,
      regionId: _selectedRegion?.id,
      cartItems: widget.cartItems,
    );
    if (success) {
      _cartCtrl.clearCart();
      if (mounted) Navigator.of(context).pop();
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
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: AppColors.primary,
          ),
          onPressed: () => Navigator.of(context).pop(),
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
                return _SelectionTile(
                  icon: HugeIcons.strokeRoundedMoney01,
                  label: _selectedPayment?.localizedName(_lang) ?? 'select_payment_method'.tr,
                  isSelected: _selectedPayment != null,
                  onTap: () => _showPaymentDialog(),
                );
              }),
              const SizedBox(height: 20),

              // Delivery type section - Hidden when region is selected
              // if (_selectedRegion == null) ...[
              //   _SectionLabel(label: 'delivery_type'.tr),
              //   const SizedBox(height: 10),
              //   Obx(() {
              //     if (_orderCtrl.isLoadingDeliveryTypes.value) {
              //       return const Center(
              //           child: Padding(
              //         padding: EdgeInsets.all(16),
              //         child: AppLoadingState(),
              //       ));
              //     }
              //     if (_orderCtrl.deliveryTypes.isEmpty) return const SizedBox.shrink();
              //     return _SelectionTile(
              //       icon: HugeIcons.strokeRoundedDeliveryBox01,
              //       label: _selectedDeliveryType?.localizedName(_lang) ?? 'select_delivery_type'.tr,
              //       isSelected: _selectedDeliveryType != null,
              //       onTap: () => _showSelectionDialog<DeliveryType>(
              //         title: 'delivery_type'.tr,
              //         items: _orderCtrl.deliveryTypes,
              //         selectedItem: _selectedDeliveryType,
              //         onItemSelected: (item) => setState(() => _selectedDeliveryType = item),
              //         itemBuilder: (item) => _DeliveryTypeListTile(
              //           type: item,
              //           lang: _lang,
              //           isSelected: _selectedDeliveryType?.id == item.id,
              //         ),
              //       ),
              //     );
              //   }),
              //   const SizedBox(height: 20),
              // ],

              // Region section
              _SectionLabel(label: 'region'.tr),
              const SizedBox(height: 10),
              Obx(() {
                if (_orderCtrl.isLoadingRegions.value) {
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.all(16),
                    child: AppLoadingState(),
                  ));
                }
                if (_orderCtrl.regions.isEmpty) return const SizedBox.shrink();
                return Column(
                  children: [
                    _SelectionTile(
                      icon: HugeIcons.strokeRoundedLocation01,
                      label: _selectedRegion?.name ?? 'select_region'.tr,
                      isSelected: _selectedRegion != null,
                      onTap: () => _showRegionDialog(),
                    ),
                    if (_selectedRegion != null) ...[
                      const SizedBox(height: 10),
                      _DeliveryTypeRow(
                        isExpress: _isExpressDelivery,
                        standardPrice: _selectedRegion!.price,
                        expressPrice: _selectedRegion!.exPrice,
                        onChanged: (val) => setState(() => _isExpressDelivery = val),
                      ),
                    ],
                  ],
                );
              }),
              const SizedBox(height: 20),

              // Delivery time section
              _SectionLabel(label: 'delivery_time'.tr),
              const SizedBox(height: 10),
              Obx(() {
                if (_orderCtrl.isLoadingDeliveryTimes.value) {
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.all(16),
                    child: AppLoadingState(),
                  ));
                }
                if (_orderCtrl.deliveryTimes.isEmpty) return const SizedBox.shrink();
                return _SelectionTile(
                  icon: HugeIcons.strokeRoundedClock01,
                  label: _selectedDeliveryTime?.displayTime ?? 'select_delivery_time'.tr,
                  isSelected: _selectedDeliveryTime != null,
                  onTap: _showDeliveryTimeDialog,
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

  Future<bool> _showOrderDialogs() async {
    final notices = _orderCtrl.dialogNotices;
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OrderDialogSheet(notices: notices, lang: _lang),
    );
    return result == true;
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
              color: AppColors.primary,
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
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
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
    final deliveryFee = _selectedRegion != null ? (_isExpressDelivery ? _selectedRegion!.exPrice : _selectedRegion!.price) : 0.0;
    final grandTotal = widget.total + deliveryFee;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Products total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'products_total'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8E8E93),
                    fontFamily: 'Gilroy',
                  ),
                ),
                Text(
                  '${widget.total.toStringAsFixed(0)} TMT',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    fontFamily: 'Gilroy',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Delivery fee
            if (_selectedRegion != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'delivery_fee'.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8E8E93),
                          fontFamily: 'Gilroy',
                        ),
                      ),
                      if (_isExpressDelivery) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'express_delivery'.tr,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              fontFamily: 'Gilroy',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '${deliveryFee.toStringAsFixed(0)} TMT',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      fontFamily: 'Gilroy',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: Color(0xFFE8E8E8)),
              const SizedBox(height: 8),
            ],
            // Grand total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'order_total'.tr,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8E8E93),
                    fontFamily: 'Gilroy',
                  ),
                ),
                Text(
                  '${grandTotal.toStringAsFixed(0)} TMT',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
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
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
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
  final VoidCallback? onTap;

  const _PaymentTile({
    required this.method,
    required this.lang,
    required this.isSelected,
    this.onTap,
  });

  IconData get _icon {
    final name = method.nameTk.toLowerCase();
    if (name.contains('terminal')) return HugeIcons.strokeRoundedCreditCard;
    if (name.contains('online')) return HugeIcons.strokeRoundedMobileNavigator01;
    return HugeIcons.strokeRoundedMoney01;
  }

  @override
  Widget build(BuildContext context) {
    final container = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : const Color(0xFFE8E8E8),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.black.withOpacity(0.03),
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
              color: isSelected ? AppColors.primary.withOpacity(0.12) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: HugeIcon(
                icon: _icon,
                color: isSelected ? AppColors.primary : const Color(0xFF8E8E93),
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
              color: isSelected ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppColors.primary : const Color(0xFFD0D0D0),
                width: 2,
              ),
            ),
            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
          ),
        ],
      ),
    );

    if (onTap == null) return container;
    return GestureDetector(onTap: onTap, child: container);
  }
}

// ─── Order Dialog Sheet ──────────────────────────────────────────────────────

class _OrderDialogSheet extends StatelessWidget {
  final List<DialogNoticeModel> notices;
  final String lang;

  const _OrderDialogSheet({required this.notices, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Icon + title row
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedInformationCircle,
                      color: Color(0xFFE6A817),
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'order_notice'.tr,
                    style: const TextStyle(
                      fontFamily: 'Gilroy',
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Notice messages
            ...notices.map(
              (n) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFE082), width: 1),
                ),
                child: Text(
                  n.localizedBody(lang),
                  style: const TextStyle(
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xFF4A4A4A),
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Confirm button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'i_understand'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Gilroy',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'cancel'.tr,
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Gilroy',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Selection Tile ──────────────────────────────────────────────────────────

class _SelectionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE8E8E8),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.black.withOpacity(0.03),
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
                color: isSelected ? AppColors.primary.withOpacity(0.12) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: HugeIcon(
                  icon: icon,
                  color: isSelected ? AppColors.primary : const Color(0xFF8E8E93),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFF8E8E93),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isSelected ? AppColors.primary : const Color(0xFFB0B0B0),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Delivery Type Row ───────────────────────────────────────────────────────

class _DeliveryTypeRow extends StatelessWidget {
  final bool isExpress;
  final double standardPrice;
  final double expressPrice;
  final ValueChanged<bool> onChanged;

  const _DeliveryTypeRow({
    required this.isExpress,
    required this.standardPrice,
    required this.expressPrice,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: !isExpress ? AppColors.primary.withOpacity(0.1) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: !isExpress ? AppColors.primary : const Color(0xFFE8E8E8),
                  width: !isExpress ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedDeliveryBox01,
                        color: !isExpress ? AppColors.primary : const Color(0xFF8E8E93),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'standard_delivery'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Gilroy',
                            color: !isExpress ? AppColors.primary : const Color(0xFF8E8E93),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${standardPrice.toStringAsFixed(0)} TMT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Gilroy',
                      color: !isExpress ? AppColors.primary : const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isExpress ? AppColors.primary.withOpacity(0.1) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isExpress ? AppColors.primary : const Color(0xFFE8E8E8),
                  width: isExpress ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedDeliveryTruck01,
                        color: isExpress ? AppColors.primary : const Color(0xFF8E8E93),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'express_delivery'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Gilroy',
                            color: isExpress ? AppColors.primary : const Color(0xFF8E8E93),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${expressPrice.toStringAsFixed(0)} TMT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Gilroy',
                      color: isExpress ? AppColors.primary : const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Region List Tile ────────────────────────────────────────────────────────

class _RegionListTile extends StatelessWidget {
  final RegionModel region;
  final bool isSelected;
  final VoidCallback? onTap;

  const _RegionListTile({
    required this.region,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final container = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : const Color(0xFFE8E8E8),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.black.withOpacity(0.03),
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
              color: isSelected ? AppColors.primary.withOpacity(0.12) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedLocation01,
                color: isSelected ? AppColors.primary : const Color(0xFF8E8E93),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              region.name,
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
              color: isSelected ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppColors.primary : const Color(0xFFD0D0D0),
                width: 2,
              ),
            ),
            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
          ),
        ],
      ),
    );

    if (onTap == null) return container;
    return GestureDetector(onTap: onTap, child: container);
  }
}

class _DeliveryTimeGridTile extends StatelessWidget {
  final DeliveryTime time;
  final bool isSelected;

  const _DeliveryTimeGridTile({
    required this.time,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : const Color(0xFFE8E8E8),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedClock01,
            color: isSelected ? Colors.white : AppColors.primary,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            time.displayTime,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Region Search Dialog ────────────────────────────────────────────────────

class _RegionSearchDialog extends StatefulWidget {
  final List<RegionModel> regions;
  final RegionModel? selectedRegion;
  final Function(RegionModel) onSelected;

  const _RegionSearchDialog({
    required this.regions,
    required this.selectedRegion,
    required this.onSelected,
  });

  @override
  State<_RegionSearchDialog> createState() => _RegionSearchDialogState();
}

class _RegionSearchDialogState extends State<_RegionSearchDialog> {
  final _searchController = TextEditingController();
  List<RegionModel> _filteredRegions = [];

  @override
  void initState() {
    super.initState();
    _filteredRegions = widget.regions;
    _searchController.addListener(_filterRegions);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterRegions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredRegions = widget.regions;
      } else {
        _filteredRegions = widget.regions.where((region) => region.name.toLowerCase().contains(query)).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'region'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Gilroy',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'search_region'.tr,
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Gilroy',
                    color: Color(0xFF8E8E93),
                  ),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF8E8E93)),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            Flexible(
              child: _filteredRegions.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'no_results'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Gilroy',
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredRegions.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final region = _filteredRegions[index];
                        return GestureDetector(
                          onTap: () {
                            widget.onSelected(region);
                            Navigator.pop(context);
                          },
                          child: _RegionListTile(
                            region: region,
                            isSelected: widget.selectedRegion?.id == region.id,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
