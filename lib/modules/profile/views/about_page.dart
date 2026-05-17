import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/core/api/api_service.dart';
import 'package:atlas/modules/profile/controllers/language_controller.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _content;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _api.getAboutContent();
      setState(() {
        _content = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(
          'about_us'.tr,
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
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            size: 24,
            color: Color(0xFF1D1B20),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF22B241)),
      );
    }

    if (_error != null || _content == null || _content!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedCovidInfo,
              size: 48,
              color: Colors.black26,
            ),
            const SizedBox(height: 12),
            Text(
              'error_occurred'.tr,
              style: const TextStyle(
                fontFamily: 'Gilroy',
                fontSize: 15,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      );
    }

    final lang = Get.find<LanguageController>().selectedLanguage.value;
    final text = (lang == 'tk' ? _content!['content_tk'] : _content!['content_ru']) as String? ?? '';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Gilroy',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1D1B20),
            height: 1.7,
          ),
        ),
      ),
    );
  }
}
