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
  final String? brandIcon;

  String get localizedName {
    try {
      final lang = Get.find<LanguageController>().selectedLanguage.value;
      return lang == 'ru' ? nameRu : nameTk;
    } catch (_) {
      return name;
    }
  }

  String get localizedDescription {
    try {
      final lang = Get.find<LanguageController>().selectedLanguage.value;
      return lang == 'ru' ? (descriptionRu ?? description ?? '') : (descriptionTk ?? description ?? '');
    } catch (_) {
      return description ?? '';
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
    this.brandIcon,
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
      brandIcon: _parseBrandIcon(json),
    );
  }

  static String? _parseBrandIcon(Map<String, dynamic> json) {
    final brend = json['brend'];
    if (brend is Map) {
      final icon = brend['icon'] as String?;
      if (icon != null && icon.isNotEmpty) return _toAbsoluteUrl(icon);
    }
    return null;
  }

  static const String _mediaBase = 'https://termarket.com.tm';
  static const String _legacyBase = 'http://216.250.11.77:7000';

  static String _toAbsoluteUrl(String url) {
    if (url.startsWith(_legacyBase)) {
      return url.replaceFirst(_legacyBase, _mediaBase);
    }
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '$_mediaBase$url';
    return url;
  }

  static String? _parseFirstImage(Map<String, dynamic> json) {
    final images = json['images'];
    if (images is List && images.isNotEmpty) {
      final first = images.first;
      String? raw;
      if (first is String) raw = first;
      if (first is Map) raw = (first['img'] ?? first['image']) as String?;
      return raw != null ? _toAbsoluteUrl(raw) : null;
    }
    final raw = json['image'] as String?;
    return raw != null ? _toAbsoluteUrl(raw) : null;
  }

  static List<String> _parseAllImages(Map<String, dynamic> json) {
    final images = json['images'];
    if (images is List) {
      return images
          .map<String>((e) {
            String raw = '';
            if (e is String) raw = e;
            if (e is Map) raw = (e['img'] ?? e['image'] ?? '') as String;
            return raw.isNotEmpty ? _toAbsoluteUrl(raw) : '';
          })
          .where((s) => s.isNotEmpty)
          .toList();
    }
    final single = json['image'] as String?;
    return single != null ? [_toAbsoluteUrl(single)] : [];
  }
}

class PaginatedProducts {
  final int count;
  final String? next;
  final String? previous;
  final List<ProductModel> results;
  final List<Map<String, dynamic>> availableBrands;

  const PaginatedProducts({
    required this.count,
    this.next,
    this.previous,
    required this.results,
    this.availableBrands = const [],
  });

  factory PaginatedProducts.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'] as List<dynamic>? ?? [];
    final rawBrands = json['available_brands'] as List<dynamic>? ?? [];
    return PaginatedProducts(
      count: json['count'] as int? ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: rawResults.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList(),
      availableBrands: rawBrands.map((e) => e as Map<String, dynamic>).toList(),
    );
  }
}
