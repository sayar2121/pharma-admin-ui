import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models/order.dart';
import '../models/request_rider_order.dart';
import '../models/user.dart';
import '../services/order_services.dart';


class OrderState {
  final bool isOnline;
  final List<Order> incomingOrders;
  final List<Order> activeOrders;
  final bool isRequestingRider;
  final String? requestError;
  final Set<String> fetchingRidersFor;
  final Set<String> ridersFetchedFor;

  OrderState({
    this.isOnline = false,
    this.incomingOrders = const [],
    this.activeOrders = const [],
    this.isRequestingRider = false,
    this.requestError,
    this.fetchingRidersFor = const {},
    this.ridersFetchedFor = const {},
  });

  OrderState copyWith({
    bool? isOnline,
    List<Order>? incomingOrders,
    List<Order>? activeOrders,
    bool? isRequestingRider,
    String? requestError,
    Set<String>? fetchingRidersFor,
    Set<String>? ridersFetchedFor,
  }) {
    return OrderState(
      isOnline: isOnline ?? this.isOnline,
      incomingOrders: incomingOrders ?? this.incomingOrders,
      activeOrders: activeOrders ?? this.activeOrders,
      isRequestingRider: isRequestingRider ?? this.isRequestingRider,
      requestError: requestError,
      fetchingRidersFor: fetchingRidersFor ?? this.fetchingRidersFor,
      ridersFetchedFor: ridersFetchedFor ?? this.ridersFetchedFor,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final OrderService _orderService;
  final String? _shopId;
  final User? _user;
  StreamSubscription? _subscription;
  final AudioPlayer _audioPlayer = AudioPlayer();

  OrderNotifier(this._orderService, this._shopId, this._user)
    : super(OrderState()) {
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _subscription = _orderService.messageStream.listen(_onMessage);
  }

  void _onMessage(Map<String, dynamic> data) {
    final type = data['type'];

    if (type == 'new_order_broadcast') {
      try {
        final order = Order.fromJson(data['order']);
        final newIncoming = List<Order>.from(state.incomingOrders)..add(order);
        state = state.copyWith(incomingOrders: newIncoming);
        
        // Play custom notification sound continuously
        _audioPlayer.play(AssetSource('audio/order_ring.mp3'));
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
        type == 'order_status_update' ||
        type == 'quote_submitted' ||
        type == 'quote_approved_by_customer') {
      try {
        final order = Order.fromJson(data['order']);
        _updateActiveOrder(order);
      } catch (e) {
        if (kDebugMode) {
          print("Failed to parse updated order: \$e");
        }
      }
    } else if (type == 'quote_rejected_by_customer') {
      try {
        final order = Order.fromJson(data['order']);
        final newActive = state.activeOrders.where((o) => o.id != order.id).toList();
        state = state.copyWith(activeOrders: newActive);
      } catch (e) {
        if (kDebugMode) {
          print("Failed to remove rejected order: \$e");
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
    } else if (type == 'pending_broadcast_orders' ||
        type == 'broadcast_orders_list') {
      try {
        final ordersData = data['data'] as List;
        final orders = ordersData.map((e) => Order.fromJson(e)).toList();
        state = state.copyWith(incomingOrders: orders);
        if (orders.isEmpty) {
          _audioPlayer.stop();
        }
      } catch (e, stacktrace) {
        if (kDebugMode) {
          print("Failed to parse broadcast orders list: $e");
          print("Stacktrace: $stacktrace");
          print("Raw Data: ${data['data']}");
        }
      }
    } else if (type == 'remove_broadcast_order') {
      final orderId = data['order_id'];
      final newIncoming = state.incomingOrders.where((o) => o.id != orderId).toList();
      state = state.copyWith(incomingOrders: newIncoming);
      if (newIncoming.isEmpty) {
        _audioPlayer.stop();
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

    Set<String> newFetched = state.ridersFetchedFor;
    Set<String> newFetching = state.fetchingRidersFor;
    
    // If the updated order has a rider (e.g. from a global WS event), stop the searching spinner
    if (updatedOrder.rider != null) {
      if (!newFetched.contains(updatedOrder.id)) {
        newFetched = Set<String>.from(state.ridersFetchedFor)..add(updatedOrder.id);
        newFetching = Set<String>.from(state.fetchingRidersFor)..remove(updatedOrder.id);
      }
    }

    state = state.copyWith(
      activeOrders: newActive,
      incomingOrders: newIncoming,
      ridersFetchedFor: newFetched,
      fetchingRidersFor: newFetching,
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

  void ensureConnectedAndFetch() {
    if (_shopId == null) return;
    if (!state.isOnline) return;

    if (!_orderService.isConnected) {
      _orderService.connect(_shopId);
    }
    _orderService.getShopOrders(1);
    _orderService.getBroadcastOrders();
  }

  void acceptOrder(String orderId, {List<Map<String, dynamic>>? items, double? itemTotal}) {
    _audioPlayer.stop();
    _orderService.acceptOrder(orderId, items: items, itemTotal: itemTotal);
  }

  void submitPrescriptionQuote(String orderId, List<Map<String, dynamic>> items, double itemTotal) {
    _orderService.submitPrescriptionQuote(orderId, items, itemTotal);
  }

  void rejectOrder(String orderId) {
    _audioPlayer.stop();
    final newIncoming = state.incomingOrders
        .where((o) => o.id != orderId)
        .toList();
    state = state.copyWith(incomingOrders: newIncoming);
  }

  Future<bool> requestRiderForOrder(Order order) async {
    final user = _user;
    if (user == null) {
      state = state.copyWith(
        isRequestingRider: false,
        requestError: 'Shop details not available',
      );
      return false;
    }

    final pickupLat = double.tryParse(user.latitude) ?? 0.0;
    final pickupLng = double.tryParse(user.longitude) ?? 0.0;
    final dropLat = order.customer.latitude ?? 0.0;
    final dropLng = order.customer.longitude ?? 0.0;

    if (pickupLat == 0.0 || pickupLng == 0.0) {
      state = state.copyWith(
        isRequestingRider: false,
        requestError: 'Shop location is missing',
      );
      return false;
    }

    if (dropLat == 0.0 || dropLng == 0.0) {
      state = state.copyWith(
        isRequestingRider: false,
        requestError: 'Customer location is missing',
      );
      return false;
    }

    state = state.copyWith(isRequestingRider: true, requestError: null);
    try {
      final request = RequestRiderOrder(
        orderType: 'parcel',
        vehicleType: 'bike',
        pickupAddress: user.shopAddress,
        pickupLat: pickupLat,
        pickupLng: pickupLng,
        pickupContactName: user.shopName,
        pickupContactPhone: user.shopPhoneNo,
        dropAddress: order.customer.address ?? '',
        dropLat: dropLat,
        dropLng: dropLng,
        dropContactName: order.customer.name,
        dropContactPhone: order.customer.phone,
        distanceKm: 2,
        estimatedTimeMins: 5,
        paymentMethod: order.paymentMethod ?? 'cod',
        itemCount: order.items.length,
        parcelType: null,
        weightKg: null,
      );

      final response = await _orderService.createCustomerOrder(request);
      final isOk = response.statusCode == 200 || response.statusCode == 201;
      
      Set<String> newFetching = state.fetchingRidersFor;
      if (isOk) {
        newFetching = Set<String>.from(state.fetchingRidersFor)..add(order.id);
      }
      
      state = state.copyWith(
        isRequestingRider: false,
        fetchingRidersFor: newFetching,
      );
      return isOk;
    } catch (e) {
      state = state.copyWith(
        isRequestingRider: false,
        requestError: e.toString(),
      );
      return false;
    }
  }

  void informCustomer(String orderId) {
    _orderService.updateStatus(orderId, 'out_for_delivery');
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _orderService.disconnect();
    _audioPlayer.dispose();
    super.dispose();
  }
}
