import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/order_provider.dart';
import 'order_popup.dart';
import 'bill_generation_dialog.dart';
import '../models/order.dart';
import '../routes/app_router.dart';

class GlobalOrderOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const GlobalOrderOverlay({super.key, required this.child});

  @override
  ConsumerState<GlobalOrderOverlay> createState() => _GlobalOrderOverlayState();
}

class _GlobalOrderOverlayState extends ConsumerState<GlobalOrderOverlay> {
  String? _previewImageUrl;
  bool _isPreviewBase64 = false;
  Order? _billGenerationOrder;

  @override
  Widget build(BuildContext context) {
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
        widget.child,
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
                      onAccept: (items, itemTotal) {
                        if (order.type == 'prescription') {
                          setState(() {
                            _billGenerationOrder = order;
                          });
                        } else {
                          ref.read(orderProvider.notifier).acceptOrder(
                            order.id,
                            items: items,
                            itemTotal: itemTotal,
                          );
                        }
                      },
                      onReject: () {
                        ref.read(orderProvider.notifier).rejectOrder(order.id);
                      },
                      onPreviewImage: (url, isBase64) {
                        setState(() {
                          _previewImageUrl = url;
                          _isPreviewBase64 = isBase64;
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          
        if (_previewImageUrl != null)
          Positioned.fill(
            child: Material(
              color: Colors.black87,
              child: Stack(
                children: [
                  Center(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: _isPreviewBase64
                          ? Image.memory(
                              base64Decode(_previewImageUrl!.split(',').last),
                              fit: BoxFit.contain,
                            )
                          : Image.network(
                              _previewImageUrl!,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 20,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _previewImageUrl = null;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
        if (_billGenerationOrder != null)
          Positioned.fill(
            child: Material(
              color: Colors.black54,
              child: BillGenerationDialog(
                onSubmit: (items, itemTotal) {
                  ref.read(orderProvider.notifier).acceptOrder(
                    _billGenerationOrder!.id,
                    items: items,
                    itemTotal: itemTotal,
                  );
                  setState(() {
                    _billGenerationOrder = null;
                  });
                },
                onCancel: () {
                  setState(() {
                    _billGenerationOrder = null;
                  });
                },
              ),
            ),
          ),
      ],
    );
  }
}
