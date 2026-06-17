import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import '../../services/api_url.dart';
import '../../routes/app_router.dart';
import '../../screens/order/components/generate_quote_dialog.dart';
import 'assign_rider_bottomsheet.dart';

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
    final orderState = ref.watch(orderProvider);
    final currentOrder = orderState.activeOrders.firstWhere(
      (o) => o.id == order.id,
      orElse: () => order,
    );

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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Iconsax.receipt_square,
                          color: AppColors.primaryAccent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Details',
                              style: AppTextStyles.cardTitle.copyWith(
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'ID: ${currentOrder.id}',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(currentOrder.status),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(color: AppColors.divider, height: 1),
                  ),

                  if (currentOrder.type == 'prescription' &&
                      currentOrder.prescriptionImage != null &&
                      currentOrder.prescriptionImage!.isNotEmpty) ...[
                    Builder(
                      builder: (context) {
                        final imageUrl =
                            currentOrder.prescriptionImage!.startsWith('http')
                            ? currentOrder.prescriptionImage!
                            : '${ApiUrl.baseUrl}/${currentOrder.prescriptionImage!.startsWith('/') ? currentOrder.prescriptionImage!.substring(1) : currentOrder.prescriptionImage!}';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(
                              Iconsax.document_text,
                              'Prescription',
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                appRouter.push(
                                  '/prescription-preview',
                                  extra: imageUrl,
                                );
                              },
                              child: Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.divider),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topCenter,
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Divider(
                                color: AppColors.divider,
                                height: 1,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],

                  // Customer Details
                  _buildSectionTitle(
                    Iconsax.profile_circle,
                    'Customer Information',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Iconsax.user,
                    currentOrder.customer.name,
                    isBold: true,
                  ),
                  _buildInfoRow(Iconsax.call, currentOrder.customer.phone),
                  if (currentOrder.customer.address != null)
                    _buildInfoRow(
                      Iconsax.location,
                      currentOrder.customer.address!,
                    ),

                  if (currentOrder.rider != null) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Divider(color: AppColors.divider, height: 1),
                    ),
                    _buildSectionTitle(Iconsax.driver, 'Delivery Rider'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withAlpha(30)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            Iconsax.user,
                            currentOrder.rider!.name,
                            isBold: true,
                          ),
                          _buildInfoRow(Iconsax.call, currentOrder.rider!.phone),
                          if (currentOrder.rider!.vehicleNumber != null)
                            _buildInfoRow(Iconsax.car, currentOrder.rider!.vehicleNumber!),
                          if (currentOrder.pickupOtp != null) ...[
                            const SizedBox(height: 12),
                            const Divider(color: AppColors.divider),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Pickup OTP',
                                  style: AppTextStyles.description.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    currentOrder.pickupOtp!,
                                    style: AppTextStyles.cardTitle.copyWith(
                                      color: Colors.white,
                                      letterSpacing: 4,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Share this OTP with the rider when handing over the package.',
                              style: AppTextStyles.caption.copyWith(color: AppColors.primaryAccent),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],



                  // Medicines
                  _buildSectionTitle(Iconsax.box, 'Medicines'),
                  const SizedBox(height: 16),
                  ...currentOrder.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.name,
                              style: AppTextStyles.description,
                            ),
                          ),
                          Text(
                            '₹${item.totalPrice.toStringAsFixed(2)}',
                            style: AppTextStyles.description.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(color: AppColors.divider, height: 1),
                  ),

                  // Pricing
                  _buildSectionTitle(Iconsax.wallet_3, 'Earnings Breakdown'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.successLight.withAlpha(100),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.successLight),
                    ),
                    child: Column(
                      children: [
                        _buildPriceRow(
                          'Total Order Value',
                          currentOrder.totalAmount,
                        ),
                        const SizedBox(height: 8),
                        _buildPriceRow(
                          'Platform Charges',
                          -currentOrder.platformCharges,
                          isDeduction: true,
                        ),
                        const SizedBox(height: 8),
                        _buildPriceRow(
                          'Taxes',
                          -currentOrder.taxes,
                          isDeduction: true,
                        ),
                        const SizedBox(height: 8),
                        _buildPriceRow(
                          'Delivery Fee',
                          -currentOrder.deliveryFee,
                          isDeduction: true,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: AppColors.success, height: 1),
                        ),
                        _buildPriceRow(
                          'Net Earnings',
                          currentOrder.pharmacyEarnings,
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons
          if (currentOrder.status == 'accepted' ||
              currentOrder.status == 'awaiting_customer_approval' ||
              currentOrder.status == 'packing' ||
              currentOrder.status == 'out_for_delivery')
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Builder(
                builder: (context) {
                  orderState.fetchingRidersFor.contains(currentOrder.id);

                  if (currentOrder.status == 'awaiting_customer_approval') {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.divider,
                          foregroundColor: AppColors.textSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Waiting for Customer Approval',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  } else if (currentOrder.status == 'accepted' || currentOrder.status == 'packing') {
                    if (currentOrder.status == 'accepted' && currentOrder.type == 'prescription' && (currentOrder.items.isEmpty || currentOrder.totalAmount == 0)) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                             showDialog(
                               context: context,
                               builder: (context) => GenerateQuoteDialog(
                                 order: currentOrder,
                                 onSubmit: (items, itemTotal) {
                                   ref.read(orderProvider.notifier).submitPrescriptionQuote(
                                     currentOrder.id,
                                     items,
                                     itemTotal,
                                   );
                                 },
                               ),
                             );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Generate Bill for Customer',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                             Navigator.pop(context);
                             AssignRiderBottomSheet.show(context, currentOrder);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Mark Ready for Delivery',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }
                  } else {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ref
                              .read(orderProvider.notifier)
                              .informCustomer(currentOrder.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Inform Customer & Request Rider',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.textPrimary),
        const SizedBox(width: 12),
        Text(title, style: AppTextStyles.cardTitle.copyWith(fontSize: 16)),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textTertiary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.description.copyWith(
                color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isTotal = false,
    bool isDeduction = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          '${isDeduction ? "-" : ""}₹${amount.abs().toStringAsFixed(2)}',
          style: AppTextStyles.caption.copyWith(
            color: isDeduction
                ? AppColors.error
                : (isTotal ? AppColors.success : AppColors.textPrimary),
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor = AppColors.infoLight;
    Color textColor = AppColors.info;

    if (status == 'packing' || status == 'ready_for_delivery') {
      bgColor = AppColors.warningLight;
      textColor = AppColors.warning;
    } else if (status == 'awaiting_customer_approval') {
      bgColor = AppColors.purple.withAlpha(20);
      textColor = AppColors.purple;
    } else if (status == 'out_for_delivery' || status == 'delivered') {
      bgColor = AppColors.successLight;
      textColor = AppColors.success;
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
}
