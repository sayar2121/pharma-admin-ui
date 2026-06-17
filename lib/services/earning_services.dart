import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/earning.dart';
import 'api_url.dart';

class EarningService {
  Future<List<EarningModel>> fetchEarnings(String shopId, {int page = 1, int limit = 50, String period = 'all'}) async {
    final url = Uri.parse('${ApiUrl.baseUrl}/earnings/pharma-shop/get-all/$shopId?page=$page&limit=$limit&period=$period');
    
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List data = jsonResponse['data'] ?? [];
      return data.map((item) => EarningModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load earnings: ${response.statusCode}');
    }
  }

  Future<EarningSummary> fetchEarningSummary(String shopId, {String period = 'all'}) async {
    final url = Uri.parse('${ApiUrl.baseUrl}/earnings/pharma-shop/summary/$shopId?period=$period');
    
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return EarningSummary.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load earnings summary: ${response.statusCode}');
    }
  }
}
