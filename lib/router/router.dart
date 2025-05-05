import 'package:go_router/go_router.dart';

import '../view/screens/barcode_verifier_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const BarcodeVerifierScreen(),
    ),
    // Add more routes here when needed for GS1 product information
  ],
);
