import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/promotion.dart';

class PromotionService {
  static const String baseUrl = 'https://backend.gtrack.online/api';

  Future<List<Promotion>> getPromotionsByGtin(String gtin) async {
    final url = '$baseUrl/getPromotionalOffersByGtin/$gtin';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'accept': 'application/json, text/plain, */*',
        'origin': 'https://gtrack.online',
        'referer': 'https://gtrack.online/',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Promotion.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load promotions');
    }
  }
}
