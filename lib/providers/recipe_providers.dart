import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/recipe.dart';
import '../services/recipe_service.dart';

final recipeServiceProvider = Provider<RecipeService>((ref) {
  return RecipeService();
});

final recipeLoadingStateProvider = StateProvider.family<bool, String>(
  (ref, gtin) => false,
);

final recipesProvider = FutureProvider.family<List<Recipe>, String>((
  ref,
  gtin,
) async {
  final shouldLoad = ref.watch(recipeLoadingStateProvider(gtin));
  if (!shouldLoad) return [];
  final service = ref.watch(recipeServiceProvider);
  return await service.getRecipesByGtin(gtin);
});
