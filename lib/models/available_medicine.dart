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
  });

  factory AvailableMedicine.fromJson(Map<String, dynamic> json) {
    return AvailableMedicine(
      medicineId: (json['medicine_id'] ?? json['id'])?.toString(),
      medicineName: json['medicine_name'] ?? '',
      medicineCategory: json['medicine_category'] ?? '',
      medicinePhoto: json['medicine_photo'],
      medicineQuantity: json['medicine_quantity'] ?? '',
      medicineDescription: json['medicine_description'],
      medicineComposition: json['medicine_composition'],
      precautions: json['precautions'] != null 
          ? List<String>.from(json['precautions'].map((x) => x.toString())) 
          : null,
      mrp: (json['mrp'] ?? 0.0).toDouble(),
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
    };
  }
}
