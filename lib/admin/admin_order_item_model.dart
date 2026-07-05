class AdminOrderItemModel {
  final int id;
  final int? productId;
  final String? productName;
  final String? productImage;
  final int quantity;
  final double price;
  final double? totalPrice;

  const AdminOrderItemModel({
    required this.id,
    this.productId,
    this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
    this.totalPrice,
  });

  factory AdminOrderItemModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    String? image;
    final images = json['product_images'];
    if (images is List && images.isNotEmpty) {
      image = images[0]['img'] as String?;
    }

    return AdminOrderItemModel(
      id: json['id'] as int,
      productId: json['product'] as int?,
      productName: json['product_name'] as String?,
      productImage: image,
      quantity: (json['quantity'] as int?) ?? 1,
      price: parseDouble(json['price_at_purchase']),
      totalPrice: parseDouble(json['cost']),
    );
  }
}
