import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/request_rider_order.dart';
import 'api_url.dart';

class OrderService {
  WebSocketChannel? _channel;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final Dio _dio = Dio();

  OrderService() {
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

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
    final payload = {
      "type": "update_packing",
      "order_id": orderId,
      "rider_name": riderName,
      "rider_phone": riderPhone,
      "vehicle_number": vehicleNumber,
      "vehicle_model": vehicleModel,
    };
    _send(payload);
  }

  void updateStatus(String orderId, String newStatus, {String? transactionId}) {
    final payload = {
      "type": "update_status",
      "order_id": orderId,
      "new_status": newStatus,
      "transaction_id": transactionId,
    };
    _send(payload);
  }

  void getShopOrders(int page, {int limit = 20, String? status}) {
    final payload = {
      "type": "get_shop_orders",
      "page": page,
      "limit": limit,
      "status": status,
    };
    _send(payload);
  }

  Future<Response> createCustomerOrder(RequestRiderOrder request) async {
    try {
      // 🚨 PHASE 1 QUICK TEST: Paste your actual token from Swagger/Postman here
      final String testToken =
          "e0b3549686a40712c06a1eb60c13768076ce805d3aba2ac069a530ad4b61287a7";

      return await _dio.post(
        ApiUrl.createCustomerOrder,
        data: request.toJson(),
        // 💥 Inject the Authorization header right here
        options: Options(headers: {'Authorization': 'Bearer $testToken'}),
      );
    } catch (e) {
      rethrow;
    }
  }
}
