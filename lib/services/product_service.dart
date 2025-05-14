import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductApiService {
  static const String baseUrl =
      'https://gs1.org.sa/api/foreignGtin/getGtinProductDetails';

  Future<ProductResponse> getProductByBarcode(String barcode) async {
    try {
      // Create request with all required headers
      final response = await http.get(Uri.parse('$baseUrl?barcode=$barcode'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log(response.body);

        // Directly return ProductResponse with the new API format
        return ProductResponse.fromJson(data);
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching product: $e');
      }
      rethrow;
    }
  }
}
