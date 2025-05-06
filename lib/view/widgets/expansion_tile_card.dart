import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpansionTileCard extends ConsumerWidget {
  final String title;
  final IconData icon;
  final Widget Function(bool isLoading, bool hasError, Object? error)
  contentBuilder;
  final VoidCallback? onExpand;
  final bool initiallyExpanded;
  final AsyncValue<dynamic>? asyncValue;

  const ExpansionTileCard({
    super.key,
    required this.title,
    required this.icon,
    required this.contentBuilder,
    this.onExpand,
    this.initiallyExpanded = false,
    this.asyncValue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    // Determine loading and error state from asyncValue if provided
    bool isLoading = asyncValue?.isLoading ?? false;
    bool hasError = asyncValue?.hasError ?? false;
    Object? error = asyncValue?.error;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            // Show loading indicator in the title
            if (isLoading) ...[
              const SizedBox(width: 8),
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              ),
            ],
            // Show error indicator in the title
            if (hasError) ...[
              const SizedBox(width: 8),
              Icon(Icons.error_outline, color: colorScheme.error, size: 16),
            ],
          ],
        ),
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        onExpansionChanged: (expanded) {
          if (expanded && onExpand != null) {
            onExpand!();
          }
        },
        children: [contentBuilder(isLoading, hasError, error)],
      ),
    );
  }
}
