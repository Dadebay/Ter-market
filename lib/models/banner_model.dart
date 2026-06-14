import 'package:atlas/models/product_model.dart';

class BannerModel {
  final int? id;
  final String image;
  final String? title;
  final String? body;
  final String? link;
  final List<ProductModel>? products;
  final int? brendId;

  const BannerModel({
    this.id,
    required this.image,
    this.title,
    this.body,
    this.link,
    this.products,
    this.brendId,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    final img = (json['img'] ?? json['image'] ?? '') as String;

    List<ProductModel>? productsList;
    if (json['products'] != null && json['products'] is List) {
      try {
        productsList = (json['products'] as List).map((p) => ProductModel.fromJson(p as Map<String, dynamic>)).toList();
      } catch (e) {
        print('[BannerModel] Error parsing products: $e');
      }
    }

    // "brend" field can be int, or null
    int? brendId;
    final brendRaw = json['brend'];
    if (brendRaw is int) {
      brendId = brendRaw;
    } else if (brendRaw is String) {
      brendId = int.tryParse(brendRaw);
    }

    return BannerModel(
      id: json['id'] as int?,
      image: img,
      title: json['title'] as String?,
      body: json['body'] as String?,
      link: json['link'] as String?,
      products: productsList,
      brendId: brendId,
    );
  }
}
