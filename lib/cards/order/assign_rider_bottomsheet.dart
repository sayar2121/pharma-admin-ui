import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/searching_rider_widget.dart';

class AssignRiderBottomSheet extends ConsumerStatefulWidget {
  final Order order;

  const AssignRiderBottomSheet({super.key, required this.order});

  static void show(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => AssignRiderBottomSheet(order: order),
    );
  }

  @override
  ConsumerState<AssignRiderBottomSheet> createState() => _AssignRiderBottomSheetState();
}

class _AssignRiderBottomSheetState extends ConsumerState<AssignRiderBottomSheet> {
  bool _hasRequested = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasRequested) {
        _hasRequested = true;
        final isFetching = ref.read(orderProvider).fetchingRidersFor.contains(widget.order.id);
        final rider = widget.order.rider;
        if (!isFetching && rider == null) {
          ref.read(orderProvider.notifier).requestRiderForOrder(widget.order);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final currentOrder = orderState.activeOrders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => widget.order,
    );

    final isFetching = orderState.fetchingRidersFor.contains(currentOrder.id) || orderState.isRequestingRider;
    final rider = currentOrder.rider;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
                children: [
                  if (isFetching) ...[
                    const SizedBox(height: 60),
                    const SearchingRiderWidget(),
                    const SizedBox(height: 40),
                    Text(
                      'Connecting to Caby24...',
                      style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please do not close this window while we find a delivery partner.',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                      textAlign: TextAlign.center,
                    ),
                  ] else if (rider != null) ...[
                    const Icon(
                      Iconsax.verify5,
                      color: AppColors.success,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Rider Assigned!',
                      style: AppTextStyles.header.copyWith(color: AppColors.success),
                    ),
                    const SizedBox(height: 32),
                    
                    // Rider Details Card
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
                          _buildInfoRow(Iconsax.user, rider.name, isBold: true),
                          _buildInfoRow(Iconsax.call, rider.phone),
                          if (rider.vehicleNumber != null)
                            _buildInfoRow(Iconsax.car, rider.vehicleNumber!),
                          
                          if (currentOrder.pickupOtp != null) ...[
                            const SizedBox(height: 16),
                            const Divider(color: AppColors.divider),
                            const SizedBox(height: 16),
                            Text(
                              'Pickup OTP',
                              style: AppTextStyles.description.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  currentOrder.pickupOtp!,
                                  style: AppTextStyles.header.copyWith(
                                    color: Colors.white,
                                    letterSpacing: 8,
                                    fontSize: 32,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Share this OTP with the rider when handing over the package.',
                              style: AppTextStyles.caption.copyWith(color: AppColors.primaryAccent),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // close assign sheet
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
                          'Done',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ] else ...[
                     const Icon(
                      Iconsax.warning_2,
                      color: AppColors.error,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to assign rider.',
                      style: AppTextStyles.header.copyWith(color: AppColors.error),
                    ),
                    if (orderState.requestError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        orderState.requestError!,
                        style: AppTextStyles.caption.copyWith(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // close assign sheet
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textSecondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
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
}
