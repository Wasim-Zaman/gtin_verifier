import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/packaging.dart';

class PackagingService {
  static const String baseUrl = 'https://upchub.online/api';

  Future<PackagingResponse> getPackagingsByBarcode(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/digitalLinks/packagings?page=1&pageSize=10&barcode=$barcode',
        ),
        headers: {
          'accept': 'application/json, text/plain, */*',
          'origin': 'https://gtrack.online',
          'referer': 'https://gtrack.online/',
          'sec-fetch-dest': 'empty',
          'sec-fetch-mode': 'cors',
          'sec-fetch-site': 'cross-site',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PackagingResponse.fromJson(data);
      } else {
        throw Exception('Failed to load packagings: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching packagings: $e');
      }
      rethrow;
    }
  }
}
