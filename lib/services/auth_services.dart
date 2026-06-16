import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/user.dart';
import 'api_url.dart';

class AuthService {
  final Dio _dio = Dio();

  AuthService() {
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

  Future<Response> login(String email, String password) async {
    try {
      FormData formData = FormData.fromMap({
        'email': email,
        'password': password,
      });
      return await _dio.post(ApiUrl.login, data: formData);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> signup(User user) async {
    try {
      Map<String, dynamic> userMap = user.toMap();
      Map<String, dynamic> formMap = {};

      // Map of our model field names to backend expected names for files
      final fileFieldMapping = {
        'drug_license_upload': 'drug_license',
        'pan_card_upload': 'pan_card',
        'registration_certificate_upload': 'registration_certificate',
        'shop_photo': 'shop_photo',
        'gst_certificate_upload': 'gst_certificate',
        'trade_license_upload': 'trade_license',
        'aadhaar_card_upload': 'aadhaar_card',
        'pharmacist_reg_upload': 'pharmacist_reg',
        'bank_document_upload': 'bank_document',
        'address_proof_upload': 'address_proof',
        'owner_photo': 'owner_photo',
      };

      for (var entry in userMap.entries) {
        final key = entry.key;
        final value = entry.value;

        if (value != null && value is String && value.isNotEmpty) {
          if (fileFieldMapping.containsKey(key)) {
            // Check if it's a valid local path (Not supported on Web)
            if (!kIsWeb && File(value).existsSync()) {
              formMap[fileFieldMapping[key]!] = await MultipartFile.fromFile(value);
            }
          } else {
            // Normal text field
            formMap[key] = value;
          }
        } else if (value != null) {
          formMap[key] = value;
        }
      }

      FormData formData = FormData.fromMap(formMap);
      return await _dio.post(ApiUrl.signup, data: formData);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateProfile(String shopId, User user) async {
    try {
      Map<String, dynamic> userMap = user.toMap();
      Map<String, dynamic> formMap = {};

      final fileFieldMapping = {
        'drug_license_upload': 'drug_license',
        'pan_card_upload': 'pan_card',
        'registration_certificate_upload': 'registration_certificate',
        'shop_photo': 'shop_photo',
        'gst_certificate_upload': 'gst_certificate',
        'trade_license_upload': 'trade_license',
        'aadhaar_card_upload': 'aadhaar_card',
        'pharmacist_reg_upload': 'pharmacist_reg',
        'bank_document_upload': 'bank_document',
        'address_proof_upload': 'address_proof',
        'owner_photo': 'owner_photo',
      };

      for (var entry in userMap.entries) {
        final key = entry.key;
        final value = entry.value;

        if (value != null && value is String && value.isNotEmpty) {
          if (fileFieldMapping.containsKey(key)) {
            // Upload if it's not a web URL or an existing backend URL
            if (!kIsWeb && !value.contains('uploads/pharma_shop') && !value.contains('skipped_for_web_testing')) {
              try {
                formMap[fileFieldMapping[key]!] = await MultipartFile.fromFile(value);
              } catch (e) {
                if (kDebugMode) {
                  print("Failed to attach file $value: $e");
                }
              }
            }
          } else {
            formMap[key] = value;
          }
        } else if (value != null) {
          formMap[key] = value;
        }
      }

      FormData formData = FormData.fromMap(formMap);
      return await _dio.put("${ApiUrl.updateShopById}/$shopId", data: formData);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getShopById(String shopId) async {
    try {
      return await _dio.get("${ApiUrl.getShopById}/$shopId");
    } catch (e) {
      rethrow;
    }
  }
}
