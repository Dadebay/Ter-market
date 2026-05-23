class RegionModel {
  final int id;
  final String name;
  final double price;
  final double exPrice;

  const RegionModel({
    required this.id,
    required this.name,
    required this.price,
    required this.exPrice,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return RegionModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      price: parseDouble(json['price']),
      exPrice: parseDouble(json['ex_price']),
    );
  }
}

class DeliveryType {
  final int id;
  final String titleTk;
  final String titleRu;

  const DeliveryType({required this.id, required this.titleTk, required this.titleRu});

  factory DeliveryType.fromJson(Map<String, dynamic> json) => DeliveryType(
        id: json['id'] as int,
        titleTk: json['title_tk'] as String? ?? '',
        titleRu: json['title_ru'] as String? ?? '',
      );

  String localizedName(String lang) => lang == 'ru' ? titleRu : titleTk;
}

class DeliveryTime {
  final int id;
  final String time1;
  final String time2;
  final String? formattedTime;

  const DeliveryTime({required this.id, required this.time1, required this.time2, this.formattedTime});

  factory DeliveryTime.fromJson(Map<String, dynamic> json) => DeliveryTime(
        id: json['id'] as int,
        time1: json['time1'] as String? ?? '',
        time2: json['time2'] as String? ?? '',
        formattedTime: json['formatted_time'] as String?,
      );

  String get displayTime {
    if (formattedTime != null && formattedTime!.isNotEmpty) return formattedTime!;
    final t1 = time1.length >= 5 ? time1.substring(0, 5) : time1;
    final t2 = time2.length >= 5 ? time2.substring(0, 5) : time2;
    return '$t1 - $t2';
  }
}

class DialogNoticeModel {
  final int id;
  final String bodyTk;
  final String bodyRu;
  final DateTime createdAt;

  const DialogNoticeModel({
    required this.id,
    required this.bodyTk,
    required this.bodyRu,
    required this.createdAt,
  });

  factory DialogNoticeModel.fromJson(Map<String, dynamic> json) {
    return DialogNoticeModel(
      id: json['id'] as int,
      bodyTk: json['body_tk'] as String? ?? '',
      bodyRu: json['body_ru'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String localizedBody(String lang) => lang == 'ru' ? bodyRu : bodyTk;
}

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
  final int? deliveryTypeId;
  final int? deliveryTimeId;
  final int? regionId;
  final List<OrderItemRequest> items;

  const CreateOrderRequest({
    required this.deviceId,
    required this.phoneNumber,
    required this.address,
    required this.paymentStatus,
    this.deliveryTypeId,
    this.deliveryTimeId,
    this.regionId,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
        'phone_number': phoneNumber,
        'address': address,
        'payment_status': paymentStatus,
        if (deliveryTypeId != null) 'delivery_type': deliveryTypeId,
        if (deliveryTimeId != null) 'delivery_time': deliveryTimeId,
        if (regionId != null) 'region': regionId,
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
  final int? deliveryTypeId;
  final int? deliveryTimeId;
  final int? regionId;
  final DeliveryType? deliveryTypeDetail;
  final DeliveryTime? deliveryTimeDetail;
  final RegionModel? regionDetail;
  final String? orderStatus;

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
    this.deliveryTypeId,
    this.deliveryTimeId,
    this.regionId,
    this.deliveryTypeDetail,
    this.deliveryTimeDetail,
    this.regionDetail,
    this.orderStatus,
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
      deliveryTypeId: json['delivery_type'] as int?,
      deliveryTimeId: json['delivery_time'] as int?,
      regionId: json['region'] as int?,
      deliveryTypeDetail: json['delivery_type_detail'] != null ? DeliveryType.fromJson(json['delivery_type_detail'] as Map<String, dynamic>) : null,
      deliveryTimeDetail: json['delivery_time_detail'] != null ? DeliveryTime.fromJson(json['delivery_time_detail'] as Map<String, dynamic>) : null,
      regionDetail: json['region_detail'] != null ? RegionModel.fromJson(json['region_detail'] as Map<String, dynamic>) : null,
      orderStatus: json['order_status'] as String?,
    );
  }
}
