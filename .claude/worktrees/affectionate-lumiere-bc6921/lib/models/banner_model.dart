class BannerModel {
  final int id;
  final String image;
  final String? title;
  final String? link;

  const BannerModel({
    required this.id,
    required this.image,
    this.title,
    this.link,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as int,
      image: json['image'] as String,
      title: json['title'] as String?,
      link: json['link'] as String?,
    );
  }
}
