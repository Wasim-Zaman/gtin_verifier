import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_image.dart';
import '../services/product_image_service.dart';

final productImageServiceProvider = Provider<ProductImageService>((ref) {
  return ProductImageService();
});

final productImageLoadingStateProvider = StateProvider.family<bool, String>(
  (ref, barcode) => false,
);

final productImagesProvider = FutureProvider.family<List<ProductImage>, String>(
  (ref, barcode) async {
    final shouldLoad = ref.watch(productImageLoadingStateProvider(barcode));
    if (!shouldLoad) return [];
    final service = ref.watch(productImageServiceProvider);
    return await service.getImagesByBarcode(barcode);
  },
);
