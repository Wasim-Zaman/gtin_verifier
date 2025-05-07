import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_video.dart';
import '../services/product_video_service.dart';

final productVideoServiceProvider = Provider<ProductVideoService>((ref) {
  return ProductVideoService();
});

final productVideoLoadingStateProvider = StateProvider.family<bool, String>(
  (ref, barcode) => false,
);

final productVideosProvider = FutureProvider.family<List<ProductVideo>, String>(
  (ref, barcode) async {
    final shouldLoad = ref.watch(productVideoLoadingStateProvider(barcode));
    if (!shouldLoad) return [];
    final service = ref.watch(productVideoServiceProvider);
    return await service.getVideosByBarcode(barcode);
  },
);
