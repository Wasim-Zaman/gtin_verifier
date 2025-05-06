import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../services/product_service.dart';

final productServiceProvider = Provider<ProductApiService>((ref) {
  return ProductApiService();
});

final productProvider = FutureProvider.family<Products?, String>((
  ref,
  barcode,
) async {
  if (barcode.isEmpty) {
    return null;
  }

  try {
    final productService = ref.watch(productServiceProvider);
    final response = await productService.getProductByBarcode(barcode);

    if (response.products != null && response.products!.isNotEmpty) {
      return response.products!.first;
    } else {
      return null;
    }
  } catch (e) {
    throw Exception('Failed to load product: $e');
  }
});
