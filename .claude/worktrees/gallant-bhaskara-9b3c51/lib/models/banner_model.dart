class BannerModel {
  final int? id;
  final String image;
  final String? title;
  final String? body;
  final String? link;

  const BannerModel({
    this.id,
    required this.image,
    this.title,
    this.body,
    this.link,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    final img = (json['img'] ?? json['image'] ?? '') as String;
    return BannerModel(
      id: json['id'] as int?,
      image: img,
      title: json['title'] as String?,
      body: json['body'] as String?,
      link: json['link'] as String?,
    );
  }
}
