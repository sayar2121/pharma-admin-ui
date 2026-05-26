import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/order.dart';
import '../../theme/app_theme.dart';

class OrderPopup extends StatelessWidget {
  final Order order;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const OrderPopup({
    super.key,
    required this.order,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: AppCardStyles.sleekCard.copyWith(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Premium Compact Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: const BoxDecoration(
                    color: AppColors.darkCyan,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Iconsax.receipt_square,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'New Order',
                              style: AppTextStyles.cardTitle.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'ID: ${order.id}',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(100),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '₹${order.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customer Details (Compact Profile Row)
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.infoLight,
                              child: Text(
                                order.customer.name.isNotEmpty 
                                  ? order.customer.name.substring(0, 1).toUpperCase() 
                                  : '?',
                                style: const TextStyle(
                                  color: AppColors.info,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.customer.name,
                                    style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                                  ),
                                  Text(
                                    order.customer.phone,
                                    style: AppTextStyles.caption,
                                  ),
                                  if (order.customer.address != null) ...[
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(
                                          Iconsax.location,
                                          size: 12,
                                          color: AppColors.textTertiary,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            order.customer.address!,
                                            style: AppTextStyles.caption,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: AppColors.divider, height: 1),
                        ),

                        // Requested Items
                        Row(
                          children: [
                            const Icon(Iconsax.box, size: 16, color: AppColors.purple),
                            const SizedBox(width: 8),
                            Text(
                              'Requested Items',
                              style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...order.items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.purple.withAlpha(20),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${item.quantity}x',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.purple,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: AppTextStyles.description.copyWith(fontSize: 14),
                                    ),
                                  ),
                                  Text(
                                    '₹${item.totalPrice.toStringAsFixed(2)}',
                                    style: AppTextStyles.description.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )),

                        // Compact Prescription Thumbnail
                        if (order.prescriptionImage != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: order.prescriptionImage!.startsWith('data:image')
                                      ? Image.memory(
                                          base64Decode(order.prescriptionImage!.split(',').last),
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder: _buildImageError,
                                        )
                                      : Image.network(
                                          order.prescriptionImage!,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder: _buildImageError,
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Prescription Attached',
                                        style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                                      ),
                                      Text(
                                        'Tap to view details',
                                        style: AppTextStyles.caption.copyWith(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryCyan.withAlpha(20),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Iconsax.document_download,
                                    size: 16,
                                    color: AppColors.secondaryCyan,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: AppColors.divider, height: 1),
                        ),

                        // Payment Breakdown
                        Row(
                          children: [
                            const Icon(Iconsax.wallet_3, size: 16, color: AppColors.success),
                            const SizedBox(width: 8),
                            Text(
                              'Payment Breakdown',
                              style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.successLight.withAlpha(100),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.successLight),
                          ),
                          child: Column(
                            children: [
                              _buildPriceRow('Total Order Value', order.totalAmount),
                              const SizedBox(height: 6),
                              _buildPriceRow('Platform Charges', -order.platformCharges, isDeduction: true),
                              const SizedBox(height: 6),
                              _buildPriceRow('Taxes', -order.taxes, isDeduction: true),
                              const SizedBox(height: 6),
                              _buildPriceRow('Delivery Fee', -order.deliveryFee, isDeduction: true),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(color: AppColors.success, height: 1),
                              ),
                              _buildPriceRow('Your Earnings', order.pharmacyEarnings, isTotal: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Actions Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.divider.withAlpha(128),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onReject,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.errorLight, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Reject',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              fontFamily: 'Lexend',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Accept',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              fontFamily: 'Lexend',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageError(BuildContext context, Object error, StackTrace? stackTrace) {
    return Container(
      width: 40,
      height: 40,
      color: AppColors.divider,
      alignment: Alignment.center,
      child: const Icon(
        Iconsax.image,
        color: AppColors.textTertiary,
        size: 20,
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isDeduction = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            fontSize: isTotal ? 14 : 12,
          ),
        ),
        Text(
          '${isDeduction ? "-" : ""}₹${amount.abs().toStringAsFixed(2)}',
          style: AppTextStyles.caption.copyWith(
            color: isDeduction
                ? AppColors.error
                : (isTotal ? AppColors.success : AppColors.textPrimary),
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            fontSize: isTotal ? 15 : 13,
          ),
        ),
      ],
    );
  }
}
