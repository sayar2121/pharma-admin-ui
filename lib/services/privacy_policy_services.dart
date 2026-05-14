import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_url.dart';

class PrivacyPolicyServices {
  final Dio _dio = Dio();

  PrivacyPolicyServices() {
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

  Future<Response> getAllPrivacyPolicies() async {
    return await _dio.get(ApiUrl.getPrivacyPoliciesAll);
  }
}
