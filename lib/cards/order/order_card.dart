import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/order.dart';
import '../../theme/app_theme.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppCardStyles.sleekCard,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        order.type == 'prescription'
                            ? Iconsax.document_text
                            : Iconsax.shopping_bag,
                        color: AppColors.primaryAccent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.id,
                            style: AppTextStyles.cardTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Iconsax.box,
                                size: 14,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${order.items.length} item(s)',
                                style: AppTextStyles.caption,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '•',
                                style: TextStyle(color: AppColors.textTertiary),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                order.type.toUpperCase(),
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primaryAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: AppColors.divider, height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.infoLight,
                            child: Text(
                              order.customer.name.isNotEmpty
                                  ? order.customer.name
                                        .substring(0, 1)
                                        .toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: AppColors.info,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Customer',
                                  style: AppTextStyles.caption,
                                ),
                                Text(
                                  order.customer.name,
                                  style: AppTextStyles.description.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Net Earnings',
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${order.pharmacyEarnings.toStringAsFixed(2)}',
                          style: AppTextStyles.cardTitle.copyWith(
                            color: AppColors.success,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String label;

    switch (order.status) {
      case 'accepted':
        bgColor = AppColors.infoLight;
        textColor = AppColors.info;
        label = 'Accepted';
        break;
      case 'packing':
        bgColor = AppColors.warningLight;
        textColor = AppColors.warning;
        label = 'Packing';
        break;
      case 'ready_for_delivery':
        bgColor = AppColors.warningLight;
        textColor = AppColors.warning;
        label = 'Ready';
        break;
      case 'out_for_delivery':
        bgColor = AppColors.successLight;
        textColor = AppColors.success;
        label = 'Dispatched';
        break;
      case 'delivered':
        bgColor = AppColors.successLight;
        textColor = AppColors.success;
        label = 'Delivered';
        break;
      default:
        bgColor = AppColors.divider;
        textColor = AppColors.textSecondary;
        label = order.status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
