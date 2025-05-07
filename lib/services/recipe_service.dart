import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/recipe.dart';

class RecipeService {
  static const String baseUrl = 'https://backend.gtrack.online/api';

  Future<List<Recipe>> getRecipesByGtin(String gtin) async {
    final url = '$baseUrl/getRecipeDataByGtin/$gtin';
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
      return data.map((e) => Recipe.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }
}
