import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../providers/order_provider.dart';
import '../../cards/order/order_card.dart';
import '../../cards/order/order_bottomsheet.dart';
import '../../theme/app_theme.dart';
import '../../widgets/side_nav_bar.dart';
import '../../widgets/app_bar.dart';
import 'package:go_router/go_router.dart';

class OrderManagementScreen extends ConsumerStatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  ConsumerState<OrderManagementScreen> createState() =>
      _OrderManagementScreenState();
}

class _OrderManagementScreenState
    extends ConsumerState<OrderManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderProvider.notifier).ensureConnectedAndFetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeOrders = ref.watch(orderProvider).activeOrders;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/dashboard');
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Order Management',
        subtitle: 'Manage incoming and active orders',
        showDrawer: true,
      ),
      drawer: SideNavBar(selectedIndex: 3, onItemSelected: (_) {}),
      body: activeOrders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.receipt_item,
                    size: 64,
                    color: AppColors.textSecondary.withAlpha(100),
                  ),
                  const SizedBox(height: 16),
                  const Text('No active orders', style: AppTextStyles.header),
                  const Text(
                    'Toggle online mode to receive orders',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activeOrders.length,
              itemBuilder: (context, index) {
                final order = activeOrders[index];
                return OrderCard(
                  order: order,
                  onTap: () {
                    OrderBottomSheet.show(context, order);
                  },
                );
              },
            ),
    ));
  }
}
