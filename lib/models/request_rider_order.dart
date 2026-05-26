class RequestRiderOrder {
	final String orderType;
	final String vehicleType;
	final String pickupAddress;
	final double pickupLat;
	final double pickupLng;
	final String pickupContactName;
	final String pickupContactPhone;
	final String dropAddress;
	final double dropLat;
	final double dropLng;
	final String dropContactName;
	final String dropContactPhone;
	final double? distanceKm;
	final int? estimatedTimeMins;
	final String paymentMethod;
	final int? itemCount;
	final String? parcelType;
	final double? weightKg;

	RequestRiderOrder({
		required this.orderType,
		required this.vehicleType,
		required this.pickupAddress,
		required this.pickupLat,
		required this.pickupLng,
		required this.pickupContactName,
		required this.pickupContactPhone,
		required this.dropAddress,
		required this.dropLat,
		required this.dropLng,
		required this.dropContactName,
		required this.dropContactPhone,
		this.distanceKm,
		this.estimatedTimeMins,
		required this.paymentMethod,
		this.itemCount,
		this.parcelType,
		this.weightKg,
	});

	factory RequestRiderOrder.fromJson(Map<String, dynamic> json) {
		return RequestRiderOrder(
			orderType: json['order_type'] ?? '',
			vehicleType: json['vehicle_type'] ?? '',
			pickupAddress: json['pickup_address'] ?? '',
			pickupLat: (json['pickup_lat'] ?? 0).toDouble(),
			pickupLng: (json['pickup_lng'] ?? 0).toDouble(),
			pickupContactName: json['pickup_contact_name'] ?? '',
			pickupContactPhone: json['pickup_contact_phone'] ?? '',
			dropAddress: json['drop_address'] ?? '',
			dropLat: (json['drop_lat'] ?? 0).toDouble(),
			dropLng: (json['drop_lng'] ?? 0).toDouble(),
			dropContactName: json['drop_contact_name'] ?? '',
			dropContactPhone: json['drop_contact_phone'] ?? '',
			distanceKm: json['distance_km'] == null
					? null
					: (json['distance_km'] as num).toDouble(),
			estimatedTimeMins: json['estimated_time_mins'],
			paymentMethod: json['payment_method'] ?? '',
			itemCount: json['item_count'],
			parcelType: json['parcel_type'],
			weightKg: json['weight_kg'] == null
					? null
					: (json['weight_kg'] as num).toDouble(),
		);
	}

	Map<String, dynamic> toJson() {
		final payload = <String, dynamic>{
			'order_type': orderType,
			'vehicle_type': vehicleType,
			'pickup_address': pickupAddress,
			'pickup_lat': pickupLat,
			'pickup_lng': pickupLng,
			'pickup_contact_name': pickupContactName,
			'pickup_contact_phone': pickupContactPhone,
			'drop_address': dropAddress,
			'drop_lat': dropLat,
			'drop_lng': dropLng,
			'drop_contact_name': dropContactName,
			'drop_contact_phone': dropContactPhone,
			'payment_method': paymentMethod,
		};

		if (distanceKm != null) {
			payload['distance_km'] = distanceKm;
		}
		if (estimatedTimeMins != null) {
			payload['estimated_time_mins'] = estimatedTimeMins;
		}
		if (itemCount != null) {
			payload['item_count'] = itemCount;
		}
		if (parcelType != null) {
			payload['parcel_type'] = parcelType;
		}
		if (weightKg != null) {
			payload['weight_kg'] = weightKg;
		}

		return payload;
	}
}
