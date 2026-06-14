class AdminOrderModel {
  final int id;
  final String? orderNumber;
  final String? deviceId;
  final String? regionName;
  final String? phoneNumber;
  final String? address;
  final String? deliveryTime;
  final String? deliveryType;
  final int? region;
  final String? paymentStatus;
  final double totalPrice;
  final String? createdAt;
  final String? orderStatus;
  final String? status;

  const AdminOrderModel({
    required this.id,
    this.orderNumber,
    this.deviceId,
    this.regionName,
    this.phoneNumber,
    this.address,
    this.deliveryTime,
    this.deliveryType,
    this.region,
    this.paymentStatus,
    required this.totalPrice,
    this.createdAt,
    this.orderStatus,
    this.status,
  });

  factory AdminOrderModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return AdminOrderModel(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String?,
      deviceId: json['device_id'] as String?,
      regionName: json['region_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      address: json['address'] as String?,
      deliveryTime: json['delivery_time'] as String?,
      deliveryType: json['delivery_type'] as String?,
      region: json['region'] as int?,
      paymentStatus: json['payment_status'] as String?,
      totalPrice: parseDouble(json['total_price']),
      createdAt: json['created_at'] as String?,
      orderStatus: json['order_status'] as String?,
      status: json['status'] as String?,
    );
  }
}
