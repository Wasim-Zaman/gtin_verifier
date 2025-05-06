import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/product.dart';
import '../../providers/product_providers.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final String barcode;

  const ProductDetailsScreen({super.key, required this.barcode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productProvider(barcode));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: colorScheme.surfaceContainerHighest,
        elevation: 0,
        scrolledUnderElevation: 3,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              colorScheme.surface.withValues(alpha: 0.9),
            ],
            stops: const [0.0, 0.7],
          ),
        ),
        child: productAsync.when(
          data: (product) {
            if (product == null) {
              return _buildEmptyState(context);
            }
            return _buildProductDetails(context, product);
          },
          loading: () => _buildLoadingShimmer(context),
          error: (error, stackTrace) => _buildErrorState(context, error, ref),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Card(
        elevation: 0,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 40,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No product found',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We couldn\'t find any product with this barcode',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: () => context.go('/'),
                child: const Text('Return to Scanner'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Card(
        elevation: 0,
        color: colorScheme.errorContainer.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.error.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 40,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Error loading product',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.error),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => ref.refresh(productProvider(barcode)),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surfaceContainerLow,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 24),

            // Title placeholder
            Container(
              height: 32,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),

            // Brand placeholder
            Container(
              height: 24,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 16),

            // Chips placeholder
            Row(
              children: [
                Container(
                  height: 32,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 32,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Divider placeholder
            Container(height: 1, width: double.infinity, color: Colors.white),
            const SizedBox(height: 16),

            // Detail rows
            for (int i = 0; i < 8; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 24,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails(BuildContext context, Products product) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          _buildProductImage(context, product, colorScheme),
          const SizedBox(height: 24),

          // Product Name
          Text(
            product.productnameenglish ?? 'No Name',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          if (product.productnamearabic != null &&
              product.productnamearabic!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                product.productnamearabic!,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Brand & Type
          _buildBrandTypeChips(context, product, colorScheme),
          const SizedBox(height: 24),

          // Divider
          Divider(color: colorScheme.outlineVariant),
          const SizedBox(height: 16),

          // All Details Card
          _buildDetailsCard(context, product, colorScheme),
          const SizedBox(height: 24),

          // Description Card
          if (product.detailsPage != null ||
              (product.detailsPageAr != null &&
                  product.detailsPageAr!.isNotEmpty))
            _buildDescriptionCard(context, product, colorScheme),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProductImage(
    BuildContext context,
    Products product,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 250,
          width: double.infinity,
          child:
              product.frontImage != null && product.frontImage!.isNotEmpty
                  ? Image.network(
                    product.frontImage!,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            _buildImageError(colorScheme),
                  )
                  : _buildImageError(colorScheme),
        ),
      ),
    );
  }

  Widget _buildImageError(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 60,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 8),
            Text(
              'No image available',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandTypeChips(
    BuildContext context,
    Products product,
    ColorScheme colorScheme,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (product.brandName != null && product.brandName!.isNotEmpty)
          Chip(
            label: Text(product.brandName!),
            labelStyle: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: colorScheme.primaryContainer.withValues(
              alpha: 0.7,
            ),
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          ),
        if (product.productType != null && product.productType!.isNotEmpty)
          Chip(
            label: Text(product.productType!),
            labelStyle: TextStyle(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: colorScheme.secondaryContainer.withValues(
              alpha: 0.7,
            ),
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          ),
        if (product.countrySale != null && product.countrySale!.isNotEmpty)
          Chip(
            label: Text(product.countrySale!),
            labelStyle: TextStyle(
              color: colorScheme.onTertiaryContainer,
              fontWeight: FontWeight.w500,
            ),
            backgroundColor: colorScheme.tertiaryContainer.withValues(
              alpha: 0.7,
            ),
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          ),
      ],
    );
  }

  Widget _buildDetailsCard(
    BuildContext context,
    Products product,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Product Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              'Barcode',
              product.barcode,
              colorScheme.primary,
              colorScheme,
            ),
            _buildDetailRow(context, 'Size', product.size, null, colorScheme),
            _buildDetailRow(
              context,
              'Packaging',
              product.packagingType,
              null,
              colorScheme,
            ),
            _buildDetailRow(
              context,
              'Origin',
              product.origin,
              null,
              colorScheme,
            ),
            _buildDetailRow(context, 'GPC', product.gpc, null, colorScheme),
            _buildDetailRow(
              context,
              'GPC Code',
              product.gpcCode,
              null,
              colorScheme,
            ),
            _buildDetailRow(
              context,
              'Country of Sale',
              product.countrySale,
              null,
              colorScheme,
            ),
            _buildDetailRow(
              context,
              'HS Codes',
              product.hSCODES,
              null,
              colorScheme,
            ),
            _buildDetailRow(context, 'Unit', product.unit, null, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(
    BuildContext context,
    Products product,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            if (product.detailsPage != null &&
                product.detailsPage!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                product.detailsPage!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
              ),
            ],
            if (product.detailsPageAr != null &&
                product.detailsPageAr!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Divider(color: colorScheme.outlineVariant),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.translate, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Description (Arabic)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                product.detailsPageAr!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                textDirection: TextDirection.rtl,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String? value,
    Color? labelColor,
    ColorScheme colorScheme,
  ) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 110,
            decoration: BoxDecoration(
              color: (labelColor ?? colorScheme.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: labelColor ?? colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
