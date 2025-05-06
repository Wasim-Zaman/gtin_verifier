import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/retailer.dart';
import '../services/retailer_service.dart';

// Service provider
final retailerServiceProvider = Provider<RetailerService>((ref) {
  return RetailerService();
});

// State provider to track when to load retailers
final retailerLoadingStateProvider = StateProvider.family<bool, String>(
  (ref, barcode) => false,
);

// Provider to fetch retailers when triggered
final retailersProvider = FutureProvider.family<List<Retailer>, String>((
  ref,
  barcode,
) async {
  // Check if loading has been triggered
  final shouldLoad = ref.watch(retailerLoadingStateProvider(barcode));

  if (!shouldLoad) {
    return []; // Return empty list if not triggered yet
  }

  final retailerService = ref.watch(retailerServiceProvider);
  final response = await retailerService.getRetailersByBarcode(barcode);
  return response.retailers;
});
