import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_video.dart';

class ProductVideoService {
  static const String baseUrl = 'https://upchub.online/api';

  Future<List<ProductVideo>> getVideosByBarcode(String barcode) async {
    final url =
        '$baseUrl/digitalLinks/videos?page=1&pageSize=10&barcode=$barcode';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'accept': 'application/json, text/plain, */*',
        'origin': 'https://gtrack.online',
        'referer': 'https://gtrack.online/',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ProductVideoResponse.fromJson(data).videos;
    } else {
      throw Exception('Failed to load product videos');
    }
  }
}
