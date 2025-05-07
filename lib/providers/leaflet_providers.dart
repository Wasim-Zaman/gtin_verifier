import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/leaflet.dart';
import '../services/leaflet_service.dart';

final leafletServiceProvider = Provider<LeafletService>((ref) {
  return LeafletService();
});

final leafletLoadingStateProvider = StateProvider.family<bool, String>(
  (ref, gtin) => false,
);

final leafletsProvider = FutureProvider.family<List<Leaflet>, String>((
  ref,
  gtin,
) async {
  final shouldLoad = ref.watch(leafletLoadingStateProvider(gtin));
  if (!shouldLoad) return [];
  final service = ref.watch(leafletServiceProvider);
  return await service.getLeafletsByGtin(gtin);
});
