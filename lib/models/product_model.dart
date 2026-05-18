import 'package:get/get.dart';
import 'package:atlas/modules/profile/controllers/language_controller.dart';

class ProductModel {
  final int id;
  final String name;
  final String nameTk;
  final String nameRu;
  final String? image;
  final double price;
  final double? oldPrice;
  final double? discount;
  final double rating;
  final int? categoryId;
  final int? subCategoryId;
  final String? description;
  final String? storeName;
  final String? location;
  final bool isNew;

  final List<String> allImages;
  final String? descriptionTk;
  final String? descriptionRu;
  final String? categoryName;
  final String? subCategoryName;

  String get localizedName {
    try {
      final lang = Get.find<LanguageController>().selectedLanguage.value;
      return lang == 'ru' ? nameRu : nameTk;
    } catch (_) {
      return name;
    }
  }

  const ProductModel({
    required this.id,
    required this.name,
    this.nameTk = '',
    this.nameRu = '',
    this.image,
    required this.price,
    this.oldPrice,
    this.discount,
    this.rating = 0.0,
    this.categoryId,
    this.subCategoryId,
    this.description,
    this.storeName,
    this.location,
    this.isNew = false,
    this.allImages = const [],
    this.descriptionTk,
    this.descriptionRu,
    this.categoryName,
    this.subCategoryName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    final nameTk = (json['name_tk'] ?? json['name'] ?? json['title'] ?? '') as String;
    final nameRu = (json['name_ru'] ?? json['name'] ?? json['title'] ?? '') as String;
    return ProductModel(
      id: json['id'] as int,
      name: nameTk.isNotEmpty ? nameTk : nameRu,
      nameTk: nameTk,
      nameRu: nameRu,
      image: _parseFirstImage(json),
      allImages: _parseAllImages(json),
      price: parseDouble(json['discounted_price'] ?? json['price']),
      oldPrice: (json['discounted_price'] != null && json['price'] != null && parseDouble(json['discounted_price']) != parseDouble(json['price'])) ? parseDouble(json['price']) : null,
      discount: json['skidka'] != null ? parseDouble(json['skidka']) : null,
      rating: parseDouble(json['rating']),
      categoryId: json['category'] is int ? json['category'] as int : (json['category']?['id'] as int?),
      subCategoryId: json['sub_category'] is int ? json['sub_category'] as int : (json['sub_category']?['id'] as int?),
      description: (json['description_tk'] ?? json['description_ru'] ?? json['description']) as String?,
      descriptionTk: json['description_tk'] as String?,
      descriptionRu: json['description_ru'] as String?,
      categoryName: json['category'] is Map ? (json['category']['title_tk'] ?? json['category']['title_ru']) as String? : null,
      subCategoryName: json['sub_category'] is Map ? (json['sub_category']['title_tk'] ?? json['sub_category']['title_ru']) as String? : null,
      storeName: json['store_name'] as String?,
      location: json['location'] as String?,
      isNew: (json['is_new'] as bool?) ?? false,
    );
  }

  static String? _parseFirstImage(Map<String, dynamic> json) {
    final images = json['images'];
    if (images is List && images.isNotEmpty) {
      final first = images.first;
      if (first is String) return first;
      if (first is Map) return (first['img'] ?? first['image']) as String?;
    }
    return json['image'] as String?;
  }

  static List<String> _parseAllImages(Map<String, dynamic> json) {
    final images = json['images'];
    if (images is List) {
      return images
          .map<String>((e) {
            if (e is String) return e;
            if (e is Map) return (e['img'] ?? e['image'] ?? '') as String;
            return '';
          })
          .where((s) => s.isNotEmpty)
          .toList();
    }
    final single = json['image'] as String?;
    return single != null ? [single] : [];
  }
}

class PaginatedProducts {
  final int count;
  final String? next;
  final String? previous;
  final List<ProductModel> results;

  const PaginatedProducts({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedProducts.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'] as List<dynamic>? ?? [];
    return PaginatedProducts(
      count: json['count'] as int? ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: rawResults.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
