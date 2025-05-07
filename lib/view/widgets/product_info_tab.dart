import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/allergen.dart';
import '../../models/product.dart';
import '../../providers/allergen_providers.dart';
import '../../providers/ingredient_providers.dart';
import '../../providers/instruction_providers.dart';
import '../../providers/leaflet_providers.dart';
import '../../providers/packaging_providers.dart';
import '../../providers/product_image_providers.dart';
import '../../providers/product_video_providers.dart';
import '../../providers/promotion_providers.dart';
import '../../providers/recipe_providers.dart';
import '../../providers/retailer_providers.dart';
import 'expansion_tile_card.dart';
import 'ingredient_content.dart';
import 'instruction_content.dart';
import 'leaflet_content.dart';
import 'packaging_content.dart';
import 'product_image_content.dart';
import 'product_video_content.dart';
import 'promotion_content.dart';
import 'recipe_content.dart';
import 'retailer_content.dart';

class ProductInfoTab extends ConsumerWidget {
  final Products product;

  const ProductInfoTab({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final barcode = product.barcode ?? '';

    // Watch the allergen and retailer data
    final allergensAsync = ref.watch(allergensProvider(barcode));
    final retailersAsync = ref.watch(retailersProvider(barcode));
    final ingredientsAsync = ref.watch(ingredientsProvider(barcode));
    final instructionsAsync = ref.watch(instructionsProvider(barcode));
    final packagingsAsync = ref.watch(packagingsProvider(barcode));

    return SingleChildScrollView(
      child: Column(
        children: [
          // Allergen Information
          ExpansionTileCard(
            title: 'Allergen Information',
            icon: Icons.health_and_safety_outlined,
            asyncValue: allergensAsync,
            onExpand: () {
              // Set loading state to true when expanded
              ref.read(allergenLoadingStateProvider(barcode).notifier).state =
                  true;
            },
            contentBuilder: (isLoading, hasError, error) {
              // Show loading, error, or data based on state
              if (isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Error loading allergen information: ${error?.toString() ?? "Unknown error"}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                );
              }

              // Get the data if available
              final allergens = allergensAsync.value ?? [];

              if (allergens.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text('No allergen information available'),
                  ),
                );
              }

              // Display allergen data
              return _buildAllergensList(context, allergens);
            },
          ),

          // Has Retailers
          ExpansionTileCard(
            title: 'Has Retailers',
            icon: Icons.store_outlined,
            asyncValue: retailersAsync,
            onExpand: () {
              ref.read(retailerLoadingStateProvider(barcode).notifier).state =
                  true;
            },
            contentBuilder: (isLoading, hasError, error) {
              if (isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Error loading retailer information: ${error?.toString() ?? "Unknown error"}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                );
              }

              final retailers = retailersAsync.value ?? [];
              return RetailerContent(retailers: retailers);
            },
          ),

          // Ingredients Information
          ExpansionTileCard(
            title: 'Ingredients Information',
            icon: Icons.restaurant_menu_outlined,
            asyncValue: ingredientsAsync,
            onExpand: () {
              ref.read(ingredientLoadingStateProvider(barcode).notifier).state =
                  true;
            },
            contentBuilder: (isLoading, hasError, error) {
              if (isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Error loading ingredient information: ${error?.toString() ?? "Unknown error"}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                );
              }

              final ingredients = ingredientsAsync.value ?? [];
              return IngredientContent(ingredients: ingredients);
            },
          ),

