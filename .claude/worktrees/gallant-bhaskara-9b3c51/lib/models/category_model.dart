class CategoryModel {
  final int id;
  final String name;
  final String? image;

  const CategoryModel({
    required this.id,
    required this.name,
    this.image,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      image: json['image'] as String?,
    );
  }
}

class SubCategoryModel {
  final int id;
  final String name;
  final String? image;
  final int categoryId;

  const SubCategoryModel({
    required this.id,
    required this.name,
    this.image,
    required this.categoryId,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      image: json['image'] as String?,
      categoryId: json['category'] is int
          ? json['category'] as int
          : (json['category']?['id'] as int? ?? 0),
    );
  }
}
