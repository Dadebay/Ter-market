import 'package:atlas/modules/main/controllers/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/modules/main/controllers/feature_controllers.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'profile'.tr,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            fontFamily: 'Gilroy',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildOrderSection(),
            const SizedBox(height: 20),
            _buildMenuSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF22B241), width: 2),
            ),
            child: const CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop',
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                      controller.userName.value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Gilroy',
                        color: Color(0xFF1D1B20),
                      ),
                    )),
                const SizedBox(height: 4),
                Obx(() => Text(
                      controller.userPhone.value,
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Gilroy',
                      ),
                    )),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedPencilEdit01,
              color: Color(0xFF22B241),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'my_orders'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Gilroy',
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'all'.tr,
                  style: const TextStyle(
                    color: Color(0xFF22B241),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOrderStatus(HugeIcons.strokeRoundedWallet01, 'payment'.tr),
              _buildOrderStatus(HugeIcons.strokeRoundedPackage, 'preparing'.tr),
              _buildOrderStatus(
                  HugeIcons.strokeRoundedShippingCenter, 'on_way'.tr),
              _buildOrderStatus(HugeIcons.strokeRoundedStar, 'rate'.tr),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderStatus(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HugeIcon(icon: icon, color: Colors.black87, size: 22),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        _buildMenuItem(
          HugeIcons.strokeRoundedLocation01,
          'my_addresses'.tr,
          () {},
        ),
        _buildMenuItem(
          HugeIcons.strokeRoundedFavourite,
          'favorites'.tr,
          () => Get.find<MainController>().changeIndex(2),
        ),
        _buildMenuItem(
          HugeIcons.strokeRoundedNotification01,
          'notifications'.tr,
          () => _showNotificationSettings(),
        ),
        _buildMenuItem(
          HugeIcons.strokeRoundedGlobal,
          'change_language'.tr,
          () => _showLanguageSelector(),
          trailing: Obx(() => Text(
                controller.currentLanguage.value == 'tk' ? 'TKM' : 'RUS',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF22B241),
                ),
              )),
        ),
        _buildMenuItem(
          HugeIcons.strokeRoundedQuestion,
          'help_support'.tr,
          () {},
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          HugeIcons.strokeRoundedLogout01,
          'logout'.tr,
          () => _showLogoutDialog(),
          isDestructive: true,
          showTrailing: false,
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap,
      {bool isDestructive = false, Widget? trailing, bool showTrailing = true}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: HugeIcon(
        icon: icon,
        color: isDestructive ? Colors.red : Colors.black87,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : Colors.black87,
          fontSize: 14,
          fontFamily: 'Gilroy',
        ),
      ),
      trailing: trailing ??
          (showTrailing
              ? const Icon(Icons.chevron_right, size: 18, color: Colors.black26)
              : null),
      onTap: onTap,
    );
  }

  void _showLogoutDialog() {
    Get.defaultDialog(
      title: 'logout'.tr,
      middleText: 'logout_confirm'.tr,
      textConfirm: 'yes'.tr,
      textCancel: 'no'.tr,
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () => Get.back(),
    );
  }

  void _showLanguageSelector() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'choose_language'.tr,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Gilroy',
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLangItem(
                      'tk'.tr,
                      'tk',
                      'assets/icons/tmflag.svg',
                    ),
                    const SizedBox(height: 12),
                    _buildLangItem(
                      'ru'.tr,
                      'ru',
                      'assets/icons/ruflag.svg',
                    ),
                    const SizedBox(height: 12), // Extra space at bottom
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildLangItem(String lang, String code, String flagAsset) {
    return Obx(() {
      bool isSelected = controller.currentLanguage.value == code;
      return GestureDetector(
        onTap: () {
          controller.changeLanguage(code);
          Get.back();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF22B241).withOpacity(0.05) : const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF22B241) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SvgPicture.asset(
                  flagAsset,
                  width: 32,
                  height: 24,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                lang,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontFamily: 'Gilroy',
                  color: isSelected ? const Color(0xFF22B241) : Colors.black87,
                ),
              ),
              const Spacer(),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF22B241),
                  size: 20,
                ),
            ],
          ),
        ),
      );
    });
  }

  void _showNotificationSettings() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bildiriş sazlamalary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SwitchListTile(
              value: true,
              activeColor: const Color(0xFF22B241),
              title: const Text('Täze harytlar'),
              onChanged: (v) {}),
            SwitchListTile(
              value: false,
              activeColor: const Color(0xFF22B241),
              title: const Text('Arzanladyşlar'),
              onChanged: (v) {}),
            SwitchListTile(
              value: true,
              activeColor: const Color(0xFF22B241),
              title: const Text('Sargyt ýagdaýy'),
              onChanged: (v) {}),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