          // Instructions
          ExpansionTileCard(
            title: 'Instructions',
            icon: Icons.description_outlined,
            asyncValue: instructionsAsync,
            onExpand: () {
              ref
                  .read(instructionLoadingStateProvider(barcode).notifier)
                  .state = true;
            },
            contentBuilder: (isLoading, hasError, error) {
              if (isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Error loading instructions: ${error?.toString() ?? "Unknown error"}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                );
              }

              final instructions = instructionsAsync.value ?? [];
              return InstructionContent(instructions: instructions);
            },
          ),

          // Packaging Information
          ExpansionTileCard(
            title: 'Packaging Information',
            icon: Icons.inventory_2_outlined,
            asyncValue: packagingsAsync,
            onExpand: () {
              ref.read(packagingLoadingStateProvider(barcode).notifier).state =
                  true;
            },
            contentBuilder: (isLoading, hasError, error) {
              if (isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Error loading packaging information: ${error?.toString() ?? "Unknown error"}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                );
              }

              final packagings = packagingsAsync.value ?? [];
              return PackagingContent(packagings: packagings);
            },
          ),

          // Promotion Information
          ExpansionTileCard(
            title: 'Promotion Information',
            icon: Icons.local_offer_outlined,
            asyncValue: ref.watch(promotionsProvider(barcode)),
            onExpand: () {
              ref.read(promotionLoadingStateProvider(barcode).notifier).state =
                  true;
            },
            contentBuilder: (isLoading, hasError, error) {
              if (isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Error loading promotion information: ${error?.toString() ?? "Unknown error"}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                );
              }
              final promotions =
                  ref.watch(promotionsProvider(barcode)).value ?? [];
              return PromotionContent(promotions: promotions);
            },
          ),

          // Recipe Information
          ExpansionTileCard(
            title: 'Recipe Information',
            icon: Icons.restaurant_menu,
            asyncValue: ref.watch(recipesProvider(barcode)),
            onExpand: () {
              ref.read(recipeLoadingStateProvider(barcode).notifier).state =
                  true;
            },
            contentBuilder: (isLoading, hasError, error) {
              if (isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Error loading recipe information: ${error?.toString() ?? "Unknown error"}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                );
              }
              final recipes = ref.watch(recipesProvider(barcode)).value ?? [];
              return RecipeContent(recipes: recipes);
            },
          ),

          // Electronic Leaflets
          ExpansionTileCard(
            title: 'Electronic Leaflets',
            icon: Icons.picture_as_pdf_outlined,
            asyncValue: ref.watch(leafletsProvider(barcode)),
            onExpand: () {
              ref.read(leafletLoadingStateProvider(barcode).notifier).state =
                  true;
            },
            contentBuilder: (isLoading, hasError, error) {
              if (isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Error loading electronic leaflets: ${error?.toString() ?? "Unknown error"}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                );
              }
              final leaflets = ref.watch(leafletsProvider(barcode)).value ?? [];
              return LeafletContent(leaflets: leaflets);
            },
          ),

          // Images
          ExpansionTileCard(
            title: 'Images',
            icon: Icons.image_outlined,
            asyncValue: ref.watch(productImagesProvider(barcode)),
            onExpand: () {
              ref
                  .read(productImageLoadingStateProvider(barcode).notifier)
                  .state = true;
            },
            contentBuilder: (isLoading, hasError, error) {
              if (isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Error loading images: ${error?.toString() ?? "Unknown error"}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                );
              }
              final images =
                  ref.watch(productImagesProvider(barcode)).value ?? [];
              return ProductImageContent(images: images);
            },
          ),

          // Videos
          ExpansionTileCard(
            title: 'Videos',
            icon: Icons.videocam_outlined,
            asyncValue: ref.watch(productVideosProvider(barcode)),
            onExpand: () {
              ref
                  .read(productVideoLoadingStateProvider(barcode).notifier)
                  .state = true;
            },
            contentBuilder: (isLoading, hasError, error) {
              if (isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Error loading videos: ${error?.toString() ?? "Unknown error"}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                );
              }
              final videos =
                  ref.watch(productVideosProvider(barcode)).value ?? [];
              return ProductVideoContent(videos: videos);
            },
          ),

          // Keep the rest of your expansion tiles...
          // Ingredients Information, Instructions, etc.
        ],
      ),
    );
  }

  Widget _buildAllergensList(BuildContext context, List<Allergen> allergens) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM d, yyyy');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Allergen Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Allergen items
          ...allergens.map(
            (allergen) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              color: colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: colorScheme.outlineVariant, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Allergen name and type
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getSeverityColor(
                              allergen.severity,
                              colorScheme,
                            ).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.warning_amber_outlined,
                            color: _getSeverityColor(
                              allergen.severity,
                              colorScheme,
                            ),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                allergen.allergenName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Type: ${allergen.allergenType}',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getSeverityColor(
                              allergen.severity,
                              colorScheme,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            allergen.severity,
                            style: TextStyle(
                              color: _getSeverityColor(
                                allergen.severity,
                                colorScheme,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),

                    // Details grid
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildDetailChip(
                          'Contains Allergen',
                          allergen.containsAllergen ? 'Yes' : 'No',
                          Icons.check_circle_outline,
                          allergen.containsAllergen
                              ? colorScheme.error
                              : colorScheme.primary,
                          colorScheme,
                        ),
                        _buildDetailChip(
                          'May Contain',
                          allergen.mayContain ? 'Yes' : 'No',
                          Icons.help_outline,
                          allergen.mayContain
                              ? colorScheme.tertiary
                              : colorScheme.primary,
                          colorScheme,
                        ),
                        _buildDetailChip(
                          'Cross Contamination',
                          allergen.crossContaminationRisk ? 'Yes' : 'No',
                          Icons.warning_outlined,
                          allergen.crossContaminationRisk
                              ? colorScheme.error
                              : colorScheme.primary,
                          colorScheme,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Source
                    if (allergen.allergenSource.isNotEmpty) ...[
                      Text(
                        'Source: ${allergen.allergenSource}',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Dates
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateInfo(
                            'Production',
                            dateFormat.format(allergen.productionDate),
                            Icons.calendar_today_outlined,
                            colorScheme,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDateInfo(
                            'Expiration',
                            dateFormat.format(allergen.expirationDate),
                            Icons.event_busy_outlined,
                            colorScheme,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Lot number
                    Text(
                      'Lot Number: ${allergen.lotNumber}',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(
    String label,
    String value,
    IconData icon,
    Color color,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo(
    String label,
    String date,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor(String severity, ColorScheme colorScheme) {
    switch (severity.toLowerCase()) {
      case 'high':
        return colorScheme.error;
      case 'medium':
        return colorScheme.tertiary;
      case 'low':
        return colorScheme.primary;
      default:
        return colorScheme.secondary;
    }
  }
}
