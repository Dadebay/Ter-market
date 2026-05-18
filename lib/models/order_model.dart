class PaymentMethod {
  final int id;
  final String nameTk;
  final String nameRu;

  const PaymentMethod({
    required this.id,
    required this.nameTk,
    required this.nameRu,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as int,
      nameTk: json['name_tk'] as String? ?? '',
      nameRu: json['name_ru'] as String? ?? '',
    );
  }

  String localizedName(String lang) => lang == 'ru' ? nameRu : nameTk;
}

class OrderItemRequest {
  final int product;
  final int quantity;

  const OrderItemRequest({required this.product, required this.quantity});

  Map<String, dynamic> toJson() => {'product': product, 'quantity': quantity};
}

class CreateOrderRequest {
  final String deviceId;
  final String phoneNumber;
  final String address;
  final String paymentStatus;
  final List<OrderItemRequest> items;

  const CreateOrderRequest({
    required this.deviceId,
    required this.phoneNumber,
    required this.address,
    required this.paymentStatus,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
        'phone_number': phoneNumber,
        'address': address,
        'payment_status': paymentStatus,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

class OrderItemModel {
  final int id;
  final int productId;
  final String? productName;
  final int quantity;
  final double price;
  final double cost;
  final List<String> productImages;

  const OrderItemModel({
    required this.id,
    required this.productId,
    this.productName,
    required this.quantity,
    required this.price,
    this.cost = 0,
    this.productImages = const [],
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    final rawImages = json['product_images'] as List<dynamic>? ?? [];
    final imageUrls = rawImages.map((e) => (e as Map<String, dynamic>)['img'] as String? ?? '').where((url) => url.isNotEmpty).toList();

    return OrderItemModel(
      id: json['id'] as int,
      productId: json['product'] is int ? json['product'] as int : (json['product']?['id'] as int? ?? 0),
      productName: json['product_name'] as String? ?? (json['product'] is Map<String, dynamic> ? (json['product'] as Map<String, dynamic>)['name'] as String? : null),
      quantity: json['quantity'] as int? ?? 1,
      price: parseDouble(json['price_at_purchase'] ?? json['price']),
      cost: parseDouble(json['cost'] ?? json['price']),
      productImages: imageUrls,
    );
  }
}

class OrderModel {
  final int id;
  final String? orderNumber;
  final String deviceId;
  final String? phoneNumber;
  final String? address;
  final String status;
  final String? paymentStatus;
  final List<OrderItemModel> items;
  final double totalPrice;
  final String? createdAt;

  const OrderModel({
    required this.id,
    this.orderNumber,
    required this.deviceId,
    this.phoneNumber,
    this.address,
    required this.status,
    this.paymentStatus,
    required this.items,
    required this.totalPrice,
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    final rawItems = json['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String?,
      deviceId: json['device_id'] as String? ?? '',
      phoneNumber: json['phone_number'] as String?,
      address: json['address'] as String?,
      status: json['status'] as String? ?? 'pending',
      paymentStatus: json['payment_status'] as String?,
      items: rawItems.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>)).toList(),
      totalPrice: parseDouble(json['total_price']),
      createdAt: json['created_at'] as String?,
    );
  }
}
