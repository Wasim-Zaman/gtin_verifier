import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ingredient.dart';
import '../services/ingredient_service.dart';

// Service provider
final ingredientServiceProvider = Provider<IngredientService>((ref) {
  return IngredientService();
});

// State provider to track when to load ingredients
final ingredientLoadingStateProvider = StateProvider.family<bool, String>(
  (ref, barcode) => false,
);

// Provider to fetch ingredients when triggered
final ingredientsProvider = FutureProvider.family<List<Ingredient>, String>((
  ref,
  barcode,
) async {
  // Check if loading has been triggered
  final shouldLoad = ref.watch(ingredientLoadingStateProvider(barcode));

  if (!shouldLoad) {
    return []; // Return empty list if not triggered yet
  }

  final ingredientService = ref.watch(ingredientServiceProvider);
  final response = await ingredientService.getIngredientsByBarcode(barcode);
  return response.ingredients;
});
