import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:atlas/modules/home/controllers/home_controller.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        leading: GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Icon(IconlyLight.arrow_left_circle, color: Color(0xFF1D1B20))),
        title: Text(
          'contact_us'.tr,
          style: const TextStyle(
            color: Color(0xFF1D1B20),
            fontWeight: FontWeight.w800,
            fontSize: 20,
            fontFamily: 'Gilroy',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1D1B20)),
      ),
      body: Obx(() {
        final contacts = controller.contactList;
        if (controller.isLoadingContact.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF4B2AA4),
            ),
          );
        }
        if (contacts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FeatherIcons.phoneOff,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'no_contact_info'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontFamily: 'Gilroy',
                  ),
                ),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contact List
              ...contacts.map((contact) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Phone Numbers
                      if (contact.phone1 != null || contact.phone2 != null || contact.phone3 != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('phone_numbers'.tr),
                            const SizedBox(height: 12),
                            if (contact.phone1 != null && contact.phone1!.isNotEmpty)
                              _buildContactCard(
                                icon: FeatherIcons.phone,
                                label: 'phone'.tr + ' 1',
                                value: contact.phone1!,
                                color: const Color(0xFF4B2AA4),
                                type: 'tel',
                              ),
                            if (contact.phone2 != null && contact.phone2!.isNotEmpty)
                              _buildContactCard(
                                icon: FeatherIcons.phone,
                                label: 'phone'.tr + ' 2',
                                value: contact.phone2!,
                                color: const Color(0xFF4B2AA4),
                                type: 'tel',
                              ),
                            if (contact.phone3 != null && contact.phone3!.isNotEmpty)
                              _buildContactCard(
                                icon: FeatherIcons.phone,
                                label: 'phone'.tr + ' 3',
                                value: contact.phone3!,
                                color: const Color(0xFF4B2AA4),
                                type: 'tel',
                              ),
                            const SizedBox(height: 20),
                          ],
                        ),

                      // Email
                      if (contact.email != null && contact.email!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('email'.tr),
                            const SizedBox(height: 12),
                            _buildContactCard(
                              icon: IconlyLight.message,
                              label: 'email_address'.tr,
                              value: contact.email!,
                              color: const Color(0xFF3498DB),
                              type: 'email',
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),

                      // Social Media
                      if ((contact.telegram != null && contact.telegram!.isNotEmpty) ||
                          (contact.tiktok != null && contact.tiktok!.isNotEmpty) ||
                          (contact.youtube != null && contact.youtube!.isNotEmpty) ||
                          (contact.facebook != null && contact.facebook!.isNotEmpty))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('social_media'.tr),
                            const SizedBox(height: 12),
                            if (contact.telegram != null && contact.telegram!.isNotEmpty)
                              _buildContactCard(
                                icon: IconlyLight.send,
                                label: 'Telegram',
                                value: contact.telegram!,
                                color: const Color(0xFF29B6F6),
                                type: 'telegram',
                              ),
                            if (contact.facebook != null && contact.facebook!.isNotEmpty)
                              _buildContactCard(
                                icon: FeatherIcons.facebook,
                                label: 'Facebook',
                                value: contact.facebook!,
                                color: const Color(0xFF1877F2),
                                type: 'url',
                              ),
                            if (contact.youtube != null && contact.youtube!.isNotEmpty)
                              _buildContactCard(
                                icon: FeatherIcons.youtube,
                                label: 'YouTube',
                                value: contact.youtube!,
                                color: const Color(0xFFFF0000),
                                type: 'url',
                              ),
                            if (contact.tiktok != null && contact.tiktok!.isNotEmpty)
                              _buildContactCard(
                                icon: FeatherIcons.video,
                                label: 'TikTok',
                                value: contact.tiktok!,
                                color: const Color(0xFF000000),
                                type: 'url',
                              ),
                          ],
                        ),
                    ],
                  )),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF4B2AA4),
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

  Widget _buildContactCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required String type,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleContactTap(value, type),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
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
                        label,
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
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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
                Icon(
                  FeatherIcons.externalLink,
                  size: 20,
                  color: color.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleContactTap(String value, String type) async {
    try {
      Uri uri;
      switch (type) {
        case 'tel':
          uri = Uri(scheme: 'tel', path: value);
          break;
        case 'email':
          uri = Uri(scheme: 'mailto', path: value);
          break;
        case 'telegram':
          String telegramId = value.replaceAll('@', '');
          uri = Uri.parse('https://t.me/$telegramId');
          break;
        case 'url':
        default:
          String url = value;
          if (!url.startsWith('http')) {
            url = 'https://$url';
          }
          uri = Uri.parse(url);
      }

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }
}
