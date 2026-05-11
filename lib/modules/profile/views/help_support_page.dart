// modules/profile/views/help_support_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(
          'help_support'.tr,
          style: const TextStyle(
            color: Color(0xFF1D1B20),
            fontWeight: FontWeight.w800,
            fontSize: 20,
            fontFamily: 'Gilroy',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            size: 24,
            color: Color(0xFF1D1B20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            _buildWelcomeHeader(),
            const SizedBox(height: 32),

            // FAQ Section
            _buildSectionHeader('frequently_asked'.tr),
            const SizedBox(height: 16),
            _buildFaqSection(),
            const SizedBox(height: 32),

            // Contact Section
            _buildSectionHeader('contact_us'.tr),
            const SizedBox(height: 16),
            _buildContactSection(),
            const SizedBox(height: 32),

            // Social Section
            _buildSectionHeader('social_media'.tr),
            const SizedBox(height: 16),
            _buildSocialSection(),
            const SizedBox(height: 40),

            // Version Info
            _buildVersionInfo(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF22B241),
            const Color(0xFF22B241).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22B241).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedCustomerService,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(width: 16),
            Text(
              '+993 65 12 34 56'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                fontFamily: 'Gilroy',
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Text(
            'contact_us'
                .tr, // Reusing existing key or we could add a better one
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Gilroy',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF22B241),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            fontFamily: 'Gilroy',
            color: Color(0xFF1D1B20),
          ),
        ),
      ],
    );
  }

  Widget _buildFaqSection() {
    return Column(
      children: [
        _buildFaqItem('how_to_order'.tr, 'how_to_order_desc'.tr),
        const SizedBox(height: 12),
        _buildFaqItem('payment_methods'.tr, 'payment_methods_desc'.tr),
        const SizedBox(height: 12),
        _buildFaqItem('delivery_time'.tr, 'delivery_time_desc'.tr),
        const SizedBox(height: 12),
        _buildFaqItem('return_policy'.tr, 'return_policy_desc'.tr),
      ],
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          childrenPadding:
              const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          iconColor: const Color(0xFF22B241),
          collapsedIconColor: Colors.black26,
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'Gilroy',
              color: Color(0xFF1D1B20),
            ),
          ),
          children: [
            Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Gilroy',
                color: Colors.black54,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Column(
      children: [
        _buildContactCard(
          HugeIcons.strokeRoundedCall,
          'phone'.tr,
          '+993 65 12 34 56',
          const Color(0xFF22B241),
          () => _makePhoneCall('+99365123456'),
        ),
        const SizedBox(height: 12),
        _buildContactCard(
          HugeIcons.strokeRoundedSmsCode,
          'email'.tr,
          'support@atlas.com',
          const Color(0xFF3498DB),
          () => _sendEmail('support@atlas.com'),
        ),
        const SizedBox(height: 12),
        _buildContactCard(
          HugeIcons.strokeRoundedTelegram,
          'telegram'.tr,
          '@atlas_support',
          const Color(0xFF29B6F6),
          () => _openTelegram('atlas_support'),
        ),
      ],
    );
  }

  Widget _buildContactCard(IconData icon, String title, String value,
      Color color, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.03)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: HugeIcon(
                  icon: icon,
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black45,
                        fontFamily: 'Gilroy',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D1B20),
                        fontFamily: 'Gilroy',
                      ),
                    ),
                  ],
                ),
              ),
              const HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                size: 18,
                color: Colors.black12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialSection() {
    return Row(
      children: [
        Expanded(
          child: _buildSocialItem(
            HugeIcons.strokeRoundedInstagram,
            'Instagram',
            const Color(0xFFE1306C),
            () => _openUrl('https://instagram.com/atlas'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSocialItem(
            HugeIcons.strokeRoundedTelegram,
            'Telegram',
            const Color(0xFF0088CC),
            () => _openUrl('https://t.me/atlas'),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialItem(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.03)),
        ),
        child: Column(
          children: [
            HugeIcon(
              icon: icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: 'Gilroy',
                color: Color(0xFF1D1B20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'version'.tr,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: 'Gilroy',
                color: Colors.black26,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '© 2024 Atlas. All rights reserved.',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              fontFamily: 'Gilroy',
              color: Colors.black12,
            ),
          ),
        ],
      ),
    );
  }

  // Funksiýalar
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Get.snackbar('error_title'.tr, 'cant_call'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Get.snackbar('error_title'.tr, 'cant_send_email'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> _openTelegram(String username) async {
    final Uri launchUri = Uri.parse('https://t.me/$username');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('error_title'.tr, 'cant_open'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> _openUrl(String url) async {
    final Uri launchUri = Uri.parse(url);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('error_title'.tr, 'cant_open'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }
}
