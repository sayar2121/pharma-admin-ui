import 'dart:ui';
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
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, value, animChild) {
                return Stack(
                  children: [
                    // Glassmorphism blur effect
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8 * value, sigmaY: 8 * value),
                      child: Container(
                        color: Colors.black.withAlpha((120 * value).toInt()),
                      ),
                    ),
                    // Popup with scaling animation
                    Transform.scale(
                      scale: 0.95 + (0.05 * value),
                      child: Opacity(
                        opacity: value,
                        child: animChild,
                      ),
                    ),
                  ],
                );
              },
              child: SafeArea(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  itemCount: orderState.incomingOrders.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 40),
                  itemBuilder: (context, index) {
                    final order = orderState.incomingOrders[index];
                    return OrderPopup(
                      order: order,
                      onAccept: () {
                        ref.read(orderProvider.notifier).acceptOrder(order.id);
                      },
                      onReject: () {
                        ref.read(orderProvider.notifier).rejectOrder(order.id);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
