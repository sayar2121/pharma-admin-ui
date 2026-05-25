import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/order_provider.dart';
import 'order_popup.dart';
import '../routes/app_router.dart';

class GlobalOrderOverlay extends ConsumerWidget {
  final Widget child;

  const GlobalOrderOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(orderProvider);
    
    // Check if we have incoming orders
    final hasIncomingOrder = orderState.incomingOrders.isNotEmpty;
    
    // Determine if we should show the popup based on current route
    bool shouldShowPopup = false;
    
    if (hasIncomingOrder) {
      final currentConfig = appRouter.routerDelegate.currentConfiguration;
      final currentUri = currentConfig.uri.toString();
      
      // Suppress on auth screens
      if (currentUri != '/' && currentUri != '/login' && currentUri != '/signup') {
        shouldShowPopup = true;
      }
    }

    return Stack(
      children: [
        child,
        if (shouldShowPopup)
          Positioned.fill(
            child: Container(
              color: Colors.black.withAlpha(150),
              child: SafeArea(
                child: OrderPopup(
                  order: orderState.incomingOrders.first,
                  onAccept: () {
                    ref.read(orderProvider.notifier).acceptOrder(orderState.incomingOrders.first.id);
                  },
                  onReject: () {
                    ref.read(orderProvider.notifier).rejectOrder(orderState.incomingOrders.first.id);
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
