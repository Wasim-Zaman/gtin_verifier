import 'package:flutter/material.dart';
import 'package:gtin_verifier/models/product.dart';
import 'package:gtin_verifier/view/widgets/expansion_tile_card.dart';

class ProductInfoTab extends StatelessWidget {
  final Products product;

  const ProductInfoTab({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ExpansionTileCard(
            title: 'Allergen Information',
            icon: Icons.health_and_safety_outlined,
            onExpand: () {
              // Will implement API call later
              // fetchAllergenInformation(product.barcode);
            },
            content: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text('Allergen information will be loaded here'),
              ),
            ),
          ),

          ExpansionTileCard(
            title: 'Has Retailers',
            icon: Icons.store_outlined,
            onExpand: () {
              // Will implement API call later
              // fetchRetailers(product.barcode);
            },
            content: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text('Retailer information will be loaded here'),
              ),
            ),
          ),

          ExpansionTileCard(
            title: 'Ingredients Information',
            icon: Icons.list_alt_outlined,
            onExpand: () {
              // Will implement API call later
              // fetchIngredients(product.barcode);
            },
            content: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text('Ingredient information will be loaded here'),
              ),
            ),
          ),

          ExpansionTileCard(
            title: 'Instructions',
            icon: Icons.menu_book_outlined,
            onExpand: () {
              // Will implement API call later
              // fetchInstructions(product.barcode);
            },
            content: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('Instructions will be loaded here')),
            ),
          ),

          ExpansionTileCard(
            title: 'Packaging',
            icon: Icons.inventory_2_outlined,
            onExpand: () {
              // Will implement API call later
              // fetchPackaging(product.barcode);
            },
            content: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text('Packaging information will be loaded here'),
              ),
            ),
          ),

          ExpansionTileCard(
            title: 'Promotion',
            icon: Icons.local_offer_outlined,
            onExpand: () {
              // Will implement API call later
              // fetchPromotions(product.barcode);
            },
            content: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text('Promotion information will be loaded here'),
              ),
            ),
          ),

          ExpansionTileCard(
            title: 'Recipe Info',
            icon: Icons.dinner_dining_outlined,
            onExpand: () {
              // Will implement API call later
              // fetchRecipes(product.barcode);
            },
            content: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text('Recipe information will be loaded here'),
              ),
            ),
          ),

          ExpansionTileCard(
            title: 'Electronic Leaflets',
            icon: Icons.description_outlined,
            onExpand: () {
              // Will implement API call later
              // fetchLeaflets(product.barcode);
            },
            content: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text('Electronic leaflets will be loaded here'),
              ),
            ),
          ),

          ExpansionTileCard(
            title: 'Images',
            icon: Icons.image_outlined,
            onExpand: () {
              // Will implement API call later
              // fetchImages(product.barcode);
            },
            content: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text('Product images will be displayed here'),
              ),
            ),
          ),

          ExpansionTileCard(
            title: 'Videos',
            icon: Icons.video_library_outlined,
            onExpand: () {
              // Will implement API call later
              // fetchVideos(product.barcode);
            },
            content: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text('Product videos will be displayed here'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
