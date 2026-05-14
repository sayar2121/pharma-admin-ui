import 'available_medicine.dart';

class MedicineInventory {
  final String? inventoryMedicineId;
  final String shopId;
  final String medicineId;
  final double discountPercent;
  final double? finalPrice;
  final String status; // 'in stock' or 'out of stock'
  final AvailableMedicine? medicine; // Nested core medicine details

  MedicineInventory({
    this.inventoryMedicineId,
    required this.shopId,
    required this.medicineId,
    required this.discountPercent,
    this.finalPrice,
    required this.status,
    this.medicine,
  });

  double get displayPrice {
    if (finalPrice != null && finalPrice! > 0) return finalPrice!;
    if (medicine == null) return 0.0;
    return medicine!.mrp - (medicine!.mrp * discountPercent / 100);
  }

  factory MedicineInventory.fromJson(Map<String, dynamic> json) {
    return MedicineInventory(
      inventoryMedicineId: json['inventory_medicine_id']?.toString(),
      shopId: json['shop_id']?.toString() ?? '',
      medicineId: json['medicine_id']?.toString() ?? '',
      discountPercent: (json['discount_percent'] ?? 0.0).toDouble(),
      finalPrice: (json['final_price'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'in stock',
      medicine: json['medicine_details'] != null 
          ? AvailableMedicine.fromJson(json['medicine_details']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (inventoryMedicineId != null) 'inventory_medicine_id': inventoryMedicineId,
      'shop_id': shopId,
      'medicine_id': medicineId,
      'discount_percent': discountPercent,
      'status': status,
    };
  }
}
