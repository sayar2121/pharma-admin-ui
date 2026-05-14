import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/available_medicine.dart';
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
}
