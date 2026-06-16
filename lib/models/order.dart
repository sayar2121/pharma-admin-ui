class Customer {
  final String id;
  final String name;
  final String phone;
  final String? address;
  final double? latitude;
  final double? longitude;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    String? addr;
    double? lat;
    double? lng;
    if (json['delivery_address'] is Map) {
      final addrMap = json['delivery_address'] as Map;
      addr = addrMap['address'] as String?;
      lat = _parseDouble(addrMap['lat'] ?? addrMap['latitude']);
      lng = _parseDouble(addrMap['lng'] ?? addrMap['longitude']);
    } else {
      addr = json['delivery_address']?.toString();
    }

    lat ??= _parseDouble(json['delivery_lat'] ?? json['drop_lat']);
    lng ??= _parseDouble(json['delivery_lng'] ?? json['drop_lng']);

    return Customer(
      id: json['customer_id'] ?? '',
      name: json['receiver_name'] ?? 'Unknown',
      phone: json['receiver_phone'] ?? '',
      address: addr,
      latitude: lat,
      longitude: lng,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': id,
      'receiver_name': name,
      'receiver_phone': phone,
      'delivery_address': address,
      'delivery_lat': latitude,
      'delivery_lng': longitude,
    };
  }
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

class Rider {
  final String id;
  final String name;
  final String phone;
  final String? vehicleNumber;
  final String? vehicleModel;

  Rider({
    required this.id,
    required this.name,
    required this.phone,
    this.vehicleNumber,
    this.vehicleModel,
  });

  factory Rider.fromJson(Map<String, dynamic> json) {
    return Rider(
      id: json['rider_id'] ?? '',
      name: json['rider_name'] ?? 'Unknown',
      phone: json['rider_phone'] ?? '',
      vehicleNumber: json['vehicle_number'],
      vehicleModel: json['vehicle_model'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rider_id': id,
      'rider_name': name,
      'rider_phone': phone,
      'vehicle_number': vehicleNumber,
      'vehicle_model': vehicleModel,
    };
  }
}

class OrderItem {
  final String medicineId;
  final String name;
  final int quantity;
  final double price; // Price per item

  OrderItem({
    required this.medicineId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  double get totalPrice => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      medicineId: json['medicine_id'] ?? '',
      name: json['medicine_name'] ?? json['name'] ?? 'Unknown',
      quantity: (json['quantity'] ?? 0) as int,
      price: (json['price_per_unit'] ?? json['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicine_id': medicineId,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }
}

class Order {
  final String id;
  final String type; // 'prescription', 'cart'
  final List<OrderItem> items;
  final double totalAmount;
  final double platformCharges;
  final double taxes;
  final double deliveryFee;
  final double pharmacyEarnings;
  final String? prescriptionImage;
  final String status; // 'broadcast', 'accepted', 'packing', 'out_for_delivery', 'delivered', 'cancelled'
  final String? paymentMethod;
  final String? pickupOtp;
  final String? dropOtp;
  final Customer customer;
  final Rider? rider;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.type,
    required this.items,
    required this.totalAmount,
    required this.platformCharges,
    required this.taxes,
    required this.deliveryFee,
    required this.pharmacyEarnings,
    this.prescriptionImage,
    required this.status,
    this.paymentMethod,
    this.pickupOtp,
    this.dropOtp,
    required this.customer,
    this.rider,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsData = json['items'] ?? [];
    
    // Robustly check if rider/driver details exist
    Rider? riderDetails;
    final riderData = json['rider'] ?? json['driver'] ?? json;
    final rName = riderData['assigned_driver_name'] ?? riderData['rider_name'] ?? riderData['driver_name'] ?? riderData['name'];
    
    if (rName != null && rName.toString().isNotEmpty && json['order_type'] != 'cart') { // Cart orders usually don't have riders in the same way, but just in case
      riderDetails = Rider(
        id: (riderData['assigned_driver_id'] ?? riderData['rider_id'] ?? riderData['driver_id'] ?? riderData['id'] ?? '').toString(),
        name: rName.toString(),
        phone: (riderData['assigned_driver_phone'] ?? riderData['rider_phone'] ?? riderData['driver_phone'] ?? riderData['phone'] ?? '').toString(),
        vehicleNumber: riderData['vehicle_number']?.toString(),
        vehicleModel: riderData['vehicle_model']?.toString(),
      );
    }

    final double totalBill = (json['total_bill_amount'] ?? 0.0).toDouble();
    final double platform = (json['platform_fee'] ?? 0.0).toDouble();
    final double tax = (json['taxes'] ?? 0.0).toDouble();
    final double delivery = (json['delivery_fee'] ?? 0.0).toDouble();
    final double earnings = totalBill - platform - tax - delivery;

    return Order(
      id: json['order_id'] ?? json['id'] ?? '',
      type: json['order_type'] ?? 'cart',
      items: itemsData.map((e) => OrderItem.fromJson(e as Map<String, dynamic>)).toList(),
      totalAmount: totalBill,
      platformCharges: platform,
      taxes: tax,
      deliveryFee: delivery,
      pharmacyEarnings: earnings,
      prescriptionImage: json['prescription_url'],
      status: json['order_status'] ?? 'broadcast',
      paymentMethod: json['payment_method'],
      pickupOtp: json['pickup_otp']?.toString(),
      dropOtp: json['drop_otp']?.toString(),
      customer: Customer.fromJson(json),
      rider: riderDetails,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': id,
      'order_type': type,
      'items': items.map((e) => e.toJson()).toList(),
      'total_bill_amount': totalAmount,
      'platform_fee': platformCharges,
      'taxes': taxes,
      'delivery_fee': deliveryFee,
      'prescription_url': prescriptionImage,
      'order_status': status,
      'payment_method': paymentMethod,
      'pickup_otp': pickupOtp,
      'drop_otp': dropOtp,
      'created_at': createdAt.toIso8601String(),
      ...customer.toJson(),
      if (rider != null) ...rider!.toJson(),
    };
  }

  Order copyWith({
    String? status,
    Rider? rider,
    String? paymentMethod,
    String? pickupOtp,
    String? dropOtp,
  }) {
    return Order(
      id: id,
      type: type,
      items: items,
      totalAmount: totalAmount,
      platformCharges: platformCharges,
      taxes: taxes,
      deliveryFee: deliveryFee,
      pharmacyEarnings: pharmacyEarnings,
      prescriptionImage: prescriptionImage,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      pickupOtp: pickupOtp ?? this.pickupOtp,
      dropOtp: dropOtp ?? this.dropOtp,
      customer: customer,
      rider: rider ?? this.rider,
      createdAt: createdAt,
    );
  }
}
