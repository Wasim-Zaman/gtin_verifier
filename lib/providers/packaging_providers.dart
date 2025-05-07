// lib/providers/packaging_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/packaging.dart';
import '../services/packaging_service.dart';

// Service provider
final packagingServiceProvider = Provider<PackagingService>((ref) {
  return PackagingService();
});

// State provider to track when to load packagings
final packagingLoadingStateProvider = StateProvider.family<bool, String>(
  (ref, barcode) => false,
);

// Provider to fetch packagings when triggered
final packagingsProvider = FutureProvider.family<List<Packaging>, String>((
  ref,
  barcode,
) async {
  // Check if loading has been triggered
  final shouldLoad = ref.watch(packagingLoadingStateProvider(barcode));

  if (!shouldLoad) {
    return []; // Return empty list if not triggered yet
  }

  final packagingService = ref.watch(packagingServiceProvider);
  final response = await packagingService.getPackagingsByBarcode(barcode);
  return response.packagings;
});
