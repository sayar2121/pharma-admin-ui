import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'api_url.dart';

class OrderService {
  WebSocketChannel? _channel;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  bool get isConnected => _channel != null;

  void connect(String shopId) {
    if (_channel != null) return;

    final wsUrl = Uri.parse(ApiUrl.shopWebSocket(shopId));
    try {
      _channel = WebSocketChannel.connect(wsUrl);

      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message) as Map<String, dynamic>;
            _messageController.add(data);
          } catch (e) {
            if (kDebugMode) {
              print("Failed to decode WS message: $e");
            }
          }
        },
        onDone: () {
          if (kDebugMode) {
            print("WS connection closed");
          }
          _channel = null;
        },
        onError: (error) {
          if (kDebugMode) {
            print("WS connection error: $error");
          }
          _channel = null;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print("Failed to connect WS: $e");
      }
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  void _send(Map<String, dynamic> data) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(data));
    } else {
      if (kDebugMode) {
        print("Cannot send message, WS not connected");
      }
    }
  }

  void acceptOrder(String orderId) {
    _send({"type": "accept_order", "order_id": orderId});
  }

  void updatePacking(
    String orderId, {
    required String riderName,
    required String riderPhone,
    String? vehicleNumber,
    String? vehicleModel,
  }) {
    _send({
      "type": "update_packing",
      "order_id": orderId,
      "rider_name": riderName,
      "rider_phone": riderPhone,
      "vehicle_number": ?vehicleNumber,
      "vehicle_model": ?vehicleModel,
    });
  }

  void updateStatus(String orderId, String newStatus, {String? transactionId}) {
    _send({
      "type": "update_status",
      "order_id": orderId,
      "new_status": newStatus,
      "transaction_id": ?transactionId,
    });
  }

  void getShopOrders(int page, {int limit = 20, String? status}) {
    _send({
      "type": "get_shop_orders",
      "page": page,
      "limit": limit,
      "status": ?status,
    });
  }
}
