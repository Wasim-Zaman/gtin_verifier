import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/allergen.dart';
import '../services/allergen_service.dart';

// Service provider
final allergenServiceProvider = Provider<AllergenService>((ref) {
  return AllergenService();
});

// State provider to track when to load allergens
final allergenLoadingStateProvider = StateProvider.family<bool, String>(
  (ref, barcode) => false,
);

// Provider to fetch allergens when triggered
final allergensProvider = FutureProvider.family<List<Allergen>, String>((
  ref,
  barcode,
) async {
  // Check if loading has been triggered
  final shouldLoad = ref.watch(allergenLoadingStateProvider(barcode));

  if (!shouldLoad) {
    return []; // Return empty list if not triggered yet
  }

  final allergenService = ref.watch(allergenServiceProvider);
  final response = await allergenService.getAllergensByBarcode(barcode);
  return response.allergens;
});
