import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';

class OrderBottomSheet extends ConsumerWidget {
  final Order order;

  const OrderBottomSheet({super.key, required this.order});

  static void show(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderBottomSheet(order: order),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch order state so bottomsheet updates if order status changes while open
    final currentOrder = ref
        .watch(orderProvider)
        .activeOrders
        .firstWhere((o) => o.id == order.id, orElse: () => order);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Order ${currentOrder.id}',
                          style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildStatusBadge(currentOrder.status),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Customer Details
                  _buildSectionTitle('Customer Information'),
                  _buildInfoRow(Iconsax.user, currentOrder.customer.name),
                  _buildInfoRow(Iconsax.call, currentOrder.customer.phone),
                  if (currentOrder.customer.address != null)
                    _buildInfoRow(
                      Iconsax.location,
                      currentOrder.customer.address!,
                    ),

                  const Divider(height: 32),

                  // Rider Details
                  if (currentOrder.rider != null) ...[
                    _buildSectionTitle('Delivery Rider'),
                    _buildInfoRow(Iconsax.driver, currentOrder.rider!.name),
                    _buildInfoRow(Iconsax.call, currentOrder.rider!.phone),
                    const Divider(height: 32),
                  ],

                  // Medicines
                  _buildSectionTitle('Medicines'),
                  ...currentOrder.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            '${item.quantity}x',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(item.name)),
                          Text('₹${item.totalPrice.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 32),

                  // Pricing
                  _buildSectionTitle('Earnings Breakdown'),
                  _buildPriceRow('Total Order Value', currentOrder.totalAmount),
                  _buildPriceRow(
                    'Platform Charges',
                    -currentOrder.platformCharges,
                  ),
                  _buildPriceRow('Taxes', -currentOrder.taxes),
                  _buildPriceRow('Delivery Fee', -currentOrder.deliveryFee),
                  const Divider(),
                  _buildPriceRow(
                    'Net Earnings',
                    currentOrder.pharmacyEarnings,
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                if (currentOrder.status == 'accepted')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showRiderInfoDialog(context, ref, currentOrder.id);
                      },
                      child: const Text('Mark Ready for Delivery'),
                    ),
                  ),
                if (currentOrder.status == 'ready_for_delivery')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ref
                            .read(orderProvider.notifier)
                            .informCustomer(currentOrder.id);
                      },
                      child: const Text('Inform Customer & Request Rider'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? AppColors.primary : AppColors.textPrimary,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            '${amount < 0 ? "-" : ""}₹${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color: amount < 0
                  ? AppColors.error
                  : (isTotal ? AppColors.primary : AppColors.textPrimary),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor = AppColors.primary.withAlpha(20);
    Color textColor = AppColors.primary;

    if (status == 'packing' || status == 'ready_for_delivery') {
      bgColor = Colors.orange.withAlpha(20);
      textColor = Colors.orange;
    } else if (status == 'out_for_delivery' || status == 'delivered') {
      bgColor = Colors.green.withAlpha(20);
      textColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase().replaceAll('_', ' '),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  void _showRiderInfoDialog(
    BuildContext context,
    WidgetRef ref,
    String orderId,
  ) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rider Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Rider Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Rider Phone'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty) {
                  ref
                      .read(orderProvider.notifier)
                      .markReadyForDelivery(
                        orderId,
                        riderName: nameController.text,
                        riderPhone: phoneController.text,
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
