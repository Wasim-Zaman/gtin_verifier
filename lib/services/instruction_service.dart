import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/instruction.dart';

class InstructionService {
  static const String baseUrl = 'https://upchub.online/api';

  Future<InstructionResponse> getInstructionsByBarcode(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/digitalLinks/instructions?page=1&pageSize=10&barcode=$barcode',
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
        return InstructionResponse.fromJson(data);
      } else {
        throw Exception('Failed to load instructions: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching instructions: $e');
      }
      rethrow;
    }
  }
}
