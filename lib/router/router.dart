import 'package:go_router/go_router.dart';

import '../view/screens/barcode_test_screen.dart';
import '../view/screens/barcode_verifier_screen.dart';
import '../view/screens/product_details_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const BarcodeVerifierScreen(),
    ),
    GoRoute(
      path: '/test',
      builder: (context, state) => const BarcodeTestScreen(),
    ),
    GoRoute(
      path: '/product/:barcode',
      builder: (context, state) {
        final barcode = state.pathParameters['barcode'] ?? '';
        return ProductDetailsScreen(barcode: barcode);
      },
    ),
    // Add more routes here when needed for GS1 product information
  ],
);
