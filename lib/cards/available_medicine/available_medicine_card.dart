import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/available_medicine.dart';
import '../../services/api_url.dart';
import '../../theme/app_theme.dart';

class AvailableMedicineCard extends StatelessWidget {
  final AvailableMedicine medicine;
  final VoidCallback onTap;

  const AvailableMedicineCard({
    super.key,
    required this.medicine,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: AppCardStyles.sleekCard,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medicine Photo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: medicine.medicinePhoto != null && medicine.medicinePhoto!.isNotEmpty
                  ? Image.network(
                      "${ApiUrl.baseUrl}/${medicine.medicinePhoto}",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Iconsax.health,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    )
                  : const Icon(Iconsax.health, color: AppColors.primary, size: 32),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          medicine.medicineName,
                          style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          medicine.medicineCategory,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    medicine.medicineComposition ?? 'Composition not specified',
                    style: AppTextStyles.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        medicine.medicineQuantity,
                        style: AppTextStyles.description.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '₹${medicine.mrp.toStringAsFixed(2)}',
                        style: AppTextStyles.header.copyWith(
                          color: AppColors.primary,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
