import 'dart:convert';

class AvailableMedicine {
  final String? medicineId;
  final String medicineName;
  final String medicineCategory;
  final String? medicinePhoto;
  final String medicineQuantity;
  final String? medicineDescription;
  final String? medicineComposition;
  final List<String>? precautions;
  final double mrp;
  final double? discountPercent;
  final double? finalSellingPrice;
  final bool? prescriptionRequired;
  final String? createdAt;
  final String? updatedAt;

  AvailableMedicine({
    this.medicineId,
    required this.medicineName,
    required this.medicineCategory,
    this.medicinePhoto,
    required this.medicineQuantity,
    this.medicineDescription,
    this.medicineComposition,
    this.precautions,
    required this.mrp,
    this.discountPercent,
    this.finalSellingPrice,
    this.prescriptionRequired,
    this.createdAt,
    this.updatedAt,
  });

  factory AvailableMedicine.fromJson(Map<String, dynamic> json) {
    return AvailableMedicine(
      medicineId: (json['medicine_id'] ?? json['id'])?.toString(),
      medicineName: json['medicine_name'] ?? '',
      medicineCategory: json['medicine_category'] ?? '',
      medicinePhoto: json['medicine_photo'],
      medicineQuantity: json['medicine_quantity']?.toString() ?? '',
      medicineDescription: json['medicine_description'],
      medicineComposition: json['medicine_composition'],
      precautions: _parsePrecautions(json['precautions']),
      mrp: json['mrp'] != null ? (double.tryParse(json['mrp'].toString()) ?? 0.0) : 0.0,
      discountPercent: json['discount_percent'] != null ? double.tryParse(json['discount_percent'].toString()) : null,
      finalSellingPrice: json['final_selling_price'] != null ? double.tryParse(json['final_selling_price'].toString()) : null,
      prescriptionRequired: json['prescription_required'] != null 
          ? (json['prescription_required'] is bool 
              ? json['prescription_required'] 
              : json['prescription_required'].toString().toLowerCase() == 'true')
          : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (medicineId != null) 'medicine_id': medicineId,
      'medicine_name': medicineName,
      'medicine_category': medicineCategory,
      'medicine_photo': medicinePhoto,
      'medicine_quantity': medicineQuantity,
      'medicine_description': medicineDescription,
      'medicine_composition': medicineComposition,
      'precautions': precautions,
      'mrp': mrp,
      'discount_percent': discountPercent,
      'final_selling_price': finalSellingPrice,
      'prescription_required': prescriptionRequired,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static List<String>? _parsePrecautions(dynamic data) {
    if (data == null) return null;
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    if (data is String) {
      if (data.isEmpty) return null;
      try {
        final decoded = jsonDecode(data);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {
        // Not a valid JSON array, maybe a comma separated string?
        return data.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
    }
    // If it's a Map or some other unexpected format, just try converting the whole thing to string or ignore
    return null; 
  }
}
