import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_url.dart';

final supportServicesProvider = Provider<SupportServices>((ref) {
  return SupportServices();
});

class SupportServices {
  final Dio _dio;

  SupportServices() : _dio = Dio() {
    // Assuming ApiUrl.baseUrl is for Medy24 backend
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  Future<void> submitFeedback(int rating, String description) async {
    try {
      final response = await _dio.post(
        '${ApiUrl.baseUrl}/support/feedback/create',
        data: {
          'rating': rating,
          'description': description,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to submit feedback');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Unknown error occurred');
    }
  }

  Future<void> submitProblemReport(String category, String description) async {
    try {
      final response = await _dio.post(
        '${ApiUrl.baseUrl}/support/report-problem/create',
        data: {
          'category': category,
          'description': description,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to submit report');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Unknown error occurred');
    }
  }
}
