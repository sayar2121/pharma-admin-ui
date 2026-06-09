import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/order.dart';
import '../models/request_rider_order.dart';
import '../models/user.dart';
import '../services/order_services.dart';
import '../services/api_url.dart';

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


  OrderNotifier(this._orderService, this._shopId, this._user)
    : super(OrderState()) {
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
    } else if (type == 'pending_broadcast_orders' ||
        type == 'broadcast_orders_list') {
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
    if (!_orderService.isConnected) {
      _orderService.connect(_shopId);
    }
    _orderService.getShopOrders(1);
    if (!state.isOnline) {
      state = state.copyWith(isOnline: true);
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
        orderType: 'medicine',
        vehicleType: 'medicine_bike',
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
      state = state.copyWith(isRequestingRider: false);
      
      if (isOk) {
        // Automatically start searching for a rider via WS
        fetchAndInformCustomer(order.id);
      }
      
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

  Future<bool> fetchAndInformCustomer(String orderId) async {
    if (state.fetchingRidersFor.contains(orderId) || state.ridersFetchedFor.contains(orderId)) return false;

    final newFetching = Set<String>.from(state.fetchingRidersFor)..add(orderId);
    state = state.copyWith(fetchingRidersFor: newFetching);

    final wsUrl = Uri.parse(ApiUrl.trackOrderWs(orderId));
    final channel = WebSocketChannel.connect(wsUrl);
    final completer = Completer<bool>();

    final sub = channel.stream.listen(
      (message) {
        try {
          final data = jsonDecode(message) as Map<String, dynamic>;
          if (data['type'] == 'driver_assigned' || data['assigned_driver_name'] != null || data['rider_name'] != null || data['driver_name'] != null || data['driver'] != null) {
            final riderData = data['driver'] ?? data;
            
            final riderName = riderData['assigned_driver_name'] ?? riderData['rider_name'] ?? riderData['driver_name'] ?? riderData['name'] ?? 'Unknown Rider';
            final riderPhone = riderData['assigned_driver_phone'] ?? riderData['rider_phone'] ?? riderData['driver_phone'] ?? riderData['phone'] ?? 'N/A';
            final vehicleNumber = riderData['vehicle_number'];
            final vehicleModel = riderData['vehicle_model'];

            _orderService.updatePacking(
              orderId,
              riderName: riderName,
              riderPhone: riderPhone,
              vehicleNumber: vehicleNumber,
              vehicleModel: vehicleModel,
            );
            
            // Mark the order as out for delivery now that a driver has accepted it
            _orderService.updateStatus(orderId, 'out_for_delivery');
            
            try {
              final existingOrder = state.activeOrders.firstWhere((o) => o.id == orderId);
              final newRider = Rider(
                id: riderData['assigned_driver_id'] ?? riderData['rider_id'] ?? riderData['driver_id'] ?? riderData['id'] ?? '',
                name: riderName,
                phone: riderPhone,
                vehicleNumber: vehicleNumber,
                vehicleModel: vehicleModel,
              );
              _updateActiveOrder(existingOrder.copyWith(rider: newRider, status: 'out_for_delivery'));
            } catch (e) {
              if (kDebugMode) print("Order not found to update rider locally");
            }
            
            if (!completer.isCompleted) completer.complete(true);
          }
        } catch (e) {
          if (kDebugMode) print("Failed to decode tracking WS message: $e");
        }
      },
      onError: (e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
      onDone: () {
        if (!completer.isCompleted) completer.complete(false);
      }
    );

    bool success = false;
    try {
      success = await completer.future.timeout(const Duration(minutes: 5));
    } catch (e) {
      if (kDebugMode) print("Fetching rider timed out or failed: $e");
    } finally {
      sub.cancel();
      channel.sink.close();
      
      final nextFetching = Set<String>.from(state.fetchingRidersFor)..remove(orderId);
      final nextFetched = Set<String>.from(state.ridersFetchedFor);
      if (success) {
        nextFetched.add(orderId);
      }
      state = state.copyWith(fetchingRidersFor: nextFetching, ridersFetchedFor: nextFetched);
    }
    return success;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _orderService.disconnect();
    super.dispose();
  }
}
