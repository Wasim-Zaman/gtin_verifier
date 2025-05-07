import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/promotion.dart';
import '../services/promotion_service.dart';

final promotionServiceProvider = Provider<PromotionService>((ref) {
  return PromotionService();
});

final promotionLoadingStateProvider = StateProvider.family<bool, String>(
  (ref, gtin) => false,
);

final promotionsProvider = FutureProvider.family<List<Promotion>, String>((
  ref,
  gtin,
) async {
  final shouldLoad = ref.watch(promotionLoadingStateProvider(gtin));
  if (!shouldLoad) return [];
  final service = ref.watch(promotionServiceProvider);
  return await service.getPromotionsByGtin(gtin);
});
