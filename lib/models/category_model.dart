import 'package:get/get.dart';
import 'package:atlas/modules/profile/controllers/language_controller.dart';

class CategoryModel {
  final int id;
  final String name;
  final String titleTk;
  final String titleRu;
  final String? image;
  final int order;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.titleTk,
    required this.titleRu,
    this.image,
    this.order = 0,
  });

  String get localizedName {
    try {
      final lang = Get.find<LanguageController>().selectedLanguage.value;
      return lang == 'ru' ? titleRu : titleTk;
    } catch (_) {
      return name;
    }
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final titleTk = (json['title_tk'] ?? json['name'] ?? '') as String;
    final titleRu = (json['title_ru'] ?? json['name'] ?? '') as String;
    return CategoryModel(
      id: json['id'] as int,
      name: titleTk.isNotEmpty ? titleTk : titleRu,
      titleTk: titleTk,
      titleRu: titleRu,
      image: json['icon'] as String?,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }
}

class SubCategoryModel {
  final int id;
  final String name;
  final String titleTk;
  final String titleRu;
  final String? image;
  final int categoryId;
  final int order;

  const SubCategoryModel({
    required this.id,
    required this.name,
    required this.titleTk,
    required this.titleRu,
    this.image,
    required this.categoryId,
    this.order = 0,
  });

  String get localizedName {
    try {
      final lang = Get.find<LanguageController>().selectedLanguage.value;
      return lang == 'ru' ? titleRu : titleTk;
    } catch (_) {
      return name;
    }
  }

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    final titleTk = (json['title_tk'] ?? json['name'] ?? '') as String;
    final titleRu = (json['title_ru'] ?? json['name'] ?? '') as String;
    return SubCategoryModel(
      id: json['id'] as int,
      name: titleTk.isNotEmpty ? titleTk : titleRu,
      titleTk: titleTk,
      titleRu: titleRu,
      image: json['icon'] as String?,
      categoryId: json['category'] is int ? json['category'] as int : (json['category']?['id'] as int? ?? 0),
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }
}
