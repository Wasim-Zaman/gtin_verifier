import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/ingredient.dart';

class IngredientService {
  static const String baseUrl = 'https://upchub.online/api';

  Future<IngredientResponse> getIngredientsByBarcode(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/digitalLinks/ingredients?page=1&pageSize=10&barcode=$barcode',
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
        return IngredientResponse.fromJson(data);
      } else {
        throw Exception('Failed to load ingredients: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching ingredients: $e');
      }
      rethrow;
    }
  }
}
