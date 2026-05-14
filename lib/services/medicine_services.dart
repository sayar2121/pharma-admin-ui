import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/available_medicine.dart';
import '../models/medicine_inventory.dart';
import 'api_url.dart';

class MedicineService {
  final Dio _dio = Dio();

  MedicineService() {
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ));
  }

  Future<List<AvailableMedicine>> getAllMedicines({
    String? searchQuery,
    String? categoryFilter,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Add query parameters for filtering/searching and pagination
      Map<String, dynamic> queryParameters = {
        'page': page,
        'limit': limit,
      };
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParameters['search'] = searchQuery;
      }
      if (categoryFilter != null && categoryFilter.isNotEmpty && categoryFilter != 'All') {
        queryParameters['category'] = categoryFilter;
      }

      final response = await _dio.get(
        ApiUrl.getAllMedicines,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        // Assuming backend returns a list in response.data or response.data['data']
        List<dynamic> dataList = [];
        if (response.data is List) {
          dataList = response.data;
        } else if (response.data['data'] != null) {
          dataList = response.data['data'];
        }

        return dataList.map((json) => AvailableMedicine.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // Inventory Operations
  Future<MedicineInventory> addToInventory({
    required String shopId,
    required String medicineId,
    required double discountPercent,
    required String status,
  }) async {
    try {
      final formData = FormData.fromMap({
        'shop_id': shopId,
        'medicine_id': medicineId,
        'discount_percent': discountPercent,
        'status': status.toLowerCase(),
      });

      final response = await _dio.post(
        ApiUrl.addToInventory,
        data: formData,
      );
      return MedicineInventory.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MedicineInventory>> getShopInventory(String shopId) async {
    try {
      final response = await _dio.get("${ApiUrl.getInventoryByShop}/$shopId");
      if (response.statusCode == 200) {
        List<dynamic> data = response.data is List ? response.data : response.data['data'] ?? [];
        return data.map((json) => MedicineInventory.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<MedicineInventory> updateInventoryItem({
    required String inventoryId,
    double? discountPercent,
    String? status,
  }) async {
    try {
      Map<String, dynamic> data = {};
      if (discountPercent != null) data['discount_percent'] = discountPercent;
      if (status != null) data['status'] = status.toLowerCase();

      final formData = FormData.fromMap(data);

      final response = await _dio.put(
        "${ApiUrl.updateInventory}/$inventoryId",
        data: formData,
      );
      return MedicineInventory.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteInventoryItem(String inventoryId) async {
    try {
      await _dio.delete("${ApiUrl.deleteInventory}/$inventoryId");
    } catch (e) {
      rethrow;
    }
  }
}
