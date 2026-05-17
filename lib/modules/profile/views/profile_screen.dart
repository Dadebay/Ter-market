import 'package:atlas/modules/favorites/views/favorites_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/modules/profile/controllers/language_controller.dart';
import 'package:atlas/modules/profile/views/language_page.dart';
import 'package:atlas/modules/main/controllers/feature_controllers.dart';
import 'package:atlas/modules/profile/views/about_page.dart';
import 'package:atlas/modules/profile/views/privacy_page.dart';
import 'package:atlas/modules/splash/views/splash_screen.dart';
import 'package:atlas/widgets/app_dialogs.dart';

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
        body: _LoggedInBody());
  }
}

// ─── Logged-in view ──────────────────────────────────────────────────────────

class _LoggedInBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMenuItem(
            HugeIcons.strokeRoundedGlobal,
            'language'.tr,
            () => Get.to(() => LanguagePage()),
            trailing: GetX<LanguageController>(
              init: LanguageController(),
              builder: (langCtrl) => Text(
                langCtrl.selectedLanguage.value == 'tk' ? 'TKM' : 'RUS',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF22B241),
                  fontFamily: 'Gilroy',
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            HugeIcons.strokeRoundedFavourite,
            'favorites'.tr,
            () => Get.to(() => const FavoritesScreen()),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            HugeIcons.strokeRoundedCovidInfo,
            'about'.tr,
            () => Get.to(() => const PrivacyPage()),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            HugeIcons.strokeRoundedInformationCircle,
            'about_us'.tr,
            () => Get.to(() => const AboutPage()),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            HugeIcons.strokeRoundedDelete02,
            'delete_account'.tr,
            () => _showDeleteAccountDialog(context),
            isDestructive: true,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

Widget _buildMenuItem(
  IconData icon,
  String title,
  VoidCallback onTap, {
  bool isDestructive = false,
  Widget? trailing,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.05),
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

void _showEditDialog(BuildContext context) {
  final nameCtrl = TextEditingController(text: 'Musteri');
  final phoneCtrl = TextEditingController(text: 'Musteri');

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(
        'edit_profile'.tr,
        style: const TextStyle(
          fontFamily: 'Gilroy',
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DialogField(
            controller: nameCtrl,
            label: 'full_name'.tr,
            icon: HugeIcons.strokeRoundedUser,
          ),
          const SizedBox(height: 12),
          _DialogField(
            controller: phoneCtrl,
            label: 'phone_number'.tr,
            icon: HugeIcons.strokeRoundedCall,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'cancel'.tr,
            style: const TextStyle(
              color: Color(0xFF22B241),
              fontWeight: FontWeight.w600,
              fontFamily: 'Gilroy',
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // auth.updateProfile(
            //   name: nameCtrl.text.trim(),
            //   phone: phoneCtrl.text.trim(),
            // );
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Text(
            'save'.tr,
            style: const TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

void _showDeleteAccountDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
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
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const HugeIcon(
                icon: HugeIcons.strokeRoundedDelete02,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'delete_account'.tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                fontFamily: 'Gilroy',
                color: Color(0xFF1D1B20),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'delete_account_confirm'.tr,
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
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'cancel'.tr,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Gilroy',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      Get.back();
                      try {
                        await FirebaseMessaging.instance.deleteToken();
                      } catch (_) {}
                      final storage = Get.find<GetStorage>();
                      storage.remove('fcm_token');
                      storage.remove('device_id');
                      storage.remove('device_registered');
                      storage.remove('auth_token');
                      AppDialogs.showSnackbar(
                        message: 'account_deleted'.tr,
                        icon: Icons.check_circle_rounded,
                        iconColor: const Color(0xFF22B241),
                      );
                      await Future.delayed(const Duration(seconds: 2));
                      Get.offAll(() => const SplashScreen());
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'yes'.tr,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Gilroy',
                        color: Colors.black45,
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

class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;

  const _DialogField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Gilroy'),
        prefixIcon: HugeIcon(icon: icon, size: 20, color: const Color(0xFF22B241)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        contentPadding: const EdgeInsets.all(14),
      ),
      style: const TextStyle(fontFamily: 'Gilroy', fontSize: 15),
    );
  }
}
