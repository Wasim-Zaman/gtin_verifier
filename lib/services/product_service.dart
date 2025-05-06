import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductApiService {
  static const String baseUrl = 'https://gs1ksa.org/api';
  static const String authToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJjbHpucGQ4ZXQwMDA1YWE3dnpzNWtxdTk1IiwiZW1haWwiOiJoYXNuYWluLmFobWFkUHJvQGdtYWlsLmNvbSIsImlhdCI6MTc0MzY3NDE1OCwiZXhwIjoxNzUxNDUwMTU4fQ.54Fm_x-kntkA8wsovKW6EqQ5BC1SSGNzgSvsQvQGcJU';

  Future<ProductResponse> getProductByBarcode(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/products/paginatedProducts?page=1&pageSize=1&barcode=$barcode',
        ),
        headers: {
          'accept': 'application/json',
          'authorization': 'Bearer $authToken',
          'origin': 'https://gtrack.online',
          'referer': 'https://gtrack.online/',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log(response.body);
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
