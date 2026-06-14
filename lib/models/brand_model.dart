import 'package:get/get.dart';
import 'package:atlas/modules/profile/controllers/language_controller.dart';

class BrandModel {
  final int id;
  final String titleTk;
  final String titleRu;
  final String? icon;
  final String? categoryTitleTk;
  final String? categoryTitleRu;

  const BrandModel({
    required this.id,
    required this.titleTk,
    required this.titleRu,
    this.icon,
    this.categoryTitleTk,
    this.categoryTitleRu,
  });

  String get localizedName {
    try {
      final lang = Get.find<LanguageController>().selectedLanguage.value;
      return lang == 'ru' ? titleRu : titleTk;
    } catch (_) {
      return titleTk.isNotEmpty ? titleTk : titleRu;
    }
  }

  String? get localizedCategory {
    try {
      final lang = Get.find<LanguageController>().selectedLanguage.value;
      return lang == 'ru' ? categoryTitleRu : categoryTitleTk;
    } catch (_) {
      return categoryTitleTk;
    }
  }

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    final tk = (json['title_tk'] ?? json['name'] ?? '') as String;
    final ru = (json['title_ru'] ?? json['name'] ?? '') as String;
    final cat = json['brendscategory'] as Map<String, dynamic>?;
    return BrandModel(
      id: json['id'] as int,
      titleTk: tk,
      titleRu: ru,
      icon: json['icon'] as String?,
      categoryTitleTk: cat?['title_tk'] as String?,
      categoryTitleRu: cat?['title_ru'] as String?,
    );
  }
}
