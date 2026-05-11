import 'package:atlas/modules/main/controllers/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/modules/profile/controllers/language_controller.dart';
import 'package:atlas/modules/profile/views/language_page.dart';
import 'package:atlas/modules/main/controllers/feature_controllers.dart';
import 'package:atlas/modules/profile/views/help_support_page.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(
          'profile'.tr,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Gilroy',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildMenuSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
            onPressed: () => _showEditDialog(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF22B241).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const HugeIcon(
                icon: HugeIcons.strokeRoundedPencilEdit01,
                color: Color(0xFF22B241),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        const SizedBox(height: 12),
        _buildMenuItem(
          HugeIcons.strokeRoundedGlobal,
          'language'.tr,
          () => Get.to(() => LanguagePage()),
          trailing: GetX<LanguageController>(
            init: LanguageController(),
            builder: (langCtrl) {
              return Text(
                langCtrl.selectedLanguage.value == 'tk' ? 'TKM' : 'RUS',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF22B241),
                  fontFamily: 'Gilroy',
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          HugeIcons.strokeRoundedFavourite,
          'favorites'.tr,
          () => Get.find<MainController>().changeIndex(2),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          HugeIcons.strokeRoundedQuestion,
          'help_support'.tr,
          () => Get.to(() => const HelpSupportPage()),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          HugeIcons.strokeRoundedCovidInfo,
          'about'.tr,
          () {},
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          HugeIcons.strokeRoundedLogout01,
          'logout'.tr,
          () => _showLogoutDialog(),
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap,
      {bool isDestructive = false, Widget? trailing}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                HugeIcon(
                  icon: icon,
                  color: isDestructive ? Colors.red : Colors.black87,
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : Colors.black87,
                      fontSize: 15,
                      fontFamily: 'Gilroy',
                    ),
                  ),
                ),
                trailing ??
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      size: 18,
                      color: Colors.black26,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // DÜZEDILEN WE IŞLEÝÄN EDIT DIALOGY
  void _showEditDialog() {
    final TextEditingController nameController =
        TextEditingController(text: controller.userName.value);
    final TextEditingController phoneController =
        TextEditingController(text: controller.userPhone.value);

    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'edit_profile'.tr,
            style: const TextStyle(
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'full_name'.tr,
                    labelStyle: const TextStyle(fontFamily: 'Gilroy'),
                    prefixIcon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedUser,
                      size: 20,
                      color: Color(0xFF22B241),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9F9F9),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                  style: const TextStyle(fontFamily: 'Gilroy', fontSize: 15),
                ),
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'phone_number'.tr,
                  labelStyle: const TextStyle(fontFamily: 'Gilroy'),
                  prefixIcon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedCall,
                    size: 20,
                    color: Color(0xFF22B241),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
                  contentPadding: const EdgeInsets.all(14),
                ),
                style: const TextStyle(fontFamily: 'Gilroy', fontSize: 15),
              ),
            ],
          ),
          actions: [
            // Cancel düwmesi
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'cancel'.tr,
                style: const TextStyle(
                  color: Color(0xFF22B241),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Gilroy',
                  fontSize: 14,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                controller.userName.value = nameController.text;
                controller.userPhone.value = phoneController.text;

                Get.back();

                Get.snackbar(
                  'success'.tr,
                  'profile_updated'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFF22B241),
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22B241),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('save'.tr),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: Get.context!,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedLogout01,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'logout'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Gilroy',
                  color: Color(0xFF1D1B20),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'deleteProfileDescription'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Gilroy',
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'cancel'.tr,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Gilroy',
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'yes'.tr,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Gilroy',
                        ),
                      ),
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
}
