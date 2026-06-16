import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/available_medicine.dart';
import '../../services/api_url.dart';
import '../../theme/app_theme.dart';
import 'available_medicine_preview_card.dart';

class AvailableMedicineBottomSheet extends StatelessWidget {
  final AvailableMedicine medicine;

  const AvailableMedicineBottomSheet({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Header Row with Image
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (medicine.medicinePhoto != null &&
                          medicine.medicinePhoto!.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AvailableMedicinePreviewCard(
                              imageUrl: medicine.medicinePhoto!,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.divider),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: medicine.medicinePhoto != null && medicine.medicinePhoto!.isNotEmpty
                          ? Image.network(
                              "${ApiUrl.baseUrl}/${medicine.medicinePhoto}",
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Iconsax.health,
                                color: AppColors.primary,
                                size: 40,
                              ),
                            )
                          : const Icon(
                              Iconsax.health,
                              color: AppColors.primary,
                              size: 40,
                            ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicine.medicineName,
                          style: AppTextStyles.header.copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            medicine.medicineCategory,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              '₹${(medicine.finalSellingPrice ?? medicine.mrp).toStringAsFixed(2)}',
                              style: AppTextStyles.header.copyWith(
                                color: AppColors.primary,
                                fontSize: 24,
                              ),
                            ),
                            if (medicine.discountPercent != null &&
                                medicine.discountPercent! > 0) ...[
                              const SizedBox(width: 8),
                              Text(
                                '₹${medicine.mrp.toStringAsFixed(2)}',
                                style: AppTextStyles.caption.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withAlpha(20),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${medicine.discountPercent}% OFF',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 16),

              // Details
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        Iconsax.box,
                        'Quantity',
                        medicine.medicineQuantity,
                      ),
                      if (medicine.prescriptionRequired != null)
                        _buildDetailRow(
                          Iconsax.document_text,
                          'Prescription Required',
                          medicine.prescriptionRequired! ? 'Yes' : 'No',
                        ),
                      if (medicine.medicineComposition != null &&
                          medicine.medicineComposition!.isNotEmpty)
                        _buildDetailRow(
                          Iconsax.health,
                          'Composition',
                          medicine.medicineComposition!,
                        ),
                      if (medicine.medicineDescription != null &&
                          medicine.medicineDescription!.isNotEmpty)
                        _buildDetailRow(
                          Iconsax.note_text,
                          'Description',
                          medicine.medicineDescription!,
                        ),
                      if (medicine.precautions != null &&
                          medicine.precautions!.isNotEmpty)
                        _buildPrecautions(medicine.precautions!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textTertiary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.description.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrecautions(List<String> precautions) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Iconsax.warning_2, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Precautions',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 8),
                ...precautions.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        Expanded(
                          child: Text(
                            p,
                            style: AppTextStyles.description.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
