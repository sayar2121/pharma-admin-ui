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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.divider.withAlpha(80), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        order.type == 'prescription'
                            ? Iconsax.document
                            : Iconsax.shopping_cart,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order ${order.id}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${order.items.length} item(s) • ${order.type.toUpperCase()}',
                            style: AppTextStyles.caption,
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
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Customer', style: AppTextStyles.caption),
                          const SizedBox(height: 4),
                          Text(
                            order.customer.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                        const SizedBox(height: 4),
                        Text(
                          '₹${order.pharmacyEarnings.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
        bgColor = Colors.blue.withAlpha(30);
        textColor = Colors.blue;
        label = 'Accepted';
        break;
      case 'packing':
        bgColor = Colors.orange.withAlpha(30);
        textColor = Colors.orange;
        label = 'Packing';
        break;
      case 'ready_for_delivery':
        bgColor = Colors.orange.withAlpha(30);
        textColor = Colors.orange;
        label = 'Ready';
        break;
      case 'out_for_delivery':
        bgColor = Colors.green.withAlpha(30);
        textColor = Colors.green;
        label = 'Dispatched';
        break;
      case 'delivered':
        bgColor = Colors.green.withAlpha(30);
        textColor = Colors.green;
        label = 'Delivered';
        break;
      default:
        bgColor = AppColors.divider;
        textColor = AppColors.textSecondary;
        label = order.status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
