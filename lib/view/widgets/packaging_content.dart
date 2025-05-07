import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/packaging.dart';

class PackagingContent extends StatelessWidget {
  final List<Packaging> packagings;

  const PackagingContent({super.key, required this.packagings});

  @override
  Widget build(BuildContext context) {
    if (packagings.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('No packaging information available')),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Packaging Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...packagings.map(
            (packaging) => _buildPackagingCard(context, packaging),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagingCard(BuildContext context, Packaging packaging) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
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
            // Packaging type and status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        packaging.packagingType,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Status: ${packaging.status}',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),

            // Material and weight
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildDetailItem(
                  context,
                  'Material',
                  packaging.material,
                  Icons.category_outlined,
                ),
                _buildDetailItem(
                  context,
                  'Weight',
                  packaging.weight,
                  Icons.scale_outlined,
                ),
                if (packaging.dimensions != null)
                  _buildDetailItem(
                    context,
                    'Dimensions',
                    packaging.dimensions!,
                    Icons.straighten_outlined,
                  ),
                if (packaging.capacity != null)
                  _buildDetailItem(
                    context,
                    'Capacity',
                    packaging.capacity!,
                    Icons.water_drop_outlined,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Environmental properties
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildEnvironmentalChip(
                  context,
                  'Recyclable',
                  packaging.recyclable,
                  Icons.recycling_outlined,
                ),
                _buildEnvironmentalChip(
                  context,
                  'Biodegradable',
                  packaging.biodegradable,
                  Icons.eco_outlined,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Color and labeling
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildDetailItem(
                  context,
                  'Color',
                  packaging.color,
                  Icons.palette_outlined,
                ),
                _buildDetailItem(
                  context,
                  'Labeling',
                  packaging.labeling,
                  Icons.label_outline,
                ),
              ],
            ),

            // Images
            if (packaging.images.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Packaging Images',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: packaging.images.length,
                  itemBuilder: (context, index) {
                    final imageUrl = packaging.fullImageUrls[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                color: colorScheme.surfaceContainerHighest,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalChip(
    BuildContext context,
    String label,
    bool value,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = value ? colorScheme.tertiary : colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: ${value ? 'Yes' : 'No'}',
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
}
