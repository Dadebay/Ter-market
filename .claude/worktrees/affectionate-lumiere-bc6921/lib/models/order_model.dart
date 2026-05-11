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
  final List<OrderItemRequest> items;

  const CreateOrderRequest({
    required this.deviceId,
    required this.phoneNumber,
    required this.address,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
        'phone_number': phoneNumber,
        'address': address,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

class OrderItemModel {
  final int id;
  final int productId;
  final String? productName;
  final int quantity;
  final double price;

  const OrderItemModel({
    required this.id,
    required this.productId,
    this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return OrderItemModel(
      id: json['id'] as int,
      productId: json['product'] is int ? json['product'] as int : (json['product']?['id'] as int? ?? 0),
      productName: json['product'] is Map<String, dynamic> ? (json['product'] as Map<String, dynamic>)['name'] as String? : null,
      quantity: json['quantity'] as int? ?? 1,
      price: parseDouble(json['price']),
    );
  }
}

class OrderModel {
  final int id;
  final String deviceId;
  final String? phoneNumber;
  final String? address;
  final String status;
  final List<OrderItemModel> items;
  final double totalPrice;
  final String? createdAt;

  const OrderModel({
    required this.id,
    required this.deviceId,
    this.phoneNumber,
    this.address,
    required this.status,
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
      deviceId: json['device_id'] as String? ?? '',
      phoneNumber: json['phone_number'] as String?,
      address: json['address'] as String?,
      status: json['status'] as String? ?? 'pending',
      items: rawItems.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>)).toList(),
      totalPrice: parseDouble(json['total_price']),
      createdAt: json['created_at'] as String?,
    );
  }
}
