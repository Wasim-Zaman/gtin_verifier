import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/retailer.dart';

class RetailerContent extends StatelessWidget {
  final List<Retailer> retailers;

  const RetailerContent({super.key, required this.retailers});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM d, yyyy');

    if (retailers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('No retailer information available')),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Retailer Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          ...retailers.map(
            (retailer) => Card(
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
                    // Store information
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.store,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                retailer.storeName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'SKU: ${retailer.productSku}',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),

                    // Store details
                    _buildDetailRow(
                      'Store ID:',
                      retailer.storeId,
                      Icons.numbers,
                      colorScheme,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Store GLN:',
                      retailer.storeGln,
                      Icons.tag,
                      colorScheme,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Last Updated:',
                      dateFormat.format(retailer.updatedAt),
                      Icons.update,
                      colorScheme,
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

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.primary.withOpacity(0.7)),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
