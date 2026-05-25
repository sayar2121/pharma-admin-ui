import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../notifiers/order_notifier.dart';
import '../services/order_services.dart';
import 'auth_provider.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  final service = OrderService();
  ref.onDispose(() => service.disconnect());
  return service;
});

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  final authState = ref.watch(authProvider);
  return OrderNotifier(orderService, authState.user?.shopId);
});
