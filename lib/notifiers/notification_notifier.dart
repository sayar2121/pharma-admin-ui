import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import '../services/order_services.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;

  NotificationState({
    this.notifications = const [],
    this.isLoading = false,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final OrderService _orderService;
  StreamSubscription? _wsSubscription;

  NotificationNotifier(this._orderService) : super(NotificationState()) {
    _loadNotifications();
    _listenToWebSockets();
  }

  void _listenToWebSockets() {
    _wsSubscription = _orderService.messageStream.listen((message) {
      final type = message['type'];
      
      if (type == 'connection') {
        _addNotification(
          title: 'System Message',
          body: message['message'] ?? 'Successfully connected to server.',
          type: 'system',
        );
      } else if (type == 'new_order_broadcast') {
        final order = message['order'];
        final isPrescription = order['order_type'] == 'prescription';
        _addNotification(
          title: 'New ${isPrescription ? 'Prescription ' : ''}Order',
          body: 'A new order has been broadcasted. Review and accept now!',
          type: 'order',
        );
      } else if (type == 'order_accepted') {
        _addNotification(
          title: 'Order Accepted',
          body: message['message'] ?? 'You have accepted the order successfully.',
          type: 'order',
        );
      }
    });
  }

  Future<void> _loadNotifications() async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList('notifications') ?? [];
      
      final loadedNotifications = notificationsJson
          .map((jsonStr) => NotificationModel.fromJson(jsonStr))
          .toList();
          
      // Sort newest first
      loadedNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
      state = state.copyWith(
        notifications: loadedNotifications,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _saveNotifications(List<NotificationModel> notifications) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = notifications.map((n) => n.toJson()).toList();
      await prefs.setStringList('notifications', notificationsJson);
    } catch (e) {
      // Ignore save errors
    }
  }

  void _addNotification({
    required String title,
    required String body,
    required String type,
  }) {
    final newNotification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      createdAt: DateTime.now(),
    );

    final updatedNotifications = [newNotification, ...state.notifications];
    
    // Keep only last 100 notifications to save space
    if (updatedNotifications.length > 100) {
      updatedNotifications.removeLast();
    }

    state = state.copyWith(notifications: updatedNotifications);
    _saveNotifications(updatedNotifications);
  }

  void markAsRead(String id) {
    final updatedNotifications = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    state = state.copyWith(notifications: updatedNotifications);
    _saveNotifications(updatedNotifications);
  }

  void markAllAsRead() {
    final updatedNotifications = state.notifications.map((n) {
      return n.copyWith(isRead: true);
    }).toList();

    state = state.copyWith(notifications: updatedNotifications);
    _saveNotifications(updatedNotifications);
  }

  void clearAll() {
    state = state.copyWith(notifications: []);
    _saveNotifications([]);
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    super.dispose();
  }
}
