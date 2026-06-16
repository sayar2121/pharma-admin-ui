import 'package:flutter_riverpod/legacy.dart';
import '../notifiers/notification_notifier.dart';
import 'order_provider.dart';

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  return NotificationNotifier(orderService);
});
