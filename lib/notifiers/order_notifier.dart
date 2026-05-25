import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/order.dart';
import '../services/order_services.dart';

class OrderState {
  final bool isOnline;
  final List<Order> incomingOrders;
  final List<Order> activeOrders;

  OrderState({
    this.isOnline = false,
    this.incomingOrders = const [],
    this.activeOrders = const [],
  });

  OrderState copyWith({
    bool? isOnline,
    List<Order>? incomingOrders,
    List<Order>? activeOrders,
  }) {
    return OrderState(
      isOnline: isOnline ?? this.isOnline,
      incomingOrders: incomingOrders ?? this.incomingOrders,
      activeOrders: activeOrders ?? this.activeOrders,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final OrderService _orderService;
  final String? _shopId;
  StreamSubscription? _subscription;

  OrderNotifier(this._orderService, this._shopId) : super(OrderState()) {
    _subscription = _orderService.messageStream.listen(_onMessage);
  }

  void _onMessage(Map<String, dynamic> data) {
    final type = data['type'];

    if (type == 'new_order_broadcast') {
      try {
        final order = Order.fromJson(data['order']);
        final newIncoming = List<Order>.from(state.incomingOrders)..add(order);
        state = state.copyWith(incomingOrders: newIncoming);
      } catch (e) {
        if (kDebugMode) {
          if (kDebugMode) {
            print("Failed to parse incoming order: \$e");
          }
        }
      }
    } else if (type == 'order_accepted' ||
        type == 'order_updated' ||
        type == 'order_status_updated' ||
        type == 'order_status_update') {
      try {
        final order = Order.fromJson(data['order']);
        _updateActiveOrder(order);
      } catch (e) {
        if (kDebugMode) {
          print("Failed to parse updated order: \$e");
        }
      }
    } else if (type == 'orders_list') {
      try {
        final ordersData = data['data'] as List;
        final orders = ordersData.map((e) => Order.fromJson(e)).toList();
        state = state.copyWith(activeOrders: orders);
      } catch (e) {
        if (kDebugMode) {
          print("Failed to parse orders list: \$e");
        }
      }
    } else if (type == 'pending_broadcast_orders' || type == 'broadcast_orders_list') {
      try {
        final ordersData = data['data'] as List;
        final orders = ordersData.map((e) => Order.fromJson(e)).toList();
        state = state.copyWith(incomingOrders: orders);
      } catch (e, stacktrace) {
        if (kDebugMode) {
          print("Failed to parse broadcast orders list: $e");
          print("Stacktrace: $stacktrace");
          print("Raw Data: ${data['data']}");
        }
      }
    }
  }

  void _updateActiveOrder(Order updatedOrder) {
    final newActive = state.activeOrders.map((o) {
      return o.id == updatedOrder.id ? updatedOrder : o;
    }).toList();

    if (!newActive.any((o) => o.id == updatedOrder.id)) {
      newActive.insert(0, updatedOrder);
    }

    final newIncoming = state.incomingOrders
        .where((o) => o.id != updatedOrder.id)
        .toList();

    state = state.copyWith(
      activeOrders: newActive,
      incomingOrders: newIncoming,
    );
  }

  void setOnlineStatus(bool isOnline) {
    state = state.copyWith(isOnline: isOnline);
    if (isOnline) {
      if (_shopId != null) {
        _orderService.connect(_shopId);
        _orderService.getShopOrders(1);
      }
    } else {
      _orderService.disconnect();
      state = state.copyWith(incomingOrders: []);
    }
  }

  void acceptOrder(String orderId) {
    _orderService.acceptOrder(orderId);
  }

  void rejectOrder(String orderId) {
    final newIncoming = state.incomingOrders
        .where((o) => o.id != orderId)
        .toList();
    state = state.copyWith(incomingOrders: newIncoming);
  }

  void markReadyForDelivery(String orderId, {required String riderName, required String riderPhone}) {
    _orderService.updatePacking(
      orderId,
      riderName: riderName,
      riderPhone: riderPhone,
    );
  }

  void informCustomer(String orderId) {
    _orderService.updateStatus(orderId, 'out_for_delivery');
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _orderService.disconnect();
    super.dispose();
  }
}
